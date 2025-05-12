# train_gru_model.py

import os
import pandas as pd
import numpy as np
from pymongo import MongoClient
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GRU, Dense, Input
import joblib
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

# MongoDB connection
client = MongoClient(MONGO_URI)
db = client[DB_NAME]
expenses_col = db["expenses"]
income_col = db["income"]

# Load MongoDB data
df_exp_mongo = pd.DataFrame(list(expenses_col.find()))
df_inc_mongo = pd.DataFrame(list(income_col.find()))

# Convert ObjectId timestamp to datetime if createdAt is missing
if "createdAt" not in df_exp_mongo.columns and "_id" in df_exp_mongo.columns:
    df_exp_mongo["createdAt"] = df_exp_mongo["_id"].apply(lambda x: x.generation_time)

if "createdAt" not in df_inc_mongo.columns and "_id" in df_inc_mongo.columns:
    df_inc_mongo["createdAt"] = df_inc_mongo["_id"].apply(lambda x: x.generation_time)

# Parse dates and assign months
if "createdAt" in df_exp_mongo.columns:
    df_exp_mongo["createdAt"] = pd.to_datetime(df_exp_mongo["createdAt"], errors="coerce")
    df_exp_mongo = df_exp_mongo[df_exp_mongo["createdAt"].notnull()]
    df_exp_mongo["month"] = df_exp_mongo["createdAt"].dt.to_period("M")

if "createdAt" in df_inc_mongo.columns:
    df_inc_mongo["createdAt"] = pd.to_datetime(df_inc_mongo["createdAt"], errors="coerce")
    df_inc_mongo = df_inc_mongo[df_inc_mongo["createdAt"].notnull()]
    df_inc_mongo["month"] = df_inc_mongo["createdAt"].dt.to_period("M")

# Load CSV
df_csv = pd.read_csv("expenses_income_summary.csv")
df_csv = df_csv[["Date", "category", "amount", "type"]].dropna()
df_csv["amount"] = df_csv["amount"].astype(str).str.replace(",", "").astype(float)
df_csv["Date"] = pd.to_datetime(df_csv["Date"])
df_csv["month"] = df_csv["Date"].dt.to_period("M")

# Split CSV by type
df_csv_exp = df_csv[df_csv["type"] == "EXPENSE"]
df_csv_inc = df_csv[df_csv["type"] == "INCOME"]

# Pivot expenses
pivot_exp_csv = df_csv_exp.groupby(["month", "category"])["amount"].sum().unstack().fillna(0)
pivot_exp_mongo = df_exp_mongo.groupby(["month", "categoryName"])["expenseAmount"].sum().unstack().fillna(0)
pivot_exp = pd.concat([pivot_exp_csv, pivot_exp_mongo]).groupby(level=0).sum()

# Pivot incomes - FIXED PART
pivot_inc_csv = df_csv_inc.groupby("month")["amount"].sum().rename("income")

if not df_inc_mongo.empty and "incomeAmount" in df_inc_mongo:
    pivot_inc_mongo = df_inc_mongo.groupby("month")["incomeAmount"].sum().rename("income")
else:
    pivot_inc_mongo = pd.Series(dtype="float64", name="income")

pivot_inc = pd.concat([pivot_inc_csv, pivot_inc_mongo]).groupby(level=0).sum()

# Merge data
full_df = pivot_exp.join(pivot_inc, how="left").fillna(0)
categories = full_df.columns.tolist()

# Normalize
scaler = MinMaxScaler()
scaled_data = scaler.fit_transform(full_df.values)

# Sequence creator
def create_sequences(data, steps=3):
    X, y = [], []
    for i in range(len(data) - steps):
        X.append(data[i:i + steps])
        y.append(data[i + steps])
    return np.array(X), np.array(y)

X, y = create_sequences(scaled_data)

# GRU Model
model = Sequential([
    Input(shape=(X.shape[1], X.shape[2])),
    GRU(64),
    Dense(X.shape[2])
])
model.compile(optimizer="adam", loss="mse")
model.fit(X, y, epochs=50, batch_size=8, verbose=1)

# Save artifacts
os.makedirs("model", exist_ok=True)
model.save("model/gru_model.keras")
joblib.dump(scaler, "model/scaler.pkl")
with open("model/categories.txt", "w") as f:
    for cat in categories:
        f.write(f"{cat}\n")

print("✅ Model trained on MongoDB + CSV and saved.")
