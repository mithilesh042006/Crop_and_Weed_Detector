# -*- coding: utf-8 -*-
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
            "સવારે ઉંડું પાણી આપો જેથી મૂળોને મજબૂત વૃદ્ધિ માટે પ્રોત્સાહિત કરી શકાય. "
            "ફૂગ સંક્રમણનું જોખમ ઘટાડવા માટે ઓવરહેડ સિંચાઈ ટાળો."
        )
    },
    {
        "crop_tips": (
            "રોપણી કરતાં પહેલા સારી રીતે સડી ગયેલું ખાતર અથવા કમ્પોસ્ટ ઉમેરો. "
            "આથી માટીની રચના તથા પોષક તત્ત્વોમાં સુધાર થાય છે."
        )
    },
    {
        "crop_tips": (
            "દર અઠવાડિયે જીવાતો માટે નજર રાખો. ચાંદલાપટ્ટીઓ (sticky traps) વાપરો "
            "અથવા કુદરતી શત્રુઓ (જેમ કે લેડીબગ્સ) રજૂ કરો જેથી સફેદમાખી "
            "વગેરે પર નિયંત્રણ રાખી શકાય."
        )
    },
    {
        "crop_tips": (
            "મૂળ ચારો સાચવવા માટે તથા જ્યાં સુધી હરિયાળો દૂધ કે વાવણી માટે ઓળખાણ "
            "હાંસલ કરવામાં આવે. Mulch વાપરો, જેથી વધારાના ગુણ મળી રહે તથા "
            "નિયંત્રણ કરવામાં પણ મદદ મળે."
        )
    },
    {
        "crop_tips": (
            "દાગીના આધારિત પાક પર્યાવરણ ઊભું કરવામાં કુદરતી રીતે નિટ્રોજન "
            "પુનઃપૂર્તિ માટે લીლა ફલીઓવાળા પાક (લેગયુમ્સ) સાથે ફસલ ફેરવણી કરો. "
            "માટીનું pH દર વર્ષે તપાસો અને જરૂરી સુધારાઓ કરો."
        )
    }
]

BASE_DISEASES = [
    {
        "cure": (
            "દૂષિત છોડના અવશેષોને દૂર કરો અને અગ્નિમાં બાળી દો. "
            "સંક્રમણની પ્રથમ નિશાનીમાં તાંબા આધારિત ફૂગનાશક લગાવો "
            "જેથી વધુ ફેલાવો અટકી શકે."
        ),
        "commonness": "ઉચ્ચ"
    },
    {
        "cure": (
            "રોગપ્રતિકારક જાતો વાવો तथा પ્રમાણિત સ્વચ્છ બીજો નો ઉપયોગ કરો. "
            "રોગચક્રમાં વિક્ષેપ આવેએ માટે 2–3 વર્ષે એકવાર પાક ફેરવણી કરો."
        ),
        "commonness": "મધ્યમ"
    },
    {
        "cure": (
            "જીવાવિશેષ-નિયંત્રણ (Biological control) માટે Bacillus subtilis નો ઉપયોગ કરો. "
            "ફૂગને રોકવા માટે ગ્રીનહાઉસમાં સૌથી ઓછી ભેજ રાખવાની કોશિશ કરો."
        ),
        "commonness": "નગણ્ય"
    },
    {
        "cure": (
            "જાહેર દિશા અનુસાર systemic fungicides લગાવો. "
            "આસપાસની વધારાનીેષણશાખાઓ/Buttonholes)"
            "વીઝ ફૂગ અપેક્ષિત."
        )
    },
    {
        "cure": (
            "માટીજયાં જીવાતોને નિયંત્રિત કરવા માટે ಲાભદાયક nematodes રજૂ કરો "
            "અને સંક્રમણમાં ઘટાડો કરો. "
            "રોગની પ્રથમ লক্ষણો માટે નિયમિતરીતે ખેતરો તપાસો."
        ),
        "commonness": "મધ્યમ"
    }
]

BASE_NEWS = [
    {
        "subtitle": "માટી સ્વાસ્થ્ય & પુનઃજીવન",
        "content": (
            "પુનઃજીવિત ખેતી પદ્ધતિઓ અનુસરતા ખેડૂતોએ વધુ ઉપજ "
            "અને વધુ સારી માટી સ્થિતિ હોવાનું જણાવ્યું છે, આવું અગ્રણી કૃષિશાસ્ત્રીઓ કહે છે."
        ),
        "author_name": "AgriPulse"
    },
    {
        "subtitle": "ખેતીમાં રસાયણોના નિયમન",
        "content": (
            "નવી નીતિ કેટલાક রাসાયણિક pesticide પર પ્રતિબંધ મૂકે છે, "
            "જે ખેડુતોને ორგანિક વિકલ્પો તરફ વળવા માટે પ્રોત્સાહિત કરે છે."
        ),
        "author_name": "Farming Daily"
    },
    {
        "subtitle": "ક્લાઈમેટ-સ્માર્ટ ખેતી",
        "content": (
            "ઉચ્ચ તાપમાનમાં વધી રહેલા ચેતા વચ્ચે તેેલું-ઓછું પાણી ખર્ચતી "
            "નવાં જાતો (cultivars) અપનાવવા પર ભાર આપવામાં આવે છે, "
            "જે અસ્થિર વાતાવરણમાં પણ ખેતીમાં સહાયક છે."
        ),
        "author_name": "Global Ag Forum"
    },
    {
        "subtitle": "સુક્ષ્મખેતી (Precision Farming) ની વૃદ્ધિ",
        "content": (
            "GPS-સુચિત ટ્રેકટર તથા ડ્રોન દ્વારા સર્વેક્ષણમાં વધારો જોવા મળે છે, "
            "જે કારણે કામદારોનો ખર્ચ ઘટે છે તથા 20% સુધી ઉપજમાં વધારો થાય છે."
        ),
        "author_name": "TechAg Times"
    },
    {
        "subtitle": "સસ્ટેઇનેબલ સપ્લાય ચેઇન્સ",
        "content": (
            "રિટેલરો ઉત્પાદન વિશે વધુ પારદર્શક માહિતી માંગે છે, "
            "જે ખેડૂતોને બીજથી માંડી વેચાણ સુધીની પ્રવૃત્તિઓનું દસ્તાવેજીકરણ રાખવા માટે ಉತ್ತેજિત કરે છે."
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
    30 ફસાયોને અનુરૂપ કરીને ટિપ્સ બનાવે છે, જ્યાં crop_name ફાઇલનામમાંથી મેળવવામાં આવે છે.
    'crop_name' એ '.jpg' દૂર કરીને રહેશે.
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
    5 ધ્રુજતા BASE_DISEASES માંથી 30 અનિયમિક (random) diseases પરત આપે છે.
    દરેક ziekte માટે નામ 'Disease1', 'Disease2', ... જેવું unieke હશે.
   _crop_name' પણ 30 ફાઈલનામમાંથી એકાર્ણે પસંદ કરવામાં આવશે.
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
    5 BASE_NEWS માંથી 30 અનિયમિક (random) news items પરત આપે છે.
    દરેક news માટે 'News1', 'News2', ... જેવું unique title હશે.
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
    મુખ્ય કાર્ય:
      1) એડમિન તરીકે લોગિન કરો
      2) 30 જેટલી પાક ફાઈલનામ ('.jpg' વિना) માટે ટિપ્સ બનાવો
      3) 30 બીમારીઓ (crop_name সহ) તથા 30 સમાચાર ELB
      4) സ്വന്തം એન્ડપોઈન્ટ્સ પર JSON મોકલો
    """
    session = requests.Session()

    # 1) Admin Login
    print("એડમિન લોગિન કરવાની કોશિશ કરી રહ્યા છીએ...")
    login_payload = {
        "username": ADMIN_USERNAME,
        "password": ADMIN_PASSWORD
    }

    try:
        login_response = session.post(ADMIN_LOGIN_URL, json=login_payload)
        login_response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"[ભૂલ] લોગિન એન્ડપોઈન્ટ સુધી પહોંચી શકાયું નથી: {e}")
        return

    if login_response.status_code == 200:
        data = login_response.json()
        if data.get("is_admin") is True:
            sessionid = data.get("sessionid")
            csrftoken = data.get("csrftoken")
            print("[સફળતા] એડમિન લોગિન સફળ.")

            if sessionid:
                session.cookies.set("sessionid", sessionid)  # No domain argument
            if csrftoken:
                session.headers.update({"X-CSRFToken": csrftoken})
        else:
            print("[ભૂલ] કદાચ એડમિન એકાઉન્ટ નથી કે અન્ય કોઈ સમસ્યા છે.")
            return
    else:
        print(f"[ભૂલ] એડમિન લોગિન નિષ્ફળ. સ્તેટ્સ કોડ: {login_response.status_code}")
        print(login_response.text)
        return

    # 2) Create and Send Tips
    print("\n30 પાક માટેની ટિપ્સ ઉમેરવાની/અપડેટ કરવાની પ્રક્રિયા...")
    tips_data = create_tips_for_crops()
    for tip in tips_data:
        try:
            resp = session.post(ADD_TIP_URL, json=tip)
            resp.raise_for_status()
            print(f"[સફળતા] {tip['crop_name']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ભૂલ] {tip['crop_name']} માટે ટિપ્સ ઉમેરવી/અપડેટ કરવામાં પરાજય: {e}")

    # 3) Create and Send Diseases
    print("\n30 بیماری ઉમેરવાની/અપડેટ કરવાની પ્રક્રિયા...")
    diseases_data = create_30_diseases()
    for disease in diseases_data:
        try:
            resp = session.post(ADD_DISEASE_URL, json=disease)
            resp.raise_for_status()
            print(f"[સફળતા] {disease['disease_name']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ભૂલ] {disease['disease_name']} માટે નો દસ્તાવેજ ઉમેરવામાં/અપડેટ કરવામાં પરાજય: {e}")

    # 4) Create and Send News
    print("\n30 સમાચાર ઉમેરવાની/અપડેટ કરવાની પ્રક્રિયા...")
    news_data = create_30_news_items()
    for news_item in news_data:
        try:
            resp = session.post(ADD_NEWS_URL, json=news_item)
            resp.raise_for_status()
            print(f"[સફળતા] {news_item['title']}: {resp.json().get('message')}")
        except requests.exceptions.RequestException as e:
            print(f"[ભૂલ] સમાચાર '{news_item['title']}' ઉમેરવામાં/અપડેટ કરવામાં પરાજય: {e}")

    print("\nકાર્ય પૂર્ણ! તમારી ડેટાબેિસ તપાસીને ખાતરી કરો કે નવી એન્ટ્રીઓ ઉમેરવામાં આવી છે કે નહીં.")

if __name__ == "__main__":
    main()
