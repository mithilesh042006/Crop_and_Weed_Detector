import requests
import json
import random

# --------------------------
# 1. Configuration
# --------------------------
BASE_URL = "http://127.0.0.1:8000"   # Update if different
ADMIN_LOGIN_URL = f"{BASE_URL}/auth/admin_login"
ADD_TIP_URL = f"{BASE_URL}/admin_dashboard/add_tip"
ADD_DISEASE_URL = f"{BASE_URL}/admin_dashboard/add_disease"
ADD_NEWS_URL = f"{BASE_URL}/admin_dashboard/add_news"

# Admin credentials
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "adminpass"

# --------------------------
# 2. Base Data (5 items each)
# --------------------------
BASE_TIPS = [
    {"crop_tips": "Water regularly and maintain good soil drainage."},
    {"crop_tips": "Apply organic fertilizers and keep pests in check early."},
    {"crop_tips": "Monitor sun exposure and provide shade if temperatures soar."},
    {"crop_tips": "Rotate crops yearly to prevent soil depletion."},
    {"crop_tips": "Test soil pH before planting and adjust with lime or sulfur."}
]

BASE_DISEASES = [
    {
        "cure": "Prune infected leaves, apply copper-based fungicide.",
        "commonness": "high"
    },
    {
        "cure": "Use disease-resistant seeds and practice crop rotation.",
        "commonness": "moderate"
    },
    {
        "cure": "Early detection is key; remove diseased plants immediately.",
        "commonness": "low"
    },
    {
        "cure": "Employ a balanced fertilization plan and maintain optimum humidity.",
        "commonness": "high"
    },
    {
        "cure": "Use recommended bio-pesticides to keep the pathogen in check.",
        "commonness": "moderate"
    }
]

BASE_NEWS = [
    {
        "subtitle": "Agriculture Tech Innovations",
        "content": "Drones and sensors help in real-time crop monitoring and yield prediction.",
        "author_name": "AgroTech Report"
    },
    {
        "subtitle": "Weather Challenges",
        "content": "Unexpected rains cause a delay in harvest; farmers adapt irrigation schedules.",
        "author_name": "SkyWatch News"
    },
    {
        "subtitle": "Organic Movement",
        "content": "Rising consumer demand for pesticide-free produce influences market dynamics.",
        "author_name": "Farm2Table Weekly"
    },
    {
        "subtitle": "Policy Updates",
        "content": "New subsidy schemes announced for small-scale farmers across multiple states.",
        "author_name": "RuralGov"
    },
    {
        "subtitle": "Sustainable Practices",
        "content": "Soil health and regenerative agriculture approaches are gaining momentum globally.",
        "author_name": "Green Horizon"
    }
]


def create_30_tips():
    """
    Returns a list of 30 randomly sampled tips from the 5 BASE_TIPS.
    Each will have a unique crop_name like 'Crop1', 'Crop2', etc.
    """
    tips_data = []
    for i in range(1, 31):
        chosen_tip = random.choice(BASE_TIPS)
        tips_data.append({
            "crop_name": f"Crop{i}",
            "crop_tips": chosen_tip["crop_tips"]
        })
    return tips_data


def create_30_diseases():
    """
    Returns a list of 30 randomly sampled diseases from the 5 BASE_DISEASES.
    Each will have a unique disease_name like 'Disease1', 'Disease2', etc.
    """
    diseases_data = []
    for i in range(1, 31):
        chosen_disease = random.choice(BASE_DISEASES)
        diseases_data.append({
            "disease_name": f"Disease{i}",
            "cure": chosen_disease["cure"],
            "commonness": chosen_disease["commonness"]
        })
    return diseases_data


def create_30_news_items():
    """
    Returns a list of 30 randomly sampled news items from the 5 BASE_NEWS.
    Each will have a unique title like 'News1', 'News2', etc.
    """
    news_data = []
    for i in range(1, 31):
        chosen_news = random.choice(BASE_NEWS)
        news_data.append({
            "title": f"News{i}",
            "subtitle": chosen_news["subtitle"],
            "content": chosen_news["content"],
            "author_name": chosen_news["author_name"]
        })
    return news_data


def main():
    """
    Main function to:
      1) Log in as Admin
      2) Generate 30 tips, 30 diseases, and 30 news items (randomly from base data)
      3) Send them to the respective endpoints
    """
    # --------------------------
    # 3. Create a Session object
    # --------------------------
    session = requests.Session()

    # --------------------------
    # 4. Admin Login
    # --------------------------
    print("Attempting admin login...")
    login_payload = {
        "username": ADMIN_USERNAME,
        "password": ADMIN_PASSWORD
    }

    try:
        login_response = session.post(ADMIN_LOGIN_URL, json=login_payload)
        login_response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Failed to reach login endpoint: {e}")
        return

    if login_response.status_code == 200:
        data = login_response.json()
        if data.get("is_admin") is True:
            sessionid = data.get("sessionid")
            csrftoken = data.get("csrftoken")
            print("[SUCCESS] Admin login successful.")

            # IMPORTANT: Remove domain=None to avoid the AttributeError
            if sessionid:
                session.cookies.set("sessionid", sessionid)  # No domain argument
            if csrftoken:
                session.headers.update({"X-CSRFToken": csrftoken})
        else:
            print("[ERROR] Not an admin account or something went wrong.")
            return
    else:
        print(f"[ERROR] Admin login failed. Status code: {login_response.status_code}")
        print(login_response.text)
        return

    # --------------------------
    # 5. Create and Send 30 Tips
    # --------------------------
    print("\nAdding/Updating 30 tips...")
    tips_data = create_30_tips()
    for tip in tips_data:
        try:
            resp = session.post(ADD_TIP_URL, json=tip)
            resp.raise_for_status()
            print(f"[SUCCESS] {tip['crop_name']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Could not add/update tip for {tip['crop_name']}: {e}")

    # --------------------------
    # 6. Create and Send 30 Diseases
    # --------------------------
    print("\nAdding/Updating 30 diseases...")
    diseases_data = create_30_diseases()
    for disease in diseases_data:
        try:
            resp = session.post(ADD_DISEASE_URL, json=disease)
            resp.raise_for_status()
            print(f"[SUCCESS] {disease['disease_name']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Could not add/update disease {disease['disease_name']}: {e}")

    # --------------------------
    # 7. Create and Send 30 News
    # --------------------------
    print("\nAdding/Updating 30 news items...")
    news_data = create_30_news_items()
    for news_item in news_data:
        try:
            resp = session.post(ADD_NEWS_URL, json=news_item)
            resp.raise_for_status()
            print(f"[SUCCESS] {news_item['title']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Could not add/update news '{news_item['title']}': {e}")

    print("\nAll done! Check your database to see if the 30 entries per category were added or updated.")


if __name__ == "__main__":
    main()
