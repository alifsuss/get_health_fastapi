#Create a fastapi app that return datetime upon get reqeust
from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/app")
def read_root():
    return {"datetime": datetime.now()}

# Run the app
# uvicorn main:app --reload

#Create unittest
