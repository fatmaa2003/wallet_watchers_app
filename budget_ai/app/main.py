from fastapi import FastAPI
from fastapi.responses import FileResponse

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Budget AI API is running"}

@app.get("/favicon.ico")
async def favicon():
    return FileResponse("app/static/favicon.ico")
