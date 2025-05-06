from fastapi import APIRouter
from app.utils.predict import predict_next_budget

router = APIRouter()

@router.get("/next-month")
def get_next_month_prediction():
    prediction = predict_next_budget()
    return {"prediction": float(prediction)}  # تحويل Numpy float إلى Python float
