from fastapi import FastAPI, UploadFile, File, HTTPException
from firebase_admin import credentials, initialize_app, storage
import cv2
import numpy as np
import mediapipe as mp
import os
import uuid
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
from typing import List, Dict

# Initialize FastAPI
app = FastAPI()

# Firebase Admin Initialization
FIREBASE_CREDENTIALS_PATH = os.path.join(os.path.dirname(__file__), "workit-d3aee-firebase-adminsdk-o0jlh-fd824b8f55.json")
FIREBASE_BUCKET_NAME = "workit-d3aee.appspot.com"

cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
initialize_app(cred, {"storageBucket": FIREBASE_BUCKET_NAME})

# Initialize MediaPipe Pose
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(
    static_image_mode=False,
    model_complexity=2,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)


class LandmarkSmoother:
    def __init__(self, alpha=0.5):
        """
        Initialize a landmark smoother with an exponential moving average filter.
        :param alpha: Smoothing factor (0 < alpha ≤ 1). Higher alpha means less smoothing.
        """
        self.alpha = alpha
        self.previous_landmarks = None

    def smooth(self, current_landmarks: List[Dict[str, float]]) -> List[Dict[str, float]]:
        """
        Smooth current landmarks using exponential moving average.
        :param current_landmarks: List of landmarks from the current frame.
        :return: Smoothed landmarks.
        """
        if self.previous_landmarks is None:
            self.previous_landmarks = current_landmarks
            return current_landmarks

        smoothed_landmarks = []
        for curr, prev in zip(current_landmarks, self.previous_landmarks):
            smoothed_landmarks.append({
                "x": self.alpha * curr["x"] + (1 - self.alpha) * prev["x"],
                "y": self.alpha * curr["y"] + (1 - self.alpha) * prev["y"],
                "z": self.alpha * curr["z"] + (1 - self.alpha) * prev["z"],
                "visibility": curr["visibility"]
            })

        self.previous_landmarks = smoothed_landmarks
        return smoothed_landmarks


# Initialize the smoother globally
landmark_smoother = LandmarkSmoother(alpha=0.5)


def is_squat(skeleton_points: List[Dict[str, float]]) -> bool:
    hip = skeleton_points[23]  # Left hip
    knee = skeleton_points[25]  # Left knee
    ankle = skeleton_points[27]  # Left ankle

    def calculate_angle(a, b, c):
        ba = (a["x"] - b["x"], a["y"] - b["y"])
        bc = (c["x"] - b["x"], c["y"] - b["y"])
        dot_product = ba[0] * bc[0] + ba[1] * bc[1]
        mag_a = (ba[0]**2 + ba[1]**2) ** 0.5
        mag_b = (bc[0]**2 + bc[1]**2) ** 0.5
        return np.arccos(dot_product / (mag_a * mag_b)) * (180 / np.pi)

    angle = calculate_angle(hip, knee, ankle)
    return 70 <= angle <= 100


@app.post("/process-frame/")
async def process_frame(file: UploadFile = File(...)):
    if not file.filename.endswith(("jpg", "jpeg", "png")):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload an image.")

    try:
        file_data = await file.read()
        image = cv2.imdecode(np.frombuffer(file_data, np.uint8), cv2.IMREAD_COLOR)
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = pose.process(rgb_image)

        skeleton_points: List[Dict[str, float]] = []

        if results.pose_landmarks:
            for landmark in results.pose_landmarks.landmark:
                skeleton_points.append({
                    "x": landmark.x,
                    "y": landmark.y,
                    "z": landmark.z,
                    "visibility": landmark.visibility
                })

        if not skeleton_points or len(skeleton_points) != 33:
            raise HTTPException(status_code=422, detail="Invalid or incomplete skeleton points.")

        smoothed_skeleton = landmark_smoother.smooth(skeleton_points)
        feedback = "Good squat!" if is_squat(smoothed_skeleton) else "Adjust your form: Lower your hips for a squat."

        return {"skeleton": smoothed_skeleton, "feedback": feedback}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def evaluate_exercise(skeleton_points):
    """
    Analyze the skeleton points to provide feedback on exercise form.
    Adjust this function based on specific exercises (e.g., squats, push-ups).
    """
    feedback = []

    if len(skeleton_points) > 0:
        feedback.append("Skeleton points detected; add specific feedback logic here.")
    else:
        feedback.append("No keypoints detected; ensure the exercise is performed in view of the camera.")

    return feedback



