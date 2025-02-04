from django.shortcuts import render
from django.contrib.auth.decorators import login_required, user_passes_test
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import ImageRecord
from .ai_class import AIClass
from admin_dashboard.models import Tip, Disease, News

def is_admin(user):
    return user.is_authenticated and user.is_admin

@csrf_exempt
@login_required
def upload_image(request):
    """
    POST /api/upload
    Accepts image, image ID (optional), and model choice.
    Calls AI logic, stores the record in DB, returns species info.
    """
    if request.method == 'POST':
        image_data = None
        image_id = None

        # Check if request contains JSON or Form-data
        if request.content_type == "application/json":
            try:
                body = json.loads(request.body.decode('utf-8'))
                model_choice = body.get("model")
                image_id = body.get("image_id", None)  # Fix: Extract image_id separately
            except json.JSONDecodeError:
                return JsonResponse({"error": "Invalid JSON format"}, status=400)

        else:
            # Handle form-data request (which includes actual file upload)
            image_data = request.FILES.get("image")
            model_choice = request.POST.get("model")
            image_id = request.POST.get("image_id", None)

        if not image_data:
            return JsonResponse({"error": "No image provided"}, status=400)
        
        elif not model_choice:
            return JsonResponse({"error":"Choose a model"}, status=400)

        # ✅ Fix: Assign the logged-in user to the ImageRecord
        record = ImageRecord.objects.create(
            user=request.user,  # 🔥 Now the image is linked to the user
            image_data=image_data,
            model_chosen=model_choice
        )

        # Call AI processing
        processed_image, crop_name, summary = AIClass.detect_species(
            image_file=image_data, model_choice=model_choice, image_id=record.id
        )

        # Update the record with processed image, crop name, and summary
        record.processed_image = processed_image
        record.crop_name = crop_name
        record.summary = summary
        record.save()

        return JsonResponse({
            "message": "Image processed successfully",
            "image_id": record.id,
            "user_id": request.user.id,  # ✅ Now sending user ID in response
            "model_chosen": model_choice,
            "detected_species": crop_name,
            "summary": summary,
            "processed_image_url": record.processed_image.url
        }, status=200)

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

        # Attempt to delete
        try:
            record = ImageRecord.objects.get(id=image_id)
            record.delete()
            return JsonResponse({"message": f"Image {image_id} deleted successfully"}, status=200)
        except ImageRecord.DoesNotExist:
            return JsonResponse({"error": f"Image {image_id} not found"}, status=404)

    else:
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
            records = ImageRecord.objects.all().order_by('-created_at')  # Admin sees all records
        else:
            records = ImageRecord.objects.filter(user=request.user).order_by('-created_at')  # User sees only their records
        
        data = [
            {
                "image_id": rec.id,
                "username": rec.user.username if rec.user else "Unknown",  # ✅ Add username to response
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
