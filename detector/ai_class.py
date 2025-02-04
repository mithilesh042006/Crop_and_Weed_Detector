import random
import cv2
import numpy as np
from django.core.files.base import ContentFile
from io import BytesIO
from PIL import Image


class AIClass:
    MODEL_COLORS = {
        "model_1": (255, 0, 0),  # Red
        "model_2": (0, 255, 0),  # Green
        "model_3": (0, 0, 255),  # Blue
    }

    @staticmethod
    def detect_species(image_file, model_choice, image_id):
        """
        Process an uploaded image, draw random bounding boxes, and return processed data.

        Args:
            image_file (InMemoryUploadedFile): Uploaded image file from request.
            model_choice (str): Selected AI model (determines bounding box color).
            image_id (int): Unique image ID for saving.

        Returns:
            processed_image (ContentFile): Processed image with bounding boxes.
            crop_name (str): Placeholder for detected crop.
            summary (str): Placeholder summary.
        """

        # Open image using PIL
        image = Image.open(image_file)

        # Ensure image is in RGB format (handle grayscale & RGBA cases)
        if image.mode != "RGB":
            image = image.convert("RGB")

        # Convert to OpenCV format
        image_cv = np.array(image)

        # Get image dimensions
        height, width, _ = image_cv.shape

        # Get bounding box color based on model choice (default to Red)
        box_color = AIClass.MODEL_COLORS.get(model_choice, (255, 0, 0))

        # Draw 3 non-overlapping random bounding boxes
        for _ in range(3):
            x1 = random.randint(0, width - 50)
            y1 = random.randint(0, height - 50)
            x2 = x1 + random.randint(30, 100)
            y2 = y1 + random.randint(30, 100)
            
            # Ensure bounding box stays within image bounds
            x2 = min(x2, width)
            y2 = min(y2, height)

            cv2.rectangle(image_cv, (x1, y1), (x2, y2), box_color, 3)

        # Convert back to PIL Image
        boxed_image = Image.fromarray(image_cv)

        # Save image to BytesIO buffer
        img_io = BytesIO()
        boxed_image.save(img_io, format='PNG')
        img_io.seek(0)

        # Save as Django ContentFile
        processed_image = ContentFile(img_io.read(), name=f"processed_{image_id}.png")

        # Return processed image, crop name, and summary
        return processed_image, "Sample Crop", "Detected species placeholder"
