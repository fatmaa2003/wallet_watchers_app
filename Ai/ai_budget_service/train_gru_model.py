import os
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GRU, Dense, Input
import joblib

# === Load and clean CSVs ===

# Paths
csv1_path = "expenses_income_summary.csv"
csv2_path = "synthetic_income_expenses.csv"

# Function to standardize and validate input CSVs
def clean_and_validate_csv(df, source_name):
    df.columns = df.columns.str.strip().str.lower()  # Standardize column names

    required_columns = ["date", "category", "amount", "type"]
    for col in required_columns:
        if col not in df.columns:
            raise ValueError(f"❌ Column '{col}' is missing in {source_name}")

    df["amount"] = df["amount"].astype(str).str.replace(",", "").astype(float)
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df[df["date"].notnull()]
    df["month"] = df["date"].dt.to_period("M")
    return df

# Load CSVs
df1 = pd.read_csv(csv1_path)
df2 = pd.read_csv(csv2_path)

# Clean both datasets
df1 = clean_and_validate_csv(df1, "expenses_income_summary.csv")
df2 = clean_and_validate_csv(df2, "synthetic_income_expenses.csv")

# Combine both
combined_df = pd.concat([df1, df2], ignore_index=True)

# === Process Data ===

# Filter by type
exp_df = combined_df[combined_df["type"].str.upper() == "EXPENSE"]
inc_df = combined_df[combined_df["type"].str.upper() == "INCOME"]

# Pivot tables
pivot_exp = exp_df.groupby(["month", "category"])["amount"].sum().unstack().fillna(0)
pivot_inc = inc_df.groupby("month")["amount"].sum().rename("income")

# Merge into one dataset
full_df = pivot_exp.join(pivot_inc, how="left").fillna(0)
categories = full_df.columns.tolist()

# === Normalize and create sequences ===

scaler = MinMaxScaler()
scaled_data = scaler.fit_transform(full_df.values)

def create_sequences(data, steps=3):
    X, y = [], []
    for i in range(len(data) - steps):
        X.append(data[i:i + steps])
        y.append(data[i + steps])
    return np.array(X), np.array(y)

X, y = create_sequences(scaled_data)

# === Build and train model ===

model = Sequential([
    Input(shape=(X.shape[1], X.shape[2])),
    GRU(64),
    Dense(X.shape[2])
])
model.compile(optimizer="adam", loss="mse")
model.fit(X, y, epochs=50, batch_size=8, verbose=1)

# === Save artifacts ===

os.makedirs("model", exist_ok=True)
model.save("model/gru_model.keras")
joblib.dump(scaler, "model/scaler.pkl")

with open("model/categories.txt", "w") as f:
    for cat in categories:
        f.write(f"{cat}\n")

print("✅ Model trained on both CSV datasets and saved successfully.")
