import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
import joblib
import os

# تحميل النموذج باستخدام compile=False لتجنب مشكلة mse
model = load_model("app/model/gru_model.h5", compile=False)
scaler = joblib.load("app/model/scaler.save")

# تحميل قائمة الفئات
with open("app/model/categories.txt", "r") as f:
    categories = [line.strip() for line in f.readlines()]

def predict_next_budget():
    # 1. تحميل البيانات الأصلية
    df = pd.read_csv("expenses_income_summary.csv")
    df = df[["Date", "category", "amount"]]
    df.dropna(inplace=True)

    # تنظيف الأعمدة
    df["amount"] = df["amount"].astype(str).str.replace(',', '').astype(float)
    df["Date"] = pd.to_datetime(df["Date"])
    df["month"] = df["Date"].dt.to_period("M")

    # 2. تجميع البيانات الشهرية حسب الفئة
    pivot_df = df.groupby(["month", "category"])["amount"].sum().unstack().fillna(0)

    # تأكد من ترتيب الأعمدة حسب الفئات المحفوظة
    for cat in categories:
        if cat not in pivot_df.columns:
            pivot_df[cat] = 0
    pivot_df = pivot_df[categories]

    # 3. تطبيع البيانات
    scaled_data = scaler.transform(pivot_df.values)

    # 4. أخذ آخر 3 أشهر كنموذج للتنبؤ
    last_sequence = scaled_data[-3:]
    last_sequence = np.expand_dims(last_sequence, axis=0)  # (1, 3, num_categories)

    # 5. التنبؤ بالقيم
    prediction = model.predict(last_sequence)[0]  # (num_categories,)
    predicted_scaled = prediction.reshape(1, -1)

    # 6. إعادة تحويل القيم من النطاق الطبيعي
    predicted_actual = scaler.inverse_transform(predicted_scaled)[0]

    # 7. تحويل النتائج إلى dict
    result = {category: float(round(amount, 2)) for category, amount in zip(categories, predicted_actual)}

    return result
