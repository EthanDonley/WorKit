from fastapi import FastAPI, UploadFile, File, HTTPException
from firebase_admin import credentials, initialize_app, storage
import cv2
import numpy as np
import openai
import os
import uuid

# Initialize FastAPI
app = FastAPI()

# Firebase Admin Initialization
FIREBASE_CREDENTIALS_PATH = "/Users/ethandonley/Desktop/WorKit/WorKit/workit-d3aee-firebase-adminsdk-o0jlh-97c359092f.json"
FIREBASE_BUCKET_NAME = "workit-d3aee.appspot.com"

cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
initialize_app(cred, {"storageBucket": FIREBASE_BUCKET_NAME})

# OpenAI API Configuration
openai.api_key = os.getenv("OPENAI_API_KEY", "default_key")
openai.api_base = os.getenv("OPENAI_API_BASE", "https://api.openai.com/v1")
MODEL_NAME = "gpt-4"  # Replace with your desired model name

# Function to Upload Image to Firebase and Get URL
def upload_to_firebase(file_data: bytes, file_name: str) -> str:
    bucket = storage.bucket()
    blob = bucket.blob(f"images/{file_name}")
    blob.upload_from_string(file_data, content_type="image/jpeg")
    blob.make_public()  # Make the file publicly accessible
    return blob.public_url

# Function to Query OpenAI
def query_openai(prompt: str, image_url: str) -> str:
    try:
        response = openai.ChatCompletion.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": "You are an AI specializing in image analysis."},
                {"role": "user", "content": prompt},
                {"role": "user", "content": f"Analyze this image: {image_url}"}
            ],
        )
        return response["choices"][0]["message"]["content"]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {e}")

# API Endpoint for AI Analysis
@app.post("/analyze/")
async def analyze_image(file: UploadFile = File(...), prompt: str = "Analyze this image"):
    if not file.filename.endswith(("jpg", "jpeg", "png")):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload an image.")

    # Read the file into memory
    file_data = await file.read()
    image = cv2.imdecode(np.frombuffer(file_data, np.uint8), cv2.IMREAD_COLOR)

    # Upload the image to Firebase
    file_name = f"{uuid.uuid4()}.jpg"
    image_url = upload_to_firebase(file_data, file_name)

    # Perform AI analysis with OpenAI
    ai_response = query_openai(prompt, image_url)

    return {
        "image_url": image_url,
        "ai_analysis": ai_response
    }


@app.post("/process-frame/")
async def process_frame(file: UploadFile = File(...)):
    if not file.filename.endswith(("jpg", "jpeg", "png")):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload an image.")

    # Read and decode the image
    file_data = await file.read()
    image = cv2.imdecode(np.frombuffer(file_data, np.uint8), cv2.IMREAD_COLOR)

    # Perform pose detection (dummy example; replace with actual pose detection logic)
    skeleton_points = [{"x": 0.5, "y": 0.5, "visibility": 0.99}]  # Example points

    return {"skeleton": skeleton_points}
