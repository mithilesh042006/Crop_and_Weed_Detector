from django.shortcuts import render
import json
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required, user_passes_test
from .models import CustomUser

def is_admin(user):
    """Check if user is an admin"""
    return user.is_authenticated and user.is_admin

@csrf_exempt
def user_register(request):
    """
    POST /auth/register
    Registers a new user (Admin or Regular User)
    """
    if request.method == 'POST':
        try:
            body = json.loads(request.body.decode('utf-8'))
            username = body.get('username')
            password = body.get('password')
            is_admin = body.get('is_admin', False)

            if CustomUser.objects.filter(username=username).exists():
                return JsonResponse({"error": "Username already exists"}, status=400)

            user = CustomUser.objects.create_user(username=username, password=password, is_admin=is_admin)
            return JsonResponse({"message": "User registered successfully"}, status=201)
        
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    
    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
def user_login(request):
    """
    POST /auth/user_login
    Authenticates a user and returns a session-based login
    """
    if request.method == 'POST':
        try:
            body = json.loads(request.body.decode('utf-8'))
            username = body.get('username')
            password = body.get('password')

            user = authenticate(username=username, password=password)
            if user and not user.is_admin:
                login(request, user)
                return JsonResponse({"message": "User login successful", "is_admin": False}, status=200)
            return JsonResponse({"error": "Invalid user credentials"}, status=401)
        
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)

    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
def admin_login(request):
    """
    POST /auth/admin_login
    Authenticates an admin user and returns a session-based login
    """
    if request.method == 'POST':
        try:
            body = json.loads(request.body.decode('utf-8'))
            username = body.get('username')
            password = body.get('password')

            user = authenticate(username=username, password=password)
            if user and user.is_admin:
                login(request, user)
                return JsonResponse({"message": "Admin login successful", "is_admin": True}, status=200)
            return JsonResponse({"error": "Invalid admin credentials"}, status=401)
        
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)

    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
@login_required
def user_logout(request):
    """
    GET /auth/logout
    Logs out the current user
    """
    logout(request)
    return JsonResponse({"message": "Logout successful"}, status=200)


@login_required
def get_current_user(request):
    """
    GET /auth/me
    Returns information about the currently logged-in user.
    """
    user = request.user
    return JsonResponse({
        "username": user.username,
        "is_admin": user.is_admin,
        "message": "Current user retrieved successfully"
    }, status=200)
