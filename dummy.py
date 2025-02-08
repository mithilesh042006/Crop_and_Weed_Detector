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
# 2. Base Data (5 items each, more realistic)
# --------------------------
BASE_TIPS = [
    {
        "crop_tips": (
            "Water deeply early in the morning to encourage strong root growth. "
            "Avoid overhead irrigation to reduce fungal risks."
        )
    },
    {
        "crop_tips": (
            "Incorporate well-rotted manure or compost before planting. "
            "This improves soil structure and nutrient content."
        )
    },
    {
        "crop_tips": (
            "Monitor for pests weekly. Use sticky traps or introduce natural predators (e.g., ladybugs) "
            "to keep aphids and other insects under control."
        )
    },
    {
        "crop_tips": (
            "Mulch around seedlings to conserve moisture and suppress weeds. "
            "Refresh the mulch layer as needed for maximum benefit."
        )
    },
    {
        "crop_tips": (
            "Practice crop rotation with legumes to naturally replenish nitrogen in the soil. "
            "Test your soil pH annually and amend accordingly."
        )
    }
]

BASE_DISEASES = [
    {
        "cure": (
            "Remove and burn infected plant debris. Apply copper-based fungicide at the first sign "
            "of infection to halt further spread."
        ),
        "commonness": "high"
    },
    {
        "cure": (
            "Plant disease-resistant varieties and use certified disease-free seeds. "
            "Rotate crops every 2–3 years to break the disease cycle."
        ),
        "commonness": "moderate"
    },
    {
        "cure": (
            "Use biological controls such as Bacillus subtilis. Maintain lower humidity in "
            "greenhouses to deter fungal growth."
        ),
        "commonness": "low"
    },
    {
        "cure": (
            "Apply systemic fungicides as recommended. Prune surrounding vegetation to improve "
            "air circulation and reduce damp conditions."
        ),
        "commonness": "high"
    },
    {
        "cure": (
            "Introduce beneficial nematodes to manage soil pests and reduce infection rates. "
            "Regularly monitor fields for early symptoms."
        ),
        "commonness": "moderate"
    }
]

BASE_NEWS = [
    {
        "subtitle": "Soil Health & Regeneration",
        "content": (
            "Farmers adopting regenerative practices report improved yields and healthier soils, "
            "according to leading agronomists."
        ),
        "author_name": "AgriPulse"
    },
    {
        "subtitle": "Pesticide Regulations",
        "content": (
            "A new policy restricts several chemical pesticides, encouraging farmers to switch "
            "to organic alternatives and safer handling protocols."
        ),
        "author_name": "Farming Daily"
    },
    {
        "subtitle": "Climate-Smart Agriculture",
        "content": (
            "Rising temperatures push the adoption of drought-resistant cultivars and water-saving "
            "technologies, helping farmers cope with erratic weather patterns."
        ),
        "author_name": "Global Ag Forum"
    },
    {
        "subtitle": "Precision Farming Growth",
        "content": (
            "GPS-guided tractors and drone surveillance see a surge in usage, cutting labor costs "
            "and boosting harvest efficiency by up to 20%."
        ),
        "author_name": "TechAg Times"
    },
    {
        "subtitle": "Sustainable Supply Chains",
        "content": (
            "Retailers increasingly demand transparent sourcing, encouraging farmers to document "
            "their practices from seed to sale."
        ),
        "author_name": "EcoMarket Insights"
    }
]

# --------------------------
# 2.1 Crop Image Filenames
# --------------------------
CROP_FILENAMES = [
    "almond.jpg",
    "banana.jpg",
    "cardamom.jpg",
    "cherry.jpg",
    "chilli.jpg",
    "clove.jpg",
    "coconut.jpg",
    "coffee-plant.jpg",
    "cotton.jpg",
    "cucumber.jpg",
    "fox_nut(makhana).jpg",
    "gram.jpg",
    "jowar.jpg",
    "jute.jpg",
    "lemon.jpg",
    "maize.jpg",
    "mustard-oil.jpg",
    "olive-tree.jpg",
    "papaya.jpg",
    "pearl_millet(bajra).jpg",
    "pineapple.jpg",
    "rice.jpg",
    "soyabean.jpg",
    "sugarcane.jpg",
    "sunflower.jpg",
    "tea.jpg",
    "tobacco-plant.jpg",
    "tomato.jpg",
    "vigna-radiati(mung).jpg",
    "wheat.jpg"
]

# --------------------------
# 2.2 Create Tips from Crop Filenames
# --------------------------
def create_tips_for_crops():
    """
    Returns a list of tips where each tip is assigned to one of the 30 crops.
    'crop_name' is derived from the filename by removing '.jpg'.
    """
    tips_data = []
    for crop_image in CROP_FILENAMES:
        crop_name = crop_image.replace(".jpg", "")
        chosen_tip = random.choice(BASE_TIPS)
        tips_data.append({
            "crop_name": crop_name,
            "crop_tips": chosen_tip["crop_tips"]
        })
    return tips_data

# --------------------------
# 2.3 Create 30 Diseases
# --------------------------
def create_30_diseases():
    """
    Returns a list of 30 randomly sampled diseases from the 5 BASE_DISEASES.
    Each will have a unique disease_name like 'Disease1', 'Disease2', etc.
    Now also includes 'crop_name', chosen from the 30 filenames.
    """
    diseases_data = []
    for i in range(1, 31):
        chosen_disease = random.choice(BASE_DISEASES)
        random_crop = random.choice(CROP_FILENAMES)
        crop_name = random_crop.replace(".jpg", "")

        diseases_data.append({
            "disease_name": f"Disease{i}",
            "cure": chosen_disease["cure"],
            "commonness": chosen_disease["commonness"],
            "crop_name": crop_name
        })
    return diseases_data

# --------------------------
# 2.4 Create 30 News Items
# --------------------------
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
      2) Generate tips for each of the 30 crop filenames (removing .jpg)
      3) Also generate 30 diseases (with crop_name) and 30 news items
      4) Send them to the respective endpoints
    """
    session = requests.Session()

    # 1) Admin Login
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

    # 2) Create and Send Tips
    print("\nAdding/Updating tips for the 30 provided crops...")
    tips_data = create_tips_for_crops()
    for tip in tips_data:
        try:
            resp = session.post(ADD_TIP_URL, json=tip)
            resp.raise_for_status()
            print(f"[SUCCESS] {tip['crop_name']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Could not add/update tip for {tip['crop_name']}: {e}")

    # 3) Create and Send Diseases
    print("\nAdding/Updating 30 diseases...")
    diseases_data = create_30_diseases()
    for disease in diseases_data:
        try:
            resp = session.post(ADD_DISEASE_URL, json=disease)
            resp.raise_for_status()
            print(f"[SUCCESS] {disease['disease_name']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Could not add/update disease {disease['disease_name']}: {e}")

    # 4) Create and Send News
    print("\nAdding/Updating 30 news items...")
    news_data = create_30_news_items()
    for news_item in news_data:
        try:
            resp = session.post(ADD_NEWS_URL, json=news_item)
            resp.raise_for_status()
            print(f"[SUCCESS] {news_item['title']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Could not add/update news '{news_item['title']}': {e}")

    print("\nAll done! Check your database to see if the entries were added or updated.")

if __name__ == "__main__":
    main()
