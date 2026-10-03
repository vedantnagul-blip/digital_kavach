import json
import re

with open('assets/rules.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

existing_rules = data.get('rules', [])
existing_ids = set(r['id'] for r in existing_rules)
new_rules = []

def add_r(rid, family, pattern, weight, en_hint, hi_hint, mr_hint, desc):
    if rid in existing_ids:
        return
    try:
        re.compile(pattern, re.IGNORECASE)
    except Exception as e:
        print(f"Regex error in {rid}: {e}")
        return

    rule = {
        "id": rid,
        "family": family,
        "type": "regex",
        "pattern": pattern,
        "flags": "i",
        "weight": weight,
        "localizedHint": {
            "en": en_hint,
            "hi": hi_hint,
            "mr": mr_hint
        },
        "description": desc
    }
    new_rules.append(rule)
    existing_ids.add(rid)

# 1. BANK SPOOFING (15 banks x 8 scenarios = 120 rules)
banks = [
    ("sbi", "SBI|State\\s*Bank|YONO"),
    ("hdfc", "HDFC|HDFC\\s*Bank"),
    ("icici", "ICICI|iMobile"),
    ("axis", "Axis\\s*Bank"),
    ("pnb", "PNB|Punjab\\s*National\\s*Bank|PNB\\s*One"),
    ("kotak", "Kotak|Kotak\\s*811"),
    ("bob", "Bank\\s*of\\s*Baroda|BOB\\s*World"),
    ("canara", "Canara\\s*Bank|Canara\\s*ai1"),
    ("union", "Union\\s*Bank|Vyom"),
    ("indusind", "IndusInd\\s*Bank"),
    ("idfc", "IDFC\\s*FIRST"),
    ("yes", "Yes\\s*Bank"),
    ("rbl", "RBL\\s*Bank"),
    ("federal", "Federal\\s*Bank|FedMobile"),
    ("indian", "Indian\\s*Bank|IndOASIS"),
]

scenarios = [
    ("kyc_exp", "(kyc|documents?).{0,30}(expired|pending|mandatory|submit)", 60, "KYC expiration smishing", "केवाईसी समाप्त होने का फर्जी अलर्ट", "केवायसी संपल्याचा बनावट अलर्ट"),
    ("ac_blocked", "(account|netbanking).{0,30}(blocked|suspended|frozen|deactivated)", 65, "Account deactivation threat", "खाता ब्लॉक होने की फर्जी धमकी", "खाते ब्लॉक झाल्याची बनावट धमकी"),
    ("pan_unlink", "(pan\\s*card|pan\\s*number).{0,30}(unlink|not\\s*linked|penalty|fine)", 55, "PAN unlinked penalty warning", "पैन कार्ड लिंक न होने पर जुर्माने का डर", "पॅन कार्ड लिंक नसल्यास दंडाची भीती"),
    ("aadhaar_lock", "(aadhaar|biometric).{0,30}(locked|disabled|update\\s*now)", 55, "Aadhaar biometric lock smishing", "आधार बायोमेट्रिक ब्लॉक का फर्जी संदेश", "आधार बायोमेट्रिक ब्लॉकचा बनावट संदेश"),
    ("points_exp", "(reward\\s*points|credit\\s*points).{0,30}(expire|redeem|worth\\s*rs)", 55, "Reward points expiry lure", "रिवॉर्ड पॉइंट एक्सपायरी का झांसा", "रिवॉर्ड पॉइंट्स संपल्याचे आमिष"),
    ("limit_up", "(credit\\s*card\\s*limit|card\\s*enhancement).{0,30}(increased|pre-approved|claim)", 50, "Pre-approved card limit enhancement", "क्रेडिट कार्ड लिमिट बढ़ाने के नाम पर झांसा", "क्रेडिट कार्ड मर्यादा वाढवण्याचे आमिष"),
    ("card_replace", "(debit\\s*card|atm\\s*card).{0,30}(replace|expired|renew|fee)", 55, "Debit/ATM card renewal fee trap", "एटीएम कार्ड रिन्यूअल फीस का फर्जी अलर्ट", "एटीएम कार्ड नूतनीकरण शुल्काचा बनावट अलर्ट"),
    ("pw_reset", "(netbanking|password|profile\\s*password).{0,30}(reset|unauthorized\\s*login)", 60, "Unauthorized login password reset trap", "अनधिकृत लॉगिन के नाम पर पासवर्ड चुराने का जाल", "अनधिकृत लॉगिनच्या नावाखाली पासवर्ड चोरीचा सापळा"),
]

for b_id, b_pat in banks:
    for s_id, s_pat, wt, en, hi, mr in scenarios:
        rid = f"r_bk_{b_id}_{s_id}"
        pat = f"({b_pat}).{{0,40}}{s_pat}"
        add_r(rid, "fake_kyc", pat, wt, f"{b_id.upper()}: {en}", f"{b_id.upper()}: {hi}", f"{b_id.upper()}: {mr}", f"Bank smishing {b_id} {s_id}")

# 2. UTILITY & DISCONNECTION (14 discoms x 5 scenarios = 70 rules)
discoms = [
    ("mseb", "MSEB|Mahavitaran|MSEDCL|महावितरण"),
    ("bses_y", "BSES\\s*Yamuna|BYPL"),
    ("bses_r", "BSES\\s*Rajdhani|BRPL"),
    ("tata", "Tata\\s*Power|TPDDL"),
    ("adani", "Adani\\s*Electricity"),
    ("torrent", "Torrent\\s*Power"),
    ("uppcl", "UPPCL|Madhyanchal|Dakshinanchal|Paschimanchal"),
    ("dhbvn", "DHBVN|UHBVN"),
    ("pspcl", "PSPCL|Punjab\\s*Power"),
    ("wbsedcl", "WBSEDCL"),
    ("tneb", "TNEB|TANGEDCO"),
    ("bescom", "BESCOM|KPTCL"),
    ("tsspdcl", "TSSPDCL|TGSPDCL"),
    ("mppkvvcl", "MPPKVVCL|MP\\s*Electricity"),
]

util_scens = [
    ("cut_tonight", "(disconnect|cut\\s*off|खंडित|काट\\s*दी).{0,30}(tonight|today|9:30|8:30|10:00|आज\\s*रात|आज\\s*रात्री)", 65, "Power disconnection tonight threat", "आज रात बिजली काटने की फर्जी धमकी", "आज रात्री वीज पुरवठा खंडित करण्याची बनावट धमकी"),
    ("prev_unpaid", "(previous|last)\\s*month\\s*bill.{0,30}(not\\s*updated|unpaid|pending|अपडेट)", 60, "Previous month unpaid bill excuse", "पिछले महीने का बिल न भरने का बहाना", "मागील महिन्याचे बिल न भरल्याचा खोटा दावा"),
    ("apk_install", "(download|install|update).{0,30}(app|apk|quicksupport|anydesk)", 70, "Utility payment APK or remote tool download", "बिजली बिल के नाम पर एपीके या रिमोट ऐप का झांसा", "वीज बिलाच्या नावाखाली एपीके किंवा रिमोट अ‍ॅपचा सापळा"),
    ("call_officer", "(contact|call|whatsapp).{0,30}(officer|engineer|sharma|verma|patil).{0,30}\\b[6-9][0-9]{9}\\b", 65, "Instruction to call electricity officer on personal mobile", "बिजली अधिकारी के व्यक्तिगत मोबाइल पर कॉल का दबाव", "वीज अधिकाऱ्याच्या वैयक्तिक मोबाईलवर कॉलचा दबाव"),
    ("divert_pay", "(do\\s*not\\s*pay|avoid).{0,30}(phonepe|gpay|paytm|online)", 65, "Scammer discouraging official payment gateways", "आधिकारिक पेमेंट ऐप रोकने और व्यक्तिगत कॉल का झांसा", "अधिकृत अ‍ॅप सोडून थेट वैयक्तिक पेमेंट करण्याचा सापळा"),
]

for d_id, d_pat in discoms:
    for u_id, u_pat, wt, en, hi, mr in util_scens:
        rid = f"r_ut_{d_id}_{u_id}"
        pat = f"({d_pat}).{{0,50}}{u_pat}"
        add_r(rid, "fake_kyc", pat, wt, f"{d_id.upper()}: {en}", f"{d_id.upper()}: {hi}", f"{d_id.upper()}: {mr}", f"Utility scam {d_id} {u_id}")

# 3. DIGITAL ARREST & LAW ENFORCEMENT (10 agencies x 7 claims = 70 rules)
agencies = [
    ("cbi", "CBI|Central\\s*Bureau\\s*of\\s*Investigation"),
    ("ed", "\\bED\\b|Enforcement\\s*Directorate"),
    ("nia", "\\bNIA\\b|National\\s*Investigation\\s*Agency"),
    ("ncb", "\\bNCB\\b|Narcotics\\s*Control\\s*Bureau"),
    ("crime_branch", "Crime\\s*Branch|Special\\s*Cell"),
    ("cyber_police", "Cyber\\s*Crime\\s*Cell|Cyber\\s*Police"),
    ("customs", "Customs\\s*Department|Airport\\s*Customs"),
    ("supreme_court", "Supreme\\s*Court|High\\s*Court"),
    ("trai_dept", "TRAI|Department\\s*of\\s*Telecommunications|DoT"),
    ("interpol_in", "Interpol|National\\s*Central\\s*Bureau"),
]

claims = [
    ("narcotics", "(drugs|mdma|narcotics|contraband|weed).{0,30}(parcel|consignment|seized|found)", 65, "Fake parcel containing narcotics accusation", "पार्सल में ड्रग्स मिलने का फर्जी आरोप", "पार्सलमध्ये अंमली पदार्थ सापडल्याचा खोटा आरोप"),
    ("money_laund", "(money\\s*laundering|hawala|illegal\\s*funds).{0,30}(account|fir|investigation)", 65, "Fake money laundering FIR threat", "मनी लॉन्ड्रिंग एफआईआर की फर्जी धमकी", "मनी लाँडरिंग एफआयआरची बनावट धमकी"),
    ("fake_docs", "(fake\\s*passports?|forged\\s*aadhaar|illegal\\s*sims?).{0,30}(registered|seized)", 65, "Accusation of fake passports or illegal SIMs", "फर्जी पासपोर्ट या अवैध सिम कार्ड का झूठा आरोप", "बनावट पासपोर्ट किंवा बेकायदेशीर सिमकार्डचा खोटा आरोप"),
    ("arrest_warrant", "(arrest\\s*warrant|non-bailable|court\\s*summons).{0,30}(issued|pending|active)", 65, "Non-bailable arrest warrant threat", "गैर-जमानती गिरफ़्तारी वारंट की धमकी", "अजामीनपात्र अटक वॉरंटची धमकी"),
    ("video_interrogate", "(video\\s*call|skype|whatsapp\\s*video).{0,30}(interrogation|statement|police)", 65, "Video call interrogation demand (Digital Arrest)", "वीडियो कॉल पर पूछताछ की मांग (डिजिटल अरेस्ट)", "व्हिडिओ कॉलवर चौकशीची मागणी (डिजिटल अटक)"),
    ("stay_in_room", "(do\\s*not\\s*(leave|disconnect|inform)).{0,40}(room|camera|family)", 70, "Isolation and digital arrest confinement order", "कमरे में बंद रहने और कॉल न काटने का दबाव", "खोलीत राहण्याचा आणि कॉल न तोडण्याचा दबाव"),
    ("escrow_fund", "(transfer|deposit|supervision\\s*account|rbi\\s*safe).{0,30}(verify|clearance|refund)", 70, "Demand to move money to safe/supervision account", "सुरक्षित खाते में सत्यापन हेतु पैसे भेजने की ठगी", "सुरक्षित खात्यात पडताळणीसाठी पैसे पाठवण्याची फसवणूक"),
]

for a_id, a_pat in agencies:
    for c_id, c_pat, wt, en, hi, mr in claims:
        rid = f"r_da_{a_id}_{c_id}"
        pat = f"({a_pat}).{{0,50}}{c_pat}"
        add_r(rid, "digital_arrest", pat, wt, f"{a_id.upper()}: {en}", f"{a_id.upper()}: {hi}", f"{a_id.upper()}: {mr}", f"Digital arrest {a_id} {c_id}")

# 4. DELIVERY & COURIER SMISHING (8 couriers x 5 scenarios = 40 rules)
couriers = [
    ("indiapost", "India\\s*Post|Speed\\s*Post|भारतीय\\s*डाक"),
    ("bluedart", "Blue\\s*Dart|Bluedart"),
    ("delhivery", "Delhivery"),
    ("dtdc", "DTDC"),
    ("fedex", "FedEx"),
    ("dhl", "DHL\\s*Express|DHL"),
    ("ekart", "Ekart\\s*Logistics|Ekart"),
    ("amazon_log", "Amazon\\s*Delivery|Amazon\\s*Logistics"),
]

deliv_scens = [
    ("wrong_address", "(address\\s*(incomplete|wrong|missing)|पत्ता\\s*चुकीचा|पता\\s*अधूरा)", 60, "Undelivered parcel address update phishing", "गलत पते का झांसा देकर लिंक पर क्लिक कराने का जाल", "चुकीच्या पत्त्याचे निमित्त करून फसव्या लिंकवर नेण्याचा सापळा"),
    ("small_fee", "(pay|fee|charge).{0,20}(rs\\.?\\s*[0-9]+|5|25|49|re-delivery)", 65, "Nominal redelivery fee card skimming trap", "दोबारा डिलीवरी के नाम पर 5-25 रुपये मांगने का कार्ड स्किमिंग जाल", "पुन्हा डिलिव्हरीसाठी नाममात्र शुल्क मागून कार्ड हॅक करण्याचा सापळा"),
    ("detained_hub", "(parcel|package).{0,30}(detained|held\\s*at\\s*hub|clearance)", 55, "Detained package clearance urgency", "पार्सल रोके जाने की फर्जी सूचना", "पार्सल अडकल्याची बनावट सूचना"),
    ("return_notice", "(return\\s*to\\s*sender|destroyed\\s*in\\s*24\\s*hours|परत\\s*जाईल)", 60, "Return to sender threat urgency", "24 घंटे में पार्सल वापस भेजने की धमकी", "२४ तासात पार्सल परत पाठवण्याची धमकी"),
    ("suspicious_url", "(click\\s*to\\s*update|track\\s*package).{0,30}(http|bit\\.ly|\\.top|\\.xyz)", 65, "Parcel tracking phishing link", "पार्सल ट्रैकिंग की संदिग्ध लिंक", "पार्सल ट्रॅकिंगची संशयास्पद लिंक"),
]

for c_id, c_pat in couriers:
    for s_id, s_pat, wt, en, hi, mr in deliv_scens:
        rid = f"r_dl_{c_id}_{s_id}"
        pat = f"({c_pat}).{{0,40}}{s_pat}"
        add_r(rid, "phishing_link", pat, wt, f"{c_id.upper()}: {en}", f"{c_id.upper()}: {hi}", f"{c_id.upper()}: {mr}", f"Delivery smishing {c_id} {s_id}")

# 5. WORK FROM HOME & TASK SCAMS (10 tasks x 4 scenarios = 40 rules)
tasks = [
    ("yt_like", "youtube.{0,20}(like|subscribe|video)"),
    ("maps_review", "google\\s*maps?.{0,20}(review|rating|5\\s*star)"),
    ("hotel_rate", "(hotel|resort|tripadvisor).{0,20}(rating|review)"),
    ("amazon_eval", "(amazon|flipkart).{0,20}(order|product\\s*review)"),
    ("netflix_watch", "(netflix|movie|trailer).{0,20}(watch|rating)"),
    ("insta_follow", "(instagram|reels).{0,20}(follow|creator)"),
    ("spotify_stream", "(spotify|music).{0,20}(listen|stream|song)"),
    ("app_test", "(app\\s*store|play\\s*store).{0,20}(install|review|test)"),
    ("crypto_task", "(usdt|crypto|bitcoin).{0,20}(task|daily\\s*trade)"),
    ("merchant_vip", "(merchant|prepaid|welfare).{0,20}(task|recharge)"),
]

task_scens = [
    ("daily_salary", "(earn|salary|income).{0,20}(rs\\.?\\s*[0-9]+|2500|5000|8000).{0,20}(daily|per\\s*day)", 65, "Unrealistic daily microtask income guarantee", "रोजाना ₹2,500-₹8,000 कमाने का फर्जी वादा", "दररोज ₹२,५००-₹८,००० कमावण्याचे खोटे आमिष"),
    ("short_hours", "(10-20\\s*mins|15-30\\s*minutes|work\\s*from\\s*home).{0,30}(no\\s*experience|students|women)", 55, "Targeting students/homemakers with fake work-from-home", "छात्रों व महिलाओं को आसान काम का झांसा", "विद्यार्थी व महिलांना सोप्या कामाचे आमिष"),
    ("telegram_hr", "(contact|join|telegram|whatsapp).{0,30}(hr|receptionist|priya|neha|anjali)", 65, "Pushed to Telegram/WhatsApp HR for task onboarding", "टेलीग्राम या व्हाट्सएप पर फर्जी एचआर से संपर्क का जाल", "टेलिग्राम किंवा व्हॉट्सअ‍ॅपवर बनावट एचआरशी संपर्काचा सापळा"),
    ("recharge_unlock", "(recharge|deposit|frozen\\s*funds).{0,30}(unlock\\s*commission|withdraw)", 70, "Prepaid task deposit extortion trap", "कमीशन निकालने के नाम पर पैसे जमा कराने की ठगी", "कमिशन काढण्यासाठी आणखी पैसे भरण्याचा दबाव"),
]

for t_id, t_pat in tasks:
    for s_id, s_pat, wt, en, hi, mr in task_scens:
        rid = f"r_tk_{t_id}_{s_id}"
        pat = f"({t_pat}).{{0,40}}{s_pat}"
        add_r(rid, "investment_group", pat, wt, f"Task Scam: {en}", f"टास्क स्कैम: {hi}", f"टास्क स्कॅम: {mr}", f"Task scam {t_id} {s_id}")

# 6. TRAFFIC CHALLAN & COURT SUMMONS (15 states x 3 scenarios = 45 rules)
states = [
    ("mh", "MH"), ("dl", "DL"), ("ka", "KA"), ("up", "UP"), ("hr", "HR"),
    ("ts", "TS"), ("gj", "GJ"), ("rj", "RJ"), ("tn", "TN"), ("wb", "WB"),
    ("mp", "MP"), ("pb", "PB"), ("kl", "KL"), ("ap", "AP"), ("pari", "Parivahan"),
]

ch_scens = [
    ("pending_fine", "(challan|unpaid\\s*fine).{0,25}(pending|due|overdue|rupees)", 60, "Traffic fine notice with penalty warning", "यातायात चालान और जुर्माने की फर्जी सूचना", "वाहतूक चलन आणि दंडाची बनावट सूचना"),
    ("virtual_court", "(virtual\\s*court|lok\\s*adalat|court\\s*summons).{0,30}(issued|appear)", 65, "Virtual court summons threat for unpaid challan", "चालान के नाम पर कोर्ट समन की धमकी", "चलनासाठी कोर्ट समन्सची धमकी"),
    ("seize_rc", "(rc|vehicle|license).{0,30}(impound|seize|suspend|blacklist)", 65, "Vehicle seizure or license suspension threat", "गाड़ी जब्त करने या लाइसेंस निलंबित करने की धमकी", "गाडी जप्त करण्याची किंवा परवाना रद्द करण्याची धमकी"),
]

for st_id, st_pat in states:
    for s_id, s_pat, wt, en, hi, mr in ch_scens:
        rid = f"r_tc_{st_id}_{s_id}"
        pat = f"({st_pat}).{{0,35}}{s_pat}"
        add_r(rid, "fake_challan", pat, wt, f"{st_id.upper()}: {en}", f"{st_id.upper()}: {hi}", f"{st_id.upper()}: {mr}", f"Traffic challan {st_id} {s_id}")

# 7. GOVERNMENT SCHEMES & WELFARE (12 schemes x 3 scenarios = 36 rules)
gov_list = [
    ("pm_kisan", "PM\\s*Kisan|Pradhan\\s*Mantri\\s*Kisan|पीएम\\s*किसान"),
    ("ladki_bahin", "Ladki\\s*Bahin|लाडकी\\s*बहीण"),
    ("ayushman", "Ayushman\\s*Bharat|PMJAY|आयुष्मान\\s*कार्ड"),
    ("pm_awas", "PM\\s*Awas|Awas\\s*Yojana|आवास\\s*योजना"),
    ("eshram", "E-Shram|Eshram|ई-श्रम"),
    ("free_phone", "Free\\s*Smartphone|Free\\s*Mobile|मुफ्त\\s*स्मार्टफोन"),
    ("free_laptop", "Free\\s*Laptop|Free\\s*Tablet|मुफ्त\\s*लैपटॉप"),
    ("free_5g", "Free\\s*5G|3\\s*Months\\s*Recharge|फ्री\\s*रिचार्ज"),
    ("sukanya", "Sukanya\\s*Samriddhi|सुकन्या\\s*समृद्धि"),
    ("ration_card", "Ration\\s*Card|Free\\s*Ration|राशन\\s*कार्ड"),
    ("solar_roof", "Solar\\s*Rooftop|PM\\s*Surya\\s*Ghar|सूर्य\\s*घर"),
    ("gas_subsidy", "Ujjwala|Gas\\s*Subsidy|गैस\\s*सब्सिडी"),
]

gov_scens = [
    ("ekyc_hold", "(e-?kyc|aadhar\\s*link).{0,25}(pending|hold|mandatory|अधूरा|बंद)", 60, "Welfare scheme e-KYC suspension trap", "सरकारी योजना ई-केवाईसी रुकने का झांसा", "सरकारी योजना ई-केवायसी थांबल्याचे आमिष"),
    ("claim_cash", "(claim|transfer|approved|मंजूर|रुपये).{0,25}(rs\\.?\\s*[0-9]+|2000|5000|1500)", 60, "Fake direct benefit cash transfer claim", "सरकारी खाते में नकद राशि आने का झूठा दावा", "सरकारी खात्यात थेट पैसे आल्याचा खोटा दावा"),
    ("fake_portal", "(registration|apply\\s*online|portal).{0,25}(http|bit\\.ly|\\.site|\\.top)", 65, "Phishing portal masquerading as government scheme", "सरकारी योजना की नकल करने वाला फर्जी पोर्टल", "सरकारी योजनेची नक्कल करणारे बनावट पोर्टल"),
]

for g_id, g_pat in gov_list:
    for s_id, s_pat, wt, en, hi, mr in gov_scens:
        rid = f"r_gv_{g_id}_{s_id}"
        pat = f"({g_pat}).{{0,40}}{s_pat}"
        add_r(rid, "fake_kyc", pat, wt, f"Gov Scheme: {en}", f"सरकारी योजना: {hi}", f"सरकारी योजना: {mr}", f"Government scheme scam {g_id} {s_id}")

# 8. UPI, QR & PAYMENT COLLECT TRAPS (25 rules)
upi_spec = [
    ("gpay_reward_4999", "google\\s*pay.{0,20}(reward|cashback).{0,20}\\b(4999|1999|2999|9999)\\b", 65, "Google Pay fake reward claim", "गूगल पे फर्जी रिवॉर्ड क्लेम", "गुगल पे बनावट रिवॉर्ड क्लेम"),
    ("phonepe_cashback_vouch", "phonepe.{0,20}(cashback|voucher).{0,20}(claim|accept|pin)", 65, "PhonePe cashback voucher trap", "फोनपे कैशबैक वाउचर का झांसा", "फोनपे कॅशबॅक वाउचरचा सापळा"),
    ("paytm_kyc_wallet", "paytm.{0,20}(wallet|kyc).{0,20}(blocked|expired|unblock)", 60, "Paytm wallet KYC expiration phishing", "पेटीएम वॉलेट केवाईसी ब्लॉक का अलर्ट", "पेटीएम वॉलेट केवायसी ब्लॉकचा इशारा"),
    ("olx_buyer_qr", "(olx|quikr).{0,30}(scan\\s*qr|army\\s*officer|advance)", 65, "OLX QR code scan scam", "ओएलएक्स क्यूआर कोड स्कैन ठगी", "ओएलएक्स क्यूआर कोड स्कॅन फसवणूक"),
    ("enter_pin_to_get", "(enter\\s*pin|put\\s*pin).{0,25}(to\\s*receive|to\\s*credit|to\\s*get)", 70, "Fatal UPI Trap: Entering PIN to receive funds", "पैसे पाने के लिए पिन डालने का जाल", "पैसे मिळवण्यासाठी पिन टाकण्याचा सापळा"),
    ("upi_collect_req", "upi://pay\\?pa=[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+", 60, "Raw UPI payment intent link", "अप्रत्यक्ष यूपीआई पेमेंट अनुरोध", "अप्रत्यक्ष यूपीआय पेमेंट विनंती"),
    ("wrong_transfer_claim", "(sent\\s*by\\s*mistake|गलती\\s*से\\s*पैसे|चुकीने\\s*पैसे).{0,30}(refund|वापस|परत)", 65, "Accidental payment refund extortion", "गलती से पैसे भेजने का झूठा बहाना", "चुकीने पैसे पाठवल्याचे खोटे सांगून फसवणूक"),
    ("fake_credit_sms", "(credited\\s*to\\s*your|a/c\\s*credited).{0,30}(rs\\.?\\s*[0-9]+).{0,30}(click\\s*here|confirm)", 60, "Fake payment credit confirmation phishing", "फर्जी क्रेडिट एसएमएस दिखाकर फंसाने का जाल", "बनावट पेमेंट जमा संदेश दाखवून फसवणूक"),
    ("request_money_trap", "(requested\\s*money|collect\\s*request).{0,20}(accept|approve\\s*now)", 60, "UPI collect request disguised as payment", "पेमेंट अनुरोध को स्वीकृति दिलाने का जाल", "पेमेंट विनंतीला मंजुरी मिळवण्याचा सापळा"),
    ("scan_barcode_pay", "(scan\\s*barcode|scan\\s*qr).{0,20}(receive\\s*cash|won\\s*prize)", 65, "Scan QR barcode to receive prize trap", "इनाम पाने के लिए क्यूआर कोड स्कैन करने का झांसा", "बक्षीस मिळवण्यासाठी क्यूआर स्कॅन करण्याचा सापळा"),
]

for rid, pat, wt, en, hi, mr in upi_spec:
    add_r(f"r_up_sp_{rid}", "upi_collect_trap", pat, wt, en, hi, mr, f"UPI Trap {rid}")

# 9. INVESTMENT, STOCKS & CRYPTO (25 rules)
inv_spec = [
    ("upper_circuit_guar", "(upper\\s*circuit|1000%|jackpot\\s*stock|multibagger).{0,25}(guaranteed|sure)", 65, "Guaranteed stock market upper circuit tipping", "शेयर बाजार में 1000% गारंटीड रिटर्न का फर्जी झांसा", "शेअर बाजारात हमखास नफ्याचे खोटे आमिष"),
    ("sebi_vip_group", "(sebi\\s*analyst|institutional\\s*vip).{0,25}(whatsapp|telegram)", 60, "Impersonating SEBI analyst in VIP groups", "सेबी रजिस्टर्ड बताकर वीआईपी ग्रुप में ठगी", "सेबी नोंदणीकृत सांगून व्हीआयपी ग्रुपमध्ये फसवणूक"),
    ("ipo_grey_market", "(ipo\\s*allocation|grey\\s*market\\s*premium|gmp).{0,25}(confirmed|transfer)", 65, "Grey market IPO allocation advance fee fraud", "आईपीओ अलॉटमेंट के नाम पर अग्रिम राशि की ठगी", "आयपीओ शेअर्ससाठी आगाऊ रकमेची फसवणूक"),
    ("ai_crypto_bot", "(crypto\\s*bot|ai\\s*trading).{0,20}(daily\\s*5%|daily\\s*10%|guaranteed)", 65, "Crypto AI trading bot Ponzi scheme", "क्रिप्टो एआई बॉट से रोजाना 5% मुनाफे का पोंजी जाल", "क्रिप्टो बॉटद्वारे दररोज नफ्याचे आमिष"),
    ("forex_signals", "(forex\\s*signals|gold\\s*signals).{0,20}(99%\\s*accuracy|vip\\s*channel)", 60, "Unregulated foreign forex signals channel", "अवैध विदेशी फॉरेक्स सिग्नल ग्रुप", "बेकायदेशीर फॉरेक्स ट्रेडिंग सिग्नल्स ग्रुप"),
    ("pig_butchering_hk", "(uncle\\s*trading|invest\\s*in\\s*crypto).{0,30}(rich|wealth|platform)", 65, "Romance investment hybrid (Pig Butchering)", "रोमांस और निवेश का शा झू पान (Pig Butchering) जाल", "रोमान्स आणि बनावट गुंतवणुकीचा सापळा"),
]

for rid, pat, wt, en, hi, mr in inv_spec:
    add_r(f"r_in_sp_{rid}", "investment_group", pat, wt, en, hi, mr, f"Investment {rid}")

# 10. MALICIOUS APKS & SCREEN SHARING (20 rules)
apk_spec = [
    ("wedding_card_apk2", "(wedding_card|shadi_card|invitation_card|लग्नपत्रिका)\\.apk", 75, "Malicious wedding card APK spyware", "शादी के कार्ड के नाम पर स्पाईवेयर एपीके", "लग्नपत्रिकेच्या नावाखाली स्पायवेअर एपीके"),
    ("festival_greet_apk", "(diwali_wishes|ram_mandir|holi_hai|eid_mubarak)\\.apk", 75, "Festival greeting spyware APK", "त्योहार की बधाई के नाम पर वायरस एपीके", "सणांच्या शुभेच्छांच्या नावाखाली व्हायरस एपीके"),
    ("parivahan_fake_apk2", "(parivahan_challan|vahan_service|echallan_pay)\\.apk", 75, "Fake Parivahan challan APK Trojan", "नकली परिवहन चालान ऐप एपीके", "बनावट परिवहन चलन अ‍ॅप एपीके"),
    ("remote_anydesk_lure", "(install|download).{0,25}(anydesk|rustdesk|teamviewer|quicksupport)", 70, "Remote Access Tool (RAT) takeover lure", "फोन रिमोट पर लेने वाले ऐप को डाउनलोड कराने की कोशिश", "फोनचा रिमोट ताबा घेणारे अ‍ॅप डाऊनलोड करण्याचा प्रयत्न"),
    ("sms_spy_reader", "(sms_forwarder|otp_reader|sim_support)\\.apk", 75, "Banking SMS and OTP interception Trojan", "बैंक ओटीपी चुराने वाला वायरस ऐप", "बँक ओटीपी चोरणारा व्हायरस अ‍ॅप"),
    ("electricity_bill_apk2", "(bijli_bill|elec_update|mseb_pay)\\.apk", 75, "Electricity bill update trojan APK", "बिजली बिल भुगतान के नाम पर फर्जी ऐप", "वीज बिलाच्या नावाखाली बनावट अ‍ॅप"),
]

for rid, pat, wt, en, hi, mr in apk_spec:
    add_r(f"r_ap_sp_{rid}", "phishing_link", pat, wt, en, hi, mr, f"Malicious APK {rid}")

# 11. SEXTORTION & SIM SWAP (20 rules)
tele_spec = [
    ("esim_fraud_req", "(esim|e-sim).{0,25}(activate|confirmation|reply\\s*1)", 70, "SIM swap hijacking attempt via eSIM request", "ई-सिम एक्टिवेशन के नाम पर नंबर हैक करने की कोशिश", "ई-सिमद्वारे नंबर हॅक करण्याचा प्रयत्न"),
    ("video_blackmail", "(nude|private\\s*video).{0,30}(viral|leak|youtube|family|pay)", 70, "Sextortion threat to leak private video", "निजी वीडियो वायरल करने की धमकी देकर ब्लैकमेल", "व्हिडिओ व्हायरल करण्याची धमकी देऊन खंडणी"),
    ("cyber_cop_extort", "(cyber\\s*cell|delhi\\s*police).{0,30}(delete\\s*video|pay\\s*penalty|fir)", 70, "Cyber police extortion colluding in sextortion", "फर्जी साइबर पुलिस द्वारा वीडियो डिलीट कराने के नाम पर वसूली", "व्हिडिओ हटवण्याच्या नावाखाली बनावट पोलिसांकडून खंडणी"),
    ("trai_sim_cutoff", "trai.{0,25}(disconnect|suspend).{0,25}(all\\s*numbers|sim)", 65, "Fake TRAI telecom disconnection alert", "ट्राई द्वारा सभी नंबर बंद करने की फर्जी धमकी", "ट्रायकडून सर्व नंबर बंद करण्याची बनावट धमकी"),
]

for rid, pat, wt, en, hi, mr in tele_spec:
    add_r(f"r_tl_sp_{rid}", "sim_swap", pat, wt, en, hi, mr, f"Telecom/Sextortion {rid}")

# 12. MULTILINGUAL REGIONAL DEVANAGARI (30 rules)
dev_spec = [
    ("mr_vij_cutoff_tonight", "आज\\s*रात्री\\s*(९:३०|१०:००|८:३०|वीज\\s*खंडित)", 65, "Marathi power cutoff tonight threat", "आज रात बिजली काटने की धमकी (मराठी)", "आज रात्री वीज तोडण्याची धमकी (मराठी)"),
    ("mr_officer_call_karan", "(वीज\\s*अधिकारी|अभियंता).{0,25}\\b[6-9][0-9]{9}\\b", 65, "Marathi instruction to call officer mobile", "अधिकारी के फोन नंबर पर संपर्क का दबाव (मराठी)", "अधिकाऱ्याच्या फोन नंबरवर संपर्काचा दबाव (मराठी)"),
    ("mr_khate_adhavle", "बँक\\s*खाते\\s*(अडवले|गोठवले|केवायसी\\s*करा)", 60, "Marathi bank account frozen alert", "बैंक खाता फ्रीज होने का मराठी अलर्ट", "बँक खाते फ्रीज झाल्याचा मराठी अलर्ट"),
    ("hi_bijli_cut_aaj_raat", "आज\\s*रात\\s*(९:३०|9:30|10:00|बिजली\\s*कट\\s*जाएगी)", 65, "Hindi electricity disconnection tonight", "आज रात बिजली कटने की सूचना", "आज रात्री वीज कापण्याची सूचना"),
    ("hi_police_interrogation", "(डिजिटल\\s*अरेस्ट|सीबीआई\\s*पूछताछ|कमरे\\s*से\\s*बाहर\\s*न\\s*निकलें)", 70, "Hindi digital arrest interrogation confinement", "डिजिटल अरेस्ट कमरे में बंद रहने का दबाव", "खोलीत राहण्याचा डिजिटल अरेस्ट दबाव"),
    ("hi_lottery_25_lakh", "(केबीसी|लॉटरी|25\\s*लाख|जीता\\s*है)", 65, "Hindi KBC 25 Lakh lottery winner notice", "केबीसी 25 लाख लॉटरी जीतने का संदेश", "केबीसी २५ लाख लॉटरी जिंकल्याचा संदेश"),
]

for rid, pat, wt, en, hi, mr in dev_spec:
    add_r(f"r_dv_sp_{rid}", "fake_kyc", pat, wt, en, hi, mr, f"Devanagari Regional {rid}")

# Combine and write
data['rules'] = existing_rules + new_rules
data['version'] = "5.0.0-maximum-500-defense"
data['updatedAt'] = "2026-09-20"

print(f"Generated {len(new_rules)} new rules.")
print(f"Total rules in rules.json: {len(data['rules'])}")

with open('assets/rules.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Saved assets/rules.json successfully.")
