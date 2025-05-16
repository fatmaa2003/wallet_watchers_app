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

# Load environment variables
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

# MongoDB setup
client = MongoClient(MONGO_URI)
db = client[DB_NAME]
budgets_col = db["budgets"]
income_col = db["income"]
expenses_col = db["expenses"]

# Load GRU model and scaler
model = tf.keras.models.load_model("model/gru_model.keras")
scaler = joblib.load("model/scaler.pkl")

# Load trained category list
with open("model/categories.txt", "r") as f:
    categories = [line.strip() for line in f.readlines()]
lowercase_categories = [c.lower() for c in categories]  # for matching

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

        # Fetch income and expenses for the user
        incomes = list(income_col.find({"userId": user_object_id}))
        expenses = list(expenses_col.find({"userId": user_object_id}))

        if not expenses:
            raise HTTPException(status_code=404, detail="No expense data found")

        income_sum = sum(item.get("incomeAmount", 0) for item in incomes) if incomes else 0

        # Group expense totals by lowercased category name
        expense_by_category = {}
        for expense in expenses:
            raw_cat = expense.get("categoryName", "Other").strip()
            cat = raw_cat.lower()
            amount = expense.get("expenseAmount", 0)
            expense_by_category[cat] = expense_by_category.get(cat, 0) + amount

        # Prepare input vector aligned with trained categories
        input_vector = []
        for i, cat in enumerate(categories):
            if cat.lower() == "income":
                input_vector.append(income_sum)
            else:
                input_vector.append(expense_by_category.get(cat.lower(), 0))

        if len(input_vector) != scaler.n_features_in_:
            raise ValueError(f"Input vector length {len(input_vector)} does not match scaler input {scaler.n_features_in_}")

        # Predict next month
        scaled_input = scaler.transform([input_vector])
        input_sequence = np.expand_dims(np.repeat(scaled_input, 3, axis=0), axis=0)
        prediction = model.predict(input_sequence)
        predicted_values = scaler.inverse_transform(prediction)[0]
        python_values = [float(val) for val in predicted_values]

        # Identify user's used categories in lowercase
        user_categories = set(expense.get("categoryName", "").strip().lower() for expense in expenses)

        # Filter output to only include categories used by user (case-insensitive)
        category_limits = [
            {"category": cat, "amount": round(python_values[i], 2)}
            for i, cat in enumerate(categories)
            if cat.lower() in user_categories
        ]

        # Determine next month's label
        next_month = datetime.now() + relativedelta(months=1)
        predicted_month_str = next_month.strftime("%B %Y")

        # Build and return response
        response = {
            "userId": str(user_object_id),
            "predictedMonth": predicted_month_str,
            "total": round(sum([c["amount"] for c in category_limits]), 2),
            "byCategory": category_limits,
            "createdAt": datetime.utcnow()
        }

        budgets_col.insert_one(response)
        response.pop("_id", None)

        return response

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating prediction: {str(e)}")
