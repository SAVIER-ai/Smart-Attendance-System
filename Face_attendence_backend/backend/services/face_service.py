from deepface import DeepFace
import base64
import os
import uuid

UPLOAD_FOLDER = "uploads"


# Save base64 image
def save_image(base64_image):
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)

    filename = f"{uuid.uuid4()}.jpg"

    path = os.path.join(
        UPLOAD_FOLDER,
        filename
    )

    image_data = base64.b64decode(base64_image)

    with open(path, "wb") as f:
        f.write(image_data)

    return path


# Save registration image
def encode_face_from_base64(base64_image):
    path = save_image(base64_image)

    return path


# Verify faces using DeepFace directly
def verify_faces(
    registered_image,
    captured_image,
):
    try:
        result = DeepFace.verify(
            img1_path=registered_image,
            img2_path=captured_image,

            model_name="Facenet",

            detector_backend="opencv",

            enforce_detection=False
        )

        print("VERIFY RESULT:", result)

        return result["verified"]

    except Exception as e:
        print("VERIFY ERROR:", e)
        return False