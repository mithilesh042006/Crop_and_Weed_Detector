from django.shortcuts import render
from django.contrib.auth.decorators import login_required, user_passes_test
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import ImageRecord
from .ai_class import AIClass
from admin_dashboard.models import Tip, Disease, News
from PIL import Image
from io import BytesIO
import random


def is_admin(user):
    return user.is_authenticated and user.is_admin

@csrf_exempt
@login_required
def upload_image(request):
    """
    POST /api/upload
    Accepts:
      - image (file)
      - model (str)
      - mode (str): either 'classify' or 'detect'
      - (optional) image_id
    Calls AI logic, stores the record in DB, and returns relevant info.
    """
    if request.method == 'POST':
        image_data = None
        image_id = None
        mode = None

        # Determine if JSON or Form-data
        if request.content_type == "application/json":
            # JSON body
            try:
                body = json.loads(request.body.decode('utf-8'))
            except json.JSONDecodeError:
                return JsonResponse({"error": "Invalid JSON format"}, status=400)

            model_choice = body.get("model")
            mode = body.get("mode")  # new parameter
            image_id = body.get("image_id", None)

            # For a purely JSON-based upload, you'd need base64 or some data. 
            # Otherwise, you'd typically get the file from request.FILES. 
            # This example assumes your real flow uses form-data for the actual image.
            # If you do pure JSON image uploading, handle it here.

        else:
            # Form-data approach
            image_data = request.FILES.get("image")
            model_choice = request.POST.get("model")
            mode = request.POST.get("mode")  # new parameter
            image_id = request.POST.get("image_id", None)

        # Validate required fields
        if not image_data:
            return JsonResponse({"error": "No image provided"}, status=400)

        if not model_choice:
            return JsonResponse({"error": "No model provided (e.g., 'resnet' or 'yolov8_m')"}, status=400)

        if not mode:
            return JsonResponse({"error": "No mode provided (must be 'classify' or 'detect')"}, status=400)

        # Create a DB record to track
        record = ImageRecord.objects.create(
            user=request.user,
            image_data=image_data,
            model_chosen=model_choice,
            summary="Processing...",
            crop_name="Unknown"
        )

        # Initialize AIClass for processing
        ai = AIClass()
        try:
            # Perform the requested operation
            if mode.lower() == "classify":
                # Convert the incoming file to PIL
                pil_image = Image.open(image_data).convert("RGB")
                cls_result = ai.classify(pil_image, model_choice)

                if "error" in cls_result:
                    return JsonResponse({"error": cls_result["error"]}, status=400)

                record.crop_name = cls_result["class_name"]
                record.summary = f"Confidence: {cls_result['confidence']}"
                record.save()

                response_data = {
                    "message": "Image classified successfully",
                    "mode": mode,
                    "model_chosen": model_choice,
                    "image_id": record.id,
                    "class_name": cls_result["class_name"],
                    "confidence": cls_result["confidence"],
                }
                return JsonResponse(response_data, status=200)

            elif mode.lower() == "detect":
                # We'll run detection and store the annotated file
                annotated_file, weed_count, crop_count = ai.detect(image_data, model_choice, record.id)

                if annotated_file is None:
                    return JsonResponse({"error": f"Detection model '{model_choice}' not found."}, status=400)

                # Store the annotated file
                record.processed_image = annotated_file
                # Example usage for summary:
                record.crop_name = f"Detected objects"
                record.summary = f"Weeds: {weed_count}, Crops: {crop_count}"
                record.save()

                response_data = {
                    "message": "Image detected successfully",
                    "mode": mode,
                    "model_chosen": model_choice,
                    "image_id": record.id,
                    "weed_count": weed_count,
                    "crop_count": crop_count,
                    "processed_image_url": record.processed_image.url
                }
                return JsonResponse(response_data, status=200)

            else:
                return JsonResponse({"error": "Invalid mode (must be 'classify' or 'detect')"}, status=400)

        finally:
            # Make sure we close the AIClass instance
            ai.close()

    else:
        return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
def delete_image(request):
    """
    DELETE /api/delete
    Expects JSON body with 'image_id' to delete from DB.
    """
    if request.method == 'DELETE':
        try:
            body = json.loads(request.body.decode('utf-8'))
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)

        image_id = body.get('image_id', None)
        if image_id is None:
            return JsonResponse({"error": "No image_id provided"}, status=400)

        try:
            record = ImageRecord.objects.get(id=image_id)
            record.delete()
            return JsonResponse({"message": f"Image {image_id} deleted successfully"}, status=200)
        except ImageRecord.DoesNotExist:
            return JsonResponse({"error": f"Image {image_id} not found"}, status=404)

    return JsonResponse({"error": "Method not allowed"}, status=405)


@login_required
def history_view(request):
    """
    GET /api/history
    - Users see only their own history.
    - Admins see all users' history.
    """
    if request.method == 'GET':
        if request.user.is_admin:
            records = ImageRecord.objects.all().order_by('-created_at')
        else:
            records = ImageRecord.objects.filter(user=request.user).order_by('-created_at')

        data = [
            {
                "image_id": rec.id,
                "username": rec.user.username if rec.user else "Unknown",
                "summary": rec.summary,
                "model_chosen": rec.model_chosen,
                "crop_name": rec.crop_name,
                "processed_image_url": request.build_absolute_uri(rec.processed_image.url) if rec.processed_image else None,
                "created_at": rec.created_at,
            }
            for rec in records
        ]
        return JsonResponse(data, safe=False, status=200)

    return JsonResponse({"error": "Method not allowed"}, status=405)


def tips_view(request):
    if request.method == 'GET':
        tips = list(Tip.objects.values("crop_name", "crop_tips"))
        return JsonResponse({"tips": tips}, status=200)
    return JsonResponse({"error": "Method not allowed"}, status=405)


def diseases_view(request):
    if request.method == 'GET':
        diseases = list(Disease.objects.values("disease_name", "cure", "commonness"))
        return JsonResponse({"diseases": diseases}, status=200)
    return JsonResponse({"error": "Method not allowed"}, status=405)


def news_view(request):
    if request.method == 'GET':
        news = list(News.objects.values("title", "subtitle", "content", "author_name", "timestamp"))
        return JsonResponse({"news": news}, status=200)
    return JsonResponse({"error": "Method not allowed"}, status=405)
