import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GRU, Dense
import joblib
import os

# 1. تحميل وتنظيف البيانات
df = pd.read_csv("expenses_income_summary.csv")
df = df[["Date", "category", "amount"]].dropna()
df["amount"] = df["amount"].astype(str).str.replace(',', '').astype(float)
df["Date"] = pd.to_datetime(df["Date"])
df["month"] = df["Date"].dt.to_period("M")

# 2. تحويل البيانات إلى Pivot Table
pivot_df = df.groupby(["month", "category"])["amount"].sum().unstack().fillna(0)
categories = pivot_df.columns.tolist()

# 3. حفظ أسماء الفئات
os.makedirs("app/model", exist_ok=True)
with open("app/model/categories.txt", "w") as f:
    for category in categories:
        f.write(f"{category}\n")

# 4. تطبيع البيانات
scaler = MinMaxScaler()
scaled_data = scaler.fit_transform(pivot_df.values)

# 5. تحضير بيانات التسلسل
X, y = [], []
sequence_length = 3
for i in range(len(scaled_data) - sequence_length):
    X.append(scaled_data[i:i+sequence_length])
    y.append(scaled_data[i+sequence_length])

X = np.array(X)
y = np.array(y)

# 6. بناء النموذج
model = Sequential()
model.add(GRU(64, input_shape=(sequence_length, X.shape[2])))
model.add(Dense(X.shape[2]))
model.compile(optimizer='adam', loss='mse')

# 7. تدريب النموذج
model.fit(X, y, epochs=100, verbose=1)

# 8. حفظ النموذج والـ scaler
model.save("app/model/gru_model.h5")
joblib.dump(scaler, "app/model/scaler.save")

print("✅ تم تدريب وحفظ النموذج والـ Scaler بنجاح")
