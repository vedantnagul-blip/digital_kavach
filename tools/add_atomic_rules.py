import json
import re

with open('assets/rules.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

rules = data['rules']
existing_ids = set(r['id'] for r in rules)

atomic_rules = [
    # Work From Home / Task Scams
    {
        "id": "r_wfh_part_time_job",
        "family": "investment_group",
        "type": "regex",
        "pattern": "\\b(part-time|online)\\s*(vacanc|job|work|opportunity)\\b",
        "flags": "i",
        "weight": 40,
        "localizedHint": {
            "en": "Part-time online job vacancy lure detected",
            "hi": "पार्ट-टाइम ऑनलाइन नौकरी का झांसा",
            "mr": "पार्ट-टाईम ऑनलाइन नोकरीचे आमिष"
        },
        "description": "Part-time job vacancy phrasing"
    },
    {
        "id": "r_wfh_daily_earnings",
        "family": "investment_group",
        "type": "regex",
        "pattern": "\\b(earn|salary|income)\\b.{0,30}(rs\\.?|₹|inr)\\s*[0-9,]+.{0,25}\\b(daily|per\\s*day|रोज|दररोज)\\b",
        "flags": "i",
        "weight": 55,
        "localizedHint": {
            "en": "Unrealistic daily earnings promise (Rs 2,500 - 8,000/day)",
            "hi": "रोजाना ₹2,500-₹8,000 कमाने का अवास्तविक वादा",
            "mr": "दररोज ₹२,५००-₹८,००० मिळण्याचे बनावट आश्वासन"
        },
        "description": "Daily income earnings promise"
    },
    {
        "id": "r_wfh_video_like_maps_rate",
        "family": "investment_group",
        "type": "regex",
        "pattern": "(liking|watching)\\s*(videos?|reels?|youtube)|(rating|reviewing)\\s*(hotels?|google\\s*maps?|amazon|places)",
        "flags": "i",
        "weight": 60,
        "localizedHint": {
            "en": "Micro-task scam: Paid for liking YouTube videos or rating Google Maps",
            "hi": "माइक्रो-टास्क स्कैम: वीडियो लाइक या गूगल मैप्स रेटिंग के बदले पैसे",
            "mr": "मायक्रो-टास्क फसवणूक: व्हिडिओ लाईक किंवा हॉटेल रेटिंगचे आमिष"
        },
        "description": "Paid video liking / Google Maps review rating microtasks"
    },
    {
        "id": "r_wfh_telegram_hr_recruiter",
        "family": "investment_group",
        "type": "regex",
        "pattern": "(hr\\s*manager|recruiter|contact\\s*hr|priya|neha|anjali).{0,30}(telegram|whatsapp|t\\.me|wa\\.me)",
        "flags": "i",
        "weight": 55,
        "localizedHint": {
            "en": "Fake HR manager redirecting victim to Telegram/WhatsApp",
            "hi": "टेलीग्राम/व्हाट्सएप पर संपर्क कराने वाली फर्जी एचआर भर्ती",
            "mr": "टेलिग्राम/व्हॉट्सअ‍ॅपवर संपर्क साधण्यास सांगणारी बनावट एचआर"
        },
        "description": "Recruiter pushing victim to Telegram / WhatsApp"
    },
    {
        "id": "r_wfh_telegram_link",
        "family": "phishing_link",
        "type": "regex",
        "pattern": "https?://t\\.me/[a-zA-Z0-9_+]+",
        "flags": "i",
        "weight": 40,
        "localizedHint": {
            "en": "Telegram recruitment / task group link detected",
            "hi": "टेलीग्राम ग्रुप का आमंत्रण लिंक",
            "mr": "टेलिग्राम ग्रुपची निमंत्रण लिंक"
        },
        "description": "Telegram channel or contact link"
    },
    {
        "id": "r_wfh_no_experience_short_time",
        "family": "investment_group",
        "type": "regex",
        "pattern": "(no\\s*(prior\\s*)?experience|15-20\\s*minutes|10-15\\s*mins).{0,30}(daily|required|needed)",
        "flags": "i",
        "weight": 35,
        "localizedHint": {
            "en": "Low-effort high-reward trap ('15-20 mins daily, no experience')",
            "hi": "कम समय में भारी कमाई का लालच ('15-20 मिनट रोज़')",
            "mr": "कमी वेळेत जास्त कमाईचे आमिष ('रोज १५-२० मिनिटे')"
        },
        "description": "Low effort lure phrasing"
    },
    # Direct APK link
    {
        "id": "r_url_direct_apk_payload",
        "family": "phishing_link",
        "type": "regex",
        "pattern": "https?://[^\\s]+\\.apk(\\?[^\\s]*)?",
        "flags": "i",
        "weight": 70,
        "localizedHint": {
            "en": "Direct malicious Android APK download link",
            "hi": "सीधे वायरस एपीके डाउनलोड कराने वाली लिंक",
            "mr": "थेट व्हायरस एपीके डाऊनलोड करणारी लिंक"
        },
        "description": "Direct APK download link"
    },
    # WhatsApp deep link
    {
        "id": "r_url_whatsapp_wa_me",
        "family": "phishing_link",
        "type": "regex",
        "pattern": "https?://wa\\.me/[0-9]+",
        "flags": "i",
        "weight": 35,
        "localizedHint": {
            "en": "Direct WhatsApp messaging link",
            "hi": "सीधे व्हाट्सएप चैट शुरू करने की लिंक",
            "mr": "थेट व्हॉट्सअ‍ॅप चॅट सुरू करणारी लिंक"
        },
        "description": "wa.me link"
    },
    # Electricity disconnection specific
    {
        "id": "r_elec_tonight_cutoff",
        "family": "fake_kyc",
        "type": "regex",
        "pattern": "(tonight|today|आज\\s*रात|आज\\s*रात्री).{0,25}(at\\s*)?(9:30|8:30|10:00|10:30|9:00|11:00)\\s*(pm|वाजता|बजे)",
        "flags": "i",
        "weight": 60,
        "localizedHint": {
            "en": "Urgent utility cutoff time threat (Tonight at 9:30 PM)",
            "hi": "आज रात 9:30 बजे बिजली काटने की धमकी",
            "mr": "आज रात्री ९:३० वाजता वीज कापण्याची धमकी"
        },
        "description": "Tonight cutoff time pressure"
    },
    # Digital arrest specific
    {
        "id": "r_da_parcel_drugs_airport",
        "family": "digital_arrest",
        "type": "regex",
        "pattern": "(parcel|package|courier).{0,30}(customs|airport|mumbai|delhi).{0,30}(mdma|drugs|narcotics|passports)",
        "flags": "i",
        "weight": 70,
        "localizedHint": {
            "en": "Customs airport contraband parcel accusation (Digital Arrest)",
            "hi": "कस्टम्स एयरपोर्ट पार्सल में ड्रग्स मिलने का झूठा आरोप",
            "mr": "कस्टम्स एअरपोर्ट पार्सलमध्ये अंमली पदार्थ सापडल्याचा खोटा आरोप"
        },
        "description": "Airport parcel narcotics accusation"
    }
]

for r in atomic_rules:
    if r['id'] not in existing_ids:
        rules.append(r)
        existing_ids.add(r['id'])
    else:
        # Update pattern
        for idx, orig in enumerate(rules):
            if orig['id'] == r['id']:
                rules[idx] = r

data['rules'] = rules
with open('assets/rules.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Total rules in rules.json: {len(rules)}")
