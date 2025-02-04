from django.contrib.auth.decorators import login_required, user_passes_test
from django.shortcuts import render
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Tip, Disease, News

# ✅ Check if User is Admin
def is_admin(user):
    return user.is_authenticated and user.is_admin

# -------------------------------------
# ✅ CROP TIPS (ADD, UPDATE, DELETE)
# -------------------------------------
@csrf_exempt
@login_required
@user_passes_test(is_admin)
def add_or_update_tip(request):
    """ POST /admin_dashboard/add_tip """
    if request.method == 'POST':
        try:
            body = json.loads(request.body.decode('utf-8'))
            crop_name = body.get('crop_name')
            crop_tips = body.get('crop_tips')

            tip, created = Tip.objects.update_or_create(
                crop_name=crop_name, defaults={"crop_tips": crop_tips}
            )

            return JsonResponse({"message": "Tip added/updated successfully"}, status=200)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
@login_required
@user_passes_test(is_admin)
def delete_tip(request):
    """ DELETE /admin_dashboard/delete_tip """
    if request.method == 'DELETE':
        try:
            body = json.loads(request.body.decode('utf-8'))
            crop_name = body.get('crop_name')

            try:
                tip = Tip.objects.get(crop_name=crop_name)
                tip.delete()
                return JsonResponse({"message": f"Tip for {crop_name} deleted successfully"}, status=200)
            except Tip.DoesNotExist:
                return JsonResponse({"error": "Tip not found"}, status=404)

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    return JsonResponse({"error": "Method not allowed"}, status=405)

# -------------------------------------
# ✅ DISEASES (ADD, UPDATE, DELETE)
# -------------------------------------
@csrf_exempt
@login_required
@user_passes_test(is_admin)
def add_or_update_disease(request):
    """ POST /admin_dashboard/add_disease """
    if request.method == 'POST':
        try:
            body = json.loads(request.body.decode('utf-8'))
            disease_name = body.get('disease_name')
            cure = body.get('cure')
            commonness = body.get('commonness', '')

            disease, created = Disease.objects.update_or_create(
                disease_name=disease_name, defaults={"cure": cure, "commonness": commonness}
            )

            return JsonResponse({"message": "Disease added/updated successfully"}, status=200)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
@login_required
@user_passes_test(is_admin)
def delete_disease(request):
    """ DELETE /admin_dashboard/delete_disease """
    if request.method == 'DELETE':
        try:
            body = json.loads(request.body.decode('utf-8'))
            disease_name = body.get('disease_name')

            try:
                disease = Disease.objects.get(disease_name=disease_name)
                disease.delete()
                return JsonResponse({"message": f"Disease {disease_name} deleted successfully"}, status=200)
            except Disease.DoesNotExist:
                return JsonResponse({"error": "Disease not found"}, status=404)

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    return JsonResponse({"error": "Method not allowed"}, status=405)

# -------------------------------------
# ✅ NEWS (ADD, UPDATE, DELETE)
# -------------------------------------
@csrf_exempt
@login_required
@user_passes_test(is_admin)
def add_or_update_news(request):
    """ POST /admin_dashboard/add_news """
    if request.method == 'POST':
        try:
            body = json.loads(request.body.decode('utf-8'))
            title = body.get('title')
            subtitle = body.get('subtitle', '')
            content = body.get('content')
            author_name = body.get('author_name')

            news, created = News.objects.update_or_create(
                title=title, defaults={"subtitle": subtitle, "content": content, "author_name": author_name}
            )

            return JsonResponse({"message": "News added/updated successfully"}, status=201)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
@login_required
@user_passes_test(is_admin)
def delete_news(request):
    """ DELETE /admin_dashboard/delete_news """
    if request.method == 'DELETE':
        try:
            body = json.loads(request.body.decode('utf-8'))
            title = body.get('title')

            try:
                news = News.objects.get(title=title)
                news.delete()
                return JsonResponse({"message": f"News '{title}' deleted successfully"}, status=200)
            except News.DoesNotExist:
                return JsonResponse({"error": "News not found"}, status=404)

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    return JsonResponse({"error": "Method not allowed"}, status=405)
