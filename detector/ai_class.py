import os
import json
import random
import cv2
import torch
import wikipediaapi
import numpy as np
from io import BytesIO
from PIL import Image
from django.core.files.base import ContentFile
from torchvision import models, transforms
from ultralytics import YOLO
from typing import Dict, Tuple, Optional


class AIClass:
    BASE_PATH = "D:\\ZraeGlobal\\CropAndWeedD\\Crop_and_Weed_Detector\\models"
    CLASSIFICATION_PATH = os.path.join(BASE_PATH, "classification")
    DETECTION_PATH = os.path.join(BASE_PATH, "detection")

    MODEL_COLORS = {"weed": (255, 0, 0), "crop": (0, 0, 255)}

    CLASSIFICATION_MODELS = {
        "resnet": {
            "filename": "ResNet50_finetuned.pth",
            "json": "ResNet50_cls_idx.json",
            "model": models.resnet50,
            "weights": models.ResNet50_Weights.IMAGENET1K_V2,
        },
        "mobilenet": {
            "filename": "MobileNetV3_finetuned.pth",
            "json": "MobileNetV3_cls_idx.json",
            "model": models.mobilenet_v3_large,
            "weights": models.MobileNet_V3_Large_Weights.IMAGENET1K_V2,
        },
        "efficientnet": {
            "filename": "EfficientNet_finetuned.pth",
            "json": "EfficientNet_cls_idx.json",
            "model": models.efficientnet_b0,
            "weights": models.EfficientNet_B0_Weights.IMAGENET1K_V1,
        },
    }

    DETECTION_MODELS = {
        "yolov8_m": "yolo_v8_m.pt",
        "yolov8_l": "yolo_v8_l.pt",
        "yolov8_x": "yolo_v8_x.pt",
    }

    def __init__(self):
        # Check device availability
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        self.classification_models = {}
        self.class_to_idx = {}
        self.idx_to_class = {}

        # Load classification and detection models
        self._load_classification_models()
        self._load_detection_models()

        # Initialize Wikipedia API
        self.wiki_api = wikipediaapi.Wikipedia(
            language="en",
            user_agent="CropDetectionAI/1.0 (https://github.com/username/cropdetection)"
        )

        # Image transform pipeline for classification
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        ])

    def close(self):
        """
        Manually clean up resources (like wikipediaapi session)
        to avoid 'NoneType' object is not callable errors.
        """
        if hasattr(self, "wiki_api") and self.wiki_api:
            try:
                del self.wiki_api
            except Exception as e:
                print(f"Error while closing Wikipedia API: {e}")

    def __del__(self):
        """
        Ensure proper cleanup if the object goes out of scope
        without an explicit close() call.
        """
        self.close()

    def _load_classification_models(self) -> None:
        """Loads classification models from fine-tuned weights or defaults to pretrained models."""
        for model_name, model_info in self.CLASSIFICATION_MODELS.items():
            model_path = os.path.join(self.CLASSIFICATION_PATH, model_info["filename"])
            class_idx_path = os.path.join(self.CLASSIFICATION_PATH, model_info["json"])

            if os.path.exists(model_path) and os.path.exists(class_idx_path):
                self._load_finetuned_model(
                    model_name,
                    model_info["model"],
                    model_path,
                    class_idx_path
                )
            else:
                print(f"Warning: {model_name} fine-tuned model missing. "
                      f"Loading default pretrained model.")
                self._load_pretrained_model(
                    model_name,
                    model_info["model"],
                    model_info["weights"]
                )

    def _load_finetuned_model(self, model_name: str, model_fn, model_path: str, class_idx_path: str) -> None:
        """Loads a fine-tuned classification model with its class index mappings."""
        with open(class_idx_path, "r") as f:
            class_to_idx = json.load(f)
            self.class_to_idx[model_name] = class_to_idx
            self.idx_to_class[model_name] = {v: k for k, v in class_to_idx.items()}

        # Instantiate the base model
        model = model_fn(weights=None)

        # Update classifier layer to match the number of classes
        if isinstance(model, models.ResNet):
            model.fc = torch.nn.Linear(model.fc.in_features, len(class_to_idx))
        elif isinstance(model, models.EfficientNet):
            model.classifier[1] = torch.nn.Linear(model.classifier[1].in_features, len(class_to_idx))
        elif isinstance(model, models.MobileNetV3):
            model.classifier[3] = torch.nn.Linear(model.classifier[3].in_features, len(class_to_idx))

        # Load the fine-tuned weights
        model.load_state_dict(torch.load(model_path, map_location=self.device))
        model.to(self.device).eval()

        self.classification_models[model_name] = model

    def _load_pretrained_model(self, model_name: str, model_fn, model_weights) -> None:
        """
        Loads a default pretrained model when the fine-tuned model files are not available.
        This fallback ensures the code runs even if fine-tuned weights are missing.
        """
        model = model_fn(weights=model_weights).to(self.device).eval()
        self.classification_models[model_name] = model

    def _load_detection_models(self) -> None:
        """Loads YOLO detection models."""
        self.detection_models = {
            key: YOLO(os.path.join(self.DETECTION_PATH, filename))
            for key, filename in self.DETECTION_MODELS.items()
        }

    def classify(self, image: Image.Image, model_name: str) -> Dict[str, str]:
        """Classifies an image using the selected model."""
        model_name = model_name.lower()
        if model_name not in self.classification_models:
            return {"error": f"Model '{model_name}' not found."}

        model = self.classification_models[model_name]
        input_tensor = self.transform(image).unsqueeze(0).to(self.device)

        with torch.no_grad():
            outputs = model(input_tensor)
            probabilities = torch.nn.functional.softmax(outputs[0], dim=0)
            confidence, predicted_idx = torch.max(probabilities, dim=0)

        if model_name in self.idx_to_class:
            predicted_class = self.idx_to_class[model_name].get(predicted_idx.item(), str(predicted_idx.item()))
        else:
            predicted_class = str(predicted_idx.item())

        return {
            "class_name": predicted_class,
            "confidence": f"{confidence.item() * 100:.2f}%"
        }

    def detect(self, image_file, model_choice: str, image_id: int) -> Tuple[Optional[ContentFile], int, int]:
        """
        Performs object detection on an image.
        Returns (annotated_content_file, weed_count, crop_count).
        """
        image = Image.open(image_file).convert("RGB")
        image_cv = np.array(image)

        model = self.detection_models.get(model_choice)
        if not model:
            return None, 0, 0

        # Run detection
        results = model(image_cv)

        # Process the detections and return annotated image + counts
        return self._process_detection_results(results, image_cv, image_id)

    def _process_detection_results(self, results, image_cv, image_id: int) -> Tuple[ContentFile, int, int]:
        """Processes detection results, draws bounding boxes, and returns annotated image + counts."""
        weed_count = 0
        crop_count = 0

        if not results or not results[0].boxes:
            print(f"No detections found in image {image_id}")

        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                conf = float(box.conf[0]) * 100
                label = result.names[int(box.cls[0])]

                if "weed" in label.lower():
                    color = self.MODEL_COLORS["weed"]
                    weed_count += 1
                else:
                    color = self.MODEL_COLORS["crop"]
                    crop_count += 1

                cv2.rectangle(image_cv, (x1, y1), (x2, y2), color, 3)
                cv2.putText(
                    image_cv,
                    f"{label}: {conf:.2f}%",
                    (x1, y1 - 10),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    color,
                    2
                )

        # Convert annotated image to a ContentFile
        img_io = BytesIO()
        Image.fromarray(image_cv).save(img_io, format="PNG")
        img_io.seek(0)
        annotated_file = ContentFile(img_io.read(), name=f"annotated_{image_id}.png")

        return annotated_file, weed_count, crop_count


# -----------------------------------------------------------------
# Testing Logic (based on your requested snippet)
# -----------------------------------------------------------------
if __name__ == "__main__":
    # Initialize AIClass
    ai = AIClass()

    try:
        # Load an image for testing
        test_image_path = "E:\\FinalYearProjects\\Crop-Yield-Prediction\\sample_images\\samples\\Cherry\\image15.jpeg"
        test_image = Image.open(test_image_path).convert("RGB")

        # 1. Test classification
        classification_result = ai.classify(test_image, "resnet")
        print("Classification Result:", classification_result)

        # 2. Test detection
        detection_model = "yolov8_m"
        image_id = random.randint(1000, 9999)

        # Convert the PIL image to an in-memory file (BytesIO)
        img_io = BytesIO()
        test_image.save(img_io, format="PNG")
        img_io.seek(0)

        processed_image, weed_count, crop_count = ai.detect(img_io, detection_model, image_id)
        print(f"Detection Model: {detection_model}")
        print(f"Weed Count: {weed_count}, Crop Count: {crop_count}")

        # Save the processed detection image
        annotated_filename = f"annotated_{image_id}.png"
        with open(annotated_filename, "wb") as f:
            f.write(processed_image.read())
        print(f"Annotated image saved as {annotated_filename}")

    finally:
        # Close resources (important to avoid the 'NoneType' error in Wikipedia.__del__)
        ai.close()
