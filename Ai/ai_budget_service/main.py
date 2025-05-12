import os
import json
import numpy as np
import tensorflow as tf
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from bson import ObjectId
import joblib
from dotenv import load_dotenv
from datetime import datetime
from dateutil.relativedelta import relativedelta

# Load env
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

# MongoDB setup
client = MongoClient(MONGO_URI)
db = client[DB_NAME]
budgets_col = db["budgets"]  # New: collection for storing AI predictions

# Load AI model + scaler
model = tf.keras.models.load_model("model/gru_model.keras")
scaler = joblib.load("model/scaler.pkl")

# Load training categories
with open("model/categories.txt", "r") as f:
    categories = [line.strip() for line in f.readlines()]

# FastAPI setup
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/predict_budget")
async def predict_budget(payload: dict):
    try:
        user_id = payload.get("userId")
        if not user_id:
            raise HTTPException(status_code=400, detail="userId is required")

        user_object_id = ObjectId(user_id)

        # Get expense & income history
        incomes = list(db.income.find({"userId": user_object_id}))
        expenses = list(db.expenses.find({"userId": user_object_id}))

        if not expenses:
            raise HTTPException(status_code=404, detail="No expense data found")

        income_sum = sum(item.get("incomeAmount", 0) for item in incomes) if incomes else 0

        # Group expenses
        expense_by_category = {}
        for expense in expenses:
            cat = expense.get("categoryName", "Other")
            amount = expense.get("expenseAmount", 0)
            expense_by_category[cat] = expense_by_category.get(cat, 0) + amount

        # Input vector creation
        input_vector = []
        for cat in categories:
            if cat.lower() == "income":
                input_vector.append(income_sum)
            else:
                input_vector.append(expense_by_category.get(cat, 0))

        if len(input_vector) != scaler.n_features_in_:
            raise ValueError(f"Input vector length {len(input_vector)} does not match scaler input {scaler.n_features_in_}")

        # Predict next month
        scaled_input = scaler.transform([input_vector])
        input_sequence = np.expand_dims(np.repeat(scaled_input, 3, axis=0), axis=0)
        prediction = model.predict(input_sequence)
        predicted_values = scaler.inverse_transform(prediction)[0]
        python_values = [float(val) for val in predicted_values]

        # Get predicted month
        next_month = datetime.now() + relativedelta(months=1)
        predicted_month_str = next_month.strftime("%B %Y")  # e.g., "June 2025"

        # Build response
        total_spending = round(float(sum(python_values[:-1])) if "income" in categories else sum(python_values), 2)
        category_limits = [
            {"category": cat, "amount": round(float(python_values[i]), 2)}
            for i, cat in enumerate(categories)
        ]

        response = {
            "userId": str(user_object_id),
            "predictedMonth": predicted_month_str,
            "total": total_spending,
            "byCategory": category_limits,
            "createdAt": datetime.utcnow()
        }

        # Save to MongoDB
        budgets_col.insert_one(response)

        # Remove ObjectId and createdAt from response (optional)
        response.pop("_id", None)

        return response

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating prediction: {str(e)}")
