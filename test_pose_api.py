import requests

# Define the server URL
url = "http://127.0.0.1:8000/process-frame/"  # Change to your server's URL if hosted elsewhere

# Path to your test image
image_path = "/Users/ethandonley/Downloads/warrior-II-lead.jpg"

# Send the image as a POST request
with open(image_path, "rb") as image_file:
    files = {"file": image_file}
    try:
        response = requests.post(url, files=files)
        response.raise_for_status()  # Raise an error for bad responses (4xx and 5xx)
        
        # Parse the JSON response
        result = response.json()
        print("Response:", result)

        # Check for skeleton points and feedback
        if "skeleton" in result:
            print("Skeleton Points:", result["skeleton"])
        if "feedback" in result:
            print("Feedback:", result["feedback"])

    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")

