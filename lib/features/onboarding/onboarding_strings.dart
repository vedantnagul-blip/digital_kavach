import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class OnboardingStrings {
  const OnboardingStrings({
    required this.progressLabel,
    required this.next,
    required this.back,
    required this.skip,
    required this.finish,
    required this.langTitle,
    required this.langSubtitle,
    required this.langComingSoonNote,
    required this.modeTitle,
    required this.modeSubtitle,
    required this.modeStandardTitle,
    required this.modeStandardBullets,
    required this.modeElderTitle,
    required this.modeElderBullets,
    required this.modePreviewSample,
    required this.signInTitle,
    required this.signInSubtitle,
    required this.signInGoogle,
    required this.signInGuest,
    required this.signInGuestNote,
    required this.signInCancelled,
    required this.consentTitle,
    required this.consentSubtitle,
    required this.consentReadTitle,
    required this.consentReadBody,
    required this.consentLocalTitle,
    required this.consentLocalBody,
    required this.consentLeavesTitle,
    required this.consentLeavesBody,
    required this.consentStorageTitle,
    required this.consentStorageBody,
    required this.consentAllow,
    required this.consentOfflineOnly,
    required this.consentFooter,
    required this.sentinelTitle,
    required this.sentinelSubtitle,
    required this.sentinelStepNotifAccess,
    required this.sentinelStepBattery,
    required this.sentinelStepPostNotif,
    required this.sentinelLater,
    required this.sentinelLockedNote,
    required this.sentinelActionGrant,
    required this.sentinelActionGranted,
    required this.sentinelActive,
    required this.sentinelEnable,
  });

  final String progressLabel;
  final String next;
  final String back;
  final String skip;
  final String finish;

  final String langTitle;
  final String langSubtitle;
  final String langComingSoonNote;

  final String modeTitle;
  final String modeSubtitle;
  final String modeStandardTitle;
  final List<String> modeStandardBullets;
  final String modeElderTitle;
  final List<String> modeElderBullets;
  final String modePreviewSample;

  final String signInTitle;
  final String signInSubtitle;
  final String signInGoogle;
  final String signInGuest;
  final String signInGuestNote;
  final String signInCancelled;

  final String consentTitle;
  final String consentSubtitle;
  final String consentReadTitle;
  final String consentReadBody;
  final String consentLocalTitle;
  final String consentLocalBody;
  final String consentLeavesTitle;
  final String consentLeavesBody;
  final String consentStorageTitle;
  final String consentStorageBody;
  final String consentAllow;
  final String consentOfflineOnly;
  final String consentFooter;

  final String sentinelTitle;
  final String sentinelSubtitle;
  final String sentinelStepNotifAccess;
  final String sentinelStepBattery;
  final String sentinelStepPostNotif;
  final String sentinelLater;
  final String sentinelLockedNote;
  final String sentinelActionGrant;
  final String sentinelActionGranted;
  final String sentinelActive;
  final String sentinelEnable;

  static const OnboardingStrings en = OnboardingStrings(
    progressLabel: 'Step',
    next: 'Continue',
    back: 'Back',
    skip: 'Skip for now',
    finish: 'Complete Setup',
    langTitle: 'Choose your language',
    langSubtitle: 'You can change this later in Settings.',
    langComingSoonNote:
    'App menus are in English for now — scam warnings will still arrive in your language.',
    modeTitle: 'Pick a comfortable view',
    modeSubtitle: 'Bigger buttons and voice help are one tap away.',
    modeStandardTitle: 'Standard',
    modeStandardBullets: <String>[
      'Regular size buttons and text',
      'Compact home screen',
    ],
    modeElderTitle: 'Elder Mode',
    modeElderBullets: <String>[
      'Large text (1.4×)',
      'Bigger buttons (64 dp)',
      'Voice explanations by default',
    ],
    modePreviewSample: 'Digital Kavach protects you from scams.',
    signInTitle: 'Sign in to sync',
    signInSubtitle:
    'Signing in lets Family Shield alert your loved ones and keeps your history safe.',
    signInGoogle: 'Continue with Google',
    signInGuest: 'Try without signing in',
    signInGuestNote:
    'Guest mode works, but Family Shield and cloud sync are disabled.',
    signInCancelled: 'Sign-in cancelled. Try again.',
    consentTitle: 'Your data, your choice',
    consentSubtitle: 'Plain English — no fine print.',
    consentReadTitle: 'What we read',
    consentReadBody:
    'Only notifications from apps you pick in the next step (WhatsApp, SMS, Telegram). Never call logs or contacts.',
    consentLocalTitle: 'What stays on your phone',
    consentLocalBody:
    'Everything we analyze runs on-device first. Safe messages never leave.',
    consentLeavesTitle: 'What leaves the phone',
    consentLeavesBody:
    'Only messages our on-device check flags as risky are sent to our AI (Gemini) for a second look — with your consent below.',
    consentStorageTitle: 'What we store',
    consentStorageBody:
    'A short fingerprint (hash) of the verdict — never the original message.',
    consentAllow: 'Allow AI deep-scan',
    consentOfflineOnly: 'Offline check only',
    consentFooter:
    'You can change this any time in Settings. AI opinion — final decision is yours.',
    sentinelTitle: 'Turn on Kavach Sentinel',
    sentinelSubtitle: 'Real-time automatic protection while your phone stays locked.',
    sentinelStepNotifAccess: 'Notification Access',
    sentinelStepBattery: 'Battery-saver exemption',
    sentinelStepPostNotif: 'Enable background protection',
    sentinelLater: 'Skip for now',
    sentinelLockedNote:
    'You can adjust notification permissions or battery saver settings anytime from Settings → Sentinel Health Center.',
    sentinelActionGrant: 'Grant Permission',
    sentinelActionGranted: 'Granted ✓',
    sentinelActive: 'Active ✓',
    sentinelEnable: 'Enable Now',
  );

  static const OnboardingStrings hi = OnboardingStrings(
    progressLabel: 'चरण',
    next: 'आगे बढ़ें',
    back: 'वापस',
    skip: 'अभी छोड़ें',
    finish: 'सेटअप पूरा करें',
    langTitle: 'अपनी भाषा चुनें',
    langSubtitle: 'बाद में सेटिंग्स में बदल सकते हैं।',
    langComingSoonNote:
    'ऐप के मेनू अभी अंग्रेज़ी में हैं — घोटाला चेतावनियाँ आपकी भाषा में मिलेंगी।',
    modeTitle: 'आरामदायक व्यू चुनें',
    modeSubtitle: 'बड़े बटन और आवाज़ मदद एक टैप दूर हैं।',
    modeStandardTitle: 'सामान्य',
    modeStandardBullets: <String>[
      'सामान्य आकार के बटन और टेक्स्ट',
      'कॉम्पैक्ट होम स्क्रीन',
    ],
    modeElderTitle: 'बुज़ुर्ग मोड',
    modeElderBullets: <String>[
      'बड़ा टेक्स्ट (1.4×)',
      'बड़े बटन (64 dp)',
      'डिफ़ॉल्ट रूप से आवाज़ में समझाना',
    ],
    modePreviewSample: 'डिजिटल कवच घोटालों से आपकी रक्षा करता है।',
    signInTitle: 'साइन इन करें',
    signInSubtitle:
    'साइन इन करने से Family Shield काम करेगा और आपका इतिहास सुरक्षित रहेगा।',
    signInGoogle: 'Google से जारी रखें',
    signInGuest: 'बिना साइन-इन के आज़माएँ',
    signInGuestNote:
    'गेस्ट मोड चलेगा, लेकिन Family Shield और क्लाउड सिंक बंद रहेंगे।',
    signInCancelled: 'साइन-इन रद्द हुआ। दोबारा कोशिश करें।',
    consentTitle: 'आपका डेटा, आपका फ़ैसला',
    consentSubtitle: 'सरल भाषा — कोई छिपी शर्तें नहीं।',
    consentReadTitle: 'हम क्या पढ़ते हैं',
    consentReadBody:
    'सिर्फ़ आपके चुने ऐप्स के notifications (WhatsApp, SMS, Telegram)। कभी call log या contacts नहीं।',
    consentLocalTitle: 'फ़ोन में क्या रहता है',
    consentLocalBody:
    'सारा विश्लेषण पहले आपके फ़ोन पर होता है। सुरक्षित संदेश कभी बाहर नहीं जाते।',
    consentLeavesTitle: 'फ़ोन से क्या जाता है',
    consentLeavesBody:
    'सिर्फ़ वे संदेश जिन्हें हमारा ऑन-डिवाइस चेक जोखिम मानता है — आपकी अनुमति से AI (Gemini) को भेजे जाते हैं।',
    consentStorageTitle: 'हम क्या सहेजते हैं',
    consentStorageBody:
    'सिर्फ़ नतीजे का छोटा fingerprint (hash) — कभी असली संदेश नहीं।',
    consentAllow: 'AI डीप-स्कैन की अनुमति दें',
    consentOfflineOnly: 'सिर्फ़ ऑफलाइन जाँच',
    consentFooter:
    'सेटिंग्स में कभी भी बदल सकते हैं। AI की राय — अंतिम निर्णय आपका।',
    sentinelTitle: 'Kavach Sentinel चालू करें',
    sentinelSubtitle: 'फ़ोन बंद हो तब भी 24x7 अपने-आप सुरक्षा।',
    sentinelStepNotifAccess: 'Notification Access',
    sentinelStepBattery: 'बैटरी-सेवर से छूट',
    sentinelStepPostNotif: 'बैकग्राउंड सुरक्षा सक्षम करें',
    sentinelLater: 'अभी छोड़ें',
    sentinelLockedNote:
    'सेटिंग्स → Sentinel Health Center से आप कभी भी अनुमतियाँ बदल सकते हैं।',
    sentinelActionGrant: 'अनुमति दें',
    sentinelActionGranted: 'स्वीकृत ✓',
    sentinelActive: 'सक्रिय ✓',
    sentinelEnable: 'सक्रिय करें',
  );

  static const OnboardingStrings mr = OnboardingStrings(
    progressLabel: 'पायरी',
    next: 'पुढे',
    back: 'मागे',
    skip: 'आत्ता वगळा',
    finish: 'सेटअप पूर्ण करा',
    langTitle: 'तुमची भाषा निवडा',
    langSubtitle: 'नंतर सेटिंग्जमध्ये बदलू शकता.',
    langComingSoonNote:
    'अ‍ॅप मेनू सध्या इंग्रजीत — फसवणूक इशारे तुमच्या भाषेत येतील.',
    modeTitle: 'आरामदायक व्ह्यू निवडा',
    modeSubtitle: 'मोठी बटणे व आवाज मदत एक टॅप दूर.',
    modeStandardTitle: 'सामान्य',
    modeStandardBullets: <String>[
      'सामान्य आकाराची बटणे व मजकूर',
      'कॉम्पॅक्ट होम स्क्रीन',
    ],
    modeElderTitle: 'ज्येष्ठ मोड',
    modeElderBullets: <String>[
      'मोठा मजकूर (1.4×)',
      'मोठी बटणे (64 dp)',
      'डीफॉल्टने आवाजाने समजावणे',
    ],
    modePreviewSample: 'डिजिटल कवच फसवणुकीपासून तुमचे रक्षण करते.',
    signInTitle: 'साइन इन करा',
    signInSubtitle:
    'साइन इन केल्याने Family Shield कार्य करेल आणि इतिहास सुरक्षित राहील.',
    signInGoogle: 'Google ने पुढे जा',
    signInGuest: 'साइन-इन शिवाय प्रयत्न करा',
    signInGuestNote: 'गेस्ट मोड चालेल, पण Family Shield व क्लाउड सिंक बंद.',
    signInCancelled: 'साइन-इन रद्द. पुन्हा प्रयत्न करा.',
    consentTitle: 'तुमचा डेटा, तुमचा निर्णय',
    consentSubtitle: 'सोपी भाषा — छुप्या अटी नाहीत.',
    consentReadTitle: 'आम्ही काय वाचतो',
    consentReadBody:
    'फक्त तुम्ही निवडलेल्या अ‍ॅप्सचे notifications (WhatsApp, SMS, Telegram). कधीही call log किंवा contacts नाही.',
    consentLocalTitle: 'फोनमध्ये काय राहते',
    consentLocalBody:
    'सर्व तपासणी आधी तुमच्या फोनवरच होते. सुरक्षित संदेश कधीच बाहेर जात नाहीत.',
    consentLeavesTitle: 'फोनमधून काय जाते',
    consentLeavesBody:
    'फक्त धोकादायक वाटलेले संदेश — तुमच्या परवानगीने AI (Gemini) कडे पाठवले जातात.',
    consentStorageTitle: 'आम्ही काय साठवतो',
    consentStorageBody:
    'फक्त निकालाचा छोटा fingerprint (hash) — मूळ संदेश कधीच नाही.',
    consentAllow: 'AI डीप-स्कॅन ला परवानगी द्या',
    consentOfflineOnly: 'फक्त ऑफलाइन तपासणी',
    consentFooter:
    'सेटिंग्जमध्ये कधीही बदलू शकता. AI चे मत — अंतिम निर्णय तुमचा.',
    sentinelTitle: 'Kavach Sentinel चालू करा',
    sentinelSubtitle: 'फोन लॉक असतानाही 24x7 आपोआप संरक्षण.',
    sentinelStepNotifAccess: 'Notification Access',
    sentinelStepBattery: 'बॅटरी-सेव्हर सूट',
    sentinelStepPostNotif: 'पार्श्वभूमी संरक्षण सुरू करा',
    sentinelLater: 'आत्ता वगळा',
    sentinelLockedNote:
    'सेटिंग्ज → Sentinel Health Center वरून तुम्ही कधीही परवानग्या व्यवस्थापित करू शकता.',
    sentinelActionGrant: 'परवानगी द्या',
    sentinelActionGranted: 'मंजूर ✓',
    sentinelActive: 'सक्रिय ✓',
    sentinelEnable: 'सुरू करा',
  );

  static const OnboardingStrings ta = OnboardingStrings(
    progressLabel: 'படி',
    next: 'தொடரவும்',
    back: 'பின்செல்',
    skip: 'இப்போது தவிர்',
    finish: 'அமைப்பை முடி',
    langTitle: 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
    langSubtitle: 'இதை பின்னர் அமைப்புகளில் மாற்றலாம்.',
    langComingSoonNote: 'முழுமையான மொழி ஆதரவு இயக்கப்பட்டது.',
    modeTitle: 'வசதியான தோற்றத்தைத் தேர்ந்தெடுக்கவும்',
    modeSubtitle: 'பெரிய பொத்தான்கள் மற்றும் குரல் உதவி ஒரு தட்டலில்.',
    modeStandardTitle: 'நிலையானது',
    modeStandardBullets: <String>[
      'வழக்கமான அளவு பொத்தான்கள் மற்றும் உரை',
      'சிறிய முகப்பு திரை',
    ],
    modeElderTitle: 'முதியோர் முறைமை',
    modeElderBullets: <String>[
      'பெரிய உரை (1.4×)',
      'பெரிய பொத்தான்கள் (64 dp)',
      'இயல்பாகவே குரல் விளக்கம்',
    ],
    modePreviewSample: 'டிஜிட்டல் கவசம் உங்களை மோசடிகளிலிருந்து பாதுகாக்கிறது.',
    signInTitle: 'ஒத்திசைக்க உள்நுழையவும்',
    signInSubtitle: 'உள்நுழைவது குடும்பப் பாதுகாப்பை செயல்படுத்துகிறது.',
    signInGoogle: 'Google மூலம் தொடரவும்',
    signInGuest: 'உள்நுழையாமல் முயற்சிக்கவும்',
    signInGuestNote: 'விருந்தினர் முறை இயங்கும், கிளவுட் ஒத்திசைவு முடக்கப்படும்.',
    signInCancelled: 'உள்நுழைவு ரத்து செய்யப்பட்டது.',
    consentTitle: 'உங்கள் தரவு, உங்கள் முடிவு',
    consentSubtitle: 'எளிமையான மொழி — மறைக்கப்பட்ட விதிமுறைகள் இல்லை.',
    consentReadTitle: 'நாங்கள் எதைப் படிக்கிறோம்',
    consentReadBody: 'நீங்கள் தேர்ந்தெடுக்கும் பயன்பாடுகளின் அறிவிப்புகள் மட்டுமே.',
    consentLocalTitle: 'தொலைபேசியில் என்ன இருக்கும்',
    consentLocalBody: 'அனைத்து பகுப்பாய்வுகளும் முதலில் உங்கள் தொலைபேசியிலேயே இயங்கும்.',
    consentLeavesTitle: 'தொலைபேசியை விட்டு என்ன வெளியேறும்',
    consentLeavesBody: 'ஆபத்தானதாகக் கொடியிடப்பட்ட செய்திகள் மட்டுமே உங்கள் அனுமதியுடன் சரிபார்க்கப்படும்.',
    consentStorageTitle: 'நாங்கள் எதைச் சேமிக்கிறோம்',
    consentStorageBody: 'முடிவின் சிறிய கைரேகை (hash) மட்டுமே — அசல் செய்தி அல்ல.',
    consentAllow: 'AI ஆழமான ஸ்கேன் அனுமதிக்கவும்',
    consentOfflineOnly: 'ஆஃப்லைன் சரிபார்ப்பு மட்டுமே',
    consentFooter: 'அமைப்புகளில் எப்போது வேண்டுமானாலும் மாற்றலாம்.',
    sentinelTitle: 'Kavach Sentinel-ஐ இயக்கவும்',
    sentinelSubtitle: 'தொலைபேசி பூட்டப்பட்டிருக்கும்போதும் 24x7 தானியங்கி பாதுகாப்பு.',
    sentinelStepNotifAccess: 'அறிவிப்பு அணுகல்',
    sentinelStepBattery: 'பேட்டரி சேமிப்பு விலக்கு',
    sentinelStepPostNotif: 'பின்னணி பாதுகாப்பை இயக்கு',
    sentinelLater: 'இப்போது தவிர்',
    sentinelLockedNote: 'அமைப்புகள் → Sentinel Health Center மூலம் எப்போது வேண்டுமானாலும் மாற்றலாம்.',
    sentinelActionGrant: 'அனுமதி வழங்கு',
    sentinelActionGranted: 'வழங்கப்பட்டது ✓',
    sentinelActive: 'செயலில் உள்ளது ✓',
    sentinelEnable: 'இப்போது இயக்கு',
  );

  static const OnboardingStrings te = OnboardingStrings(
    progressLabel: 'దశ',
    next: 'కొనసాగించు',
    back: 'వెనుకకు',
    skip: 'ఇప్పుడు దాటవేయి',
    finish: 'సెటప్ పూర్తి చేయండి',
    langTitle: 'మీ భాషను ఎంచుకోండి',
    langSubtitle: 'దీన్ని తర్వాత సెట్టింగ్‌లలో మార్చవచ్చు.',
    langComingSoonNote: 'పూర్తి భాషా మద్దతు ప్రారంభించబడింది.',
    modeTitle: 'సౌకర్యవంతమైన వీక్షణను ఎంచుకోండి',
    modeSubtitle: 'పెద్ద బటన్లు మరియు వాయిస్ సహాయం అందుబాటులో ఉన్నాయి.',
    modeStandardTitle: 'ప్రామాణిక',
    modeStandardBullets: <String>[
      'సాధారణ పరిమాణ బటన్లు మరియు వచనం',
      'కాంపాక్ట్ హోమ్ స్క్రీన్',
    ],
    modeElderTitle: 'సీనియర్ మోడ్',
    modeElderBullets: <String>[
      'పెద్ద వచనం (1.4×)',
      'పెద్ద బటన్లు (64 dp)',
      'వాయిస్ వివరణలు అప్రమేయం',
    ],
    modePreviewSample: 'డిజిటల్ కవచ్ మిమ్మల్ని మోసాల నుండి రక్షిస్తుంది.',
    signInTitle: 'సైన్ ఇన్ చేయండి',
    signInSubtitle: 'సైన్ ఇన్ చేయడం వల్ల ఫ్యామిలీ షీల్డ్ పనిచేస్తుంది.',
    signInGoogle: 'Googleతో కొనసాగించండి',
    signInGuest: 'సైన్ ఇన్ లేకుండా ప్రయత్నించండి',
    signInGuestNote: 'గెస్ట్ మోడ్ పనిచేస్తుంది, క్లౌడ్ సింక్ నిలిపివేయబడుతుంది.',
    signInCancelled: 'సైన్ ఇన్ రద్దు చేయబడింది.',
    consentTitle: 'మీ డేటా, మీ ఎంపిక',
    consentSubtitle: 'స్పష్టమైన భాష — దాచిన నిబంధనలు లేవు.',
    consentReadTitle: 'మేము ఏమి చదువుతాము',
    consentReadBody: 'మీరు ఎంచుకున్న యాప్‌ల నోటిఫికేషన్‌లు మాత్రమే.',
    consentLocalTitle: 'ఫోన్‌లో ఏమి ఉంటుంది',
    consentLocalBody: 'విశ్లేషణ అంతా మీ ఫోన్‌లోనే స్థానికంగా జరుగుతుంది.',
    consentLeavesTitle: 'ఫోన్ నుండి బయటకు ఏమి వెళుతుంది',
    consentLeavesBody: 'ప్రమాదకరమైన సందేశాలు మాత్రమే మీ అనుమతితో తనిఖీ చేయబడతాయి.',
    consentStorageTitle: 'మేము ఏమి నిల్వ చేస్తాము',
    consentStorageBody: 'ఫలితం యొక్క చిన్న వేలిముద్ర (hash) మాత్రమే — అసలు సందేశం కాదు.',
    consentAllow: 'AI డీప్ స్కాన్ అనుమతించు',
    consentOfflineOnly: 'ఆఫ్‌లైన్ తనిఖీ మాత్రమే',
    consentFooter: 'సెట్టింగ్‌లలో ఎప్పుడైనా మార్చవచ్చు.',
    sentinelTitle: 'Kavach Sentinel ఆన్ చేయండి',
    sentinelSubtitle: 'ఫోన్ లాక్ చేయబడినప్పటికీ 24x7 ఆటోమేటిక్ రక్షణ.',
    sentinelStepNotifAccess: 'నోటిఫికేషన్ యాక్సెస్',
    sentinelStepBattery: 'బ్యాటరీ ఆదా మినహాయింపు',
    sentinelStepPostNotif: 'నేపథ్య రక్షణను ప్రారంభించండి',
    sentinelLater: 'ఇప్పుడు దాటవేయి',
    sentinelLockedNote: 'సెట్టింగ్‌లు → Sentinel Health Center నుండి ఎప్పుడైనా సర్దుబాటు చేయవచ్చు.',
    sentinelActionGrant: 'అనుమతి ఇవ్వండి',
    sentinelActionGranted: 'మంజూరు చేయబడింది ✓',
    sentinelActive: 'యాక్టివ్ ✓',
    sentinelEnable: 'ఇప్పుడే ప్రారంభించు',
  );

  static const OnboardingStrings bn = OnboardingStrings(
    progressLabel: 'ধাপ',
    next: 'এগিয়ে যান',
    back: 'পেছনে',
    skip: 'এখনই এড়িয়ে যান',
    finish: 'সেটআপ সম্পন্ন করুন',
    langTitle: 'আপনার ভাষা নির্বাচন করুন',
    langSubtitle: 'আপনি পরে সেটিংসে এটি পরিবর্তন করতে পারেন।',
    langComingSoonNote: 'সম্পূর্ণ ভাষা সমর্থন সক্রিয় রয়েছে।',
    modeTitle: 'একটি আরামদায়ক মোড বেছে নিন',
    modeSubtitle: 'বড় বোতাম এবং ভয়েস সহায়তা এক ট্যাপে উপলব্ধ।',
    modeStandardTitle: 'সাধারণ',
    modeStandardBullets: <String>[
      'নিয়মিত আকারের বোতাম এবং লেখা',
      'কমপ্যাক্ট হোম স্ক্রিন',
    ],
    modeElderTitle: 'প্রবীণ মোড',
    modeElderBullets: <String>[
      'বড় লেখা (১.৪×)',
      'বড় বোতাম (৬৪ dp)',
      'ডিফল্ট ভয়েস ব্যাখ্যা',
    ],
    modePreviewSample: 'ডিজিটাল কবচ আপনাকে প্রতারণা থেকে রক্ষা করে।',
    signInTitle: 'সাইন ইন করুন',
    signInSubtitle: 'সাইন ইন করলে ফ্যামিলি শিল্ড কাজ করবে এবং ইতিহাস সুরক্ষিত থাকবে।',
    signInGoogle: 'Google দিয়ে এগিয়ে যান',
    signInGuest: 'সাইন ইন ছাড়াই চেষ্টা করুন',
    signInGuestNote: 'গেস্ট মোড কাজ করবে, ক্লাউড সিঙ্ক নিষ্ক্রিয় থাকবে।',
    signInCancelled: 'সাইন ইন বাতিল হয়েছে।',
    consentTitle: 'আপনার ডেটা, আপনার সিদ্ধান্ত',
    consentSubtitle: 'সহজ ভাষা — কোনো লুকানো শর্ত নেই।',
    consentReadTitle: 'আমরা কী পড়ি',
    consentReadBody: 'শুধুমাত্র আপনার নির্বাচিত অ্যাপগুলির নোটিফিকেশন।',
    consentLocalTitle: 'ফোনে কী থাকে',
    consentLocalBody: 'সবকিছু প্রথমে আপনার ডিভাইসে স্থানীয়ভাবে বিশ্লেষণ করা হয়।',
    consentLeavesTitle: 'ফোন থেকে কী বাইরে যায়',
    consentLeavesBody: 'শুধুমাত্র ঝুঁকিপূর্ণ হিসেবে চিহ্নিত বার্তাগুলি আপনার সম্মতিতে যাচাই করা হয়।',
    consentStorageTitle: 'আমরা কী সংরক্ষণ করি',
    consentStorageBody: 'শুধুমাত্র ফলাফলের একটি ছোট হ্যাশ — আসল বার্তা কখনো নয়।',
    consentAllow: 'AI ডিপ-স্ক্যান অনুমতি দিন',
    consentOfflineOnly: 'শুধুমাত্র অফলাইন যাচাই',
    consentFooter: 'সেটিংসে যেকোনো সময় পরিবর্তন করা যাবে।',
    sentinelTitle: 'Kavach Sentinel চালু করুন',
    sentinelSubtitle: 'ফোন লক থাকলেও ২৪x৭ স্বয়ংক্রিয় সুরক্ষা।',
    sentinelStepNotifAccess: 'নোটিফিকেশন অ্যাক্সেস',
    sentinelStepBattery: 'ব্যাটারি সেভার ছাড়',
    sentinelStepPostNotif: 'ব্যাকগ্রাউন্ড সুরক্ষা সক্রিয় করুন',
    sentinelLater: 'এখনই এড়িয়ে যান',
    sentinelLockedNote: 'সেটিংস → Sentinel Health Center থেকে অনুমতি পরিবর্তন করতে পারেন।',
    sentinelActionGrant: 'অনুমতি দিন',
    sentinelActionGranted: 'অনুমোদিত ✓',
    sentinelActive: 'সক্রিয় ✓',
    sentinelEnable: 'সক্রিয় করুন',
  );

  static const OnboardingStrings gu = OnboardingStrings(
    progressLabel: 'પગલું',
    next: 'આગળ વધો',
    back: 'પાછળ',
    skip: 'હમણાં છોડો',
    finish: 'સેટઅપ પૂર્ણ કરો',
    langTitle: 'તમારી ભાષા પસંદ કરો',
    langSubtitle: 'તમે પછીથી સેટિંગ્સમાં આ બદલી શકો છો.',
    langComingSoonNote: 'સંપૂર્ણ ભાષા સમર્થન ઉપલબ્ધ છે.',
    modeTitle: 'આરામદાયક દૃશ્ય પસંદ કરો',
    modeSubtitle: 'મોટા બટનો અને વૉઇસ મદદ એક ટેપ પર.',
    modeStandardTitle: 'સામાન્ય',
    modeStandardBullets: <String>[
      'સામાન્ય કદના બટનો અને ટેક્સ્ટ',
      'કૉમ્પેક્ટ હોમ સ્ક્રીન',
    ],
    modeElderTitle: 'વરિષ્ઠ મોડ',
    modeElderBullets: <String>[
      'મોટો ટેક્સ્ટ (1.4×)',
      'મોટા બટનો (64 dp)',
      'ડિફૉલ્ટ વૉઇસ સમજૂતી',
    ],
    modePreviewSample: 'ડિજિટલ કવચ તમને છેતરપિંડીથી સુરક્ષિત રાખે છે.',
    signInTitle: 'સાઇન ઇન કરો',
    signInSubtitle: 'સાઇન ઇન કરવાથી ફેમિલી શિલ્ડ કાર્ય કરે છે.',
    signInGoogle: 'Google સાથે ચાલુ રાખો',
    signInGuest: 'સાઇન ઇન કર્યા વિના પ્રયાસ કરો',
    signInGuestNote: 'ગેસ્ટ મોડ ચાલશે, ક્લાઉડ સિંક બંધ રહેશે.',
    signInCancelled: 'સાઇન ઇન રદ કરવામાં આવ્યું.',
    consentTitle: 'તમારો ડેટા, તમારી પસંદગી',
    consentSubtitle: 'સરળ ભાષા — કોઈ છુપી શરતો નથી.',
    consentReadTitle: 'અમે શું વાંચીએ છીએ',
    consentReadBody: 'માત્ર તમે પસંદ કરેલ એપ્લિકેશન્સના નોટિફિકેશન.',
    consentLocalTitle: 'ફોનમાં શું રહે છે',
    consentLocalBody: 'બધું વિશ્લેષણ તમારા ફોન પર સ્થાનિક રીતે થાય છે.',
    consentLeavesTitle: 'ફોનમાંથી શું બહાર જાય છે',
    consentLeavesBody: 'માત્ર જોખમી સંદેશાઓ તમારી સંમતિથી AI ચકાસણી માટે જાય છે.',
    consentStorageTitle: 'અમે શું સંગ્રહિત કરીએ છીએ',
    consentStorageBody: 'માત્ર પરિણામની નાની ફિંગરપ્રિન્ટ (hash) — મૂળ સંદેશ ક્યારેય નહીં.',
    consentAllow: 'AI ડીપ-સ્કેનને મંજૂરી આપો',
    consentOfflineOnly: 'માત્ર ઑફલાઇન ચકાસણી',
    consentFooter: 'સેટિંગ્સમાં ગમે ત્યારે બદલી શકાય છે.',
    sentinelTitle: 'Kavach Sentinel ચાલુ કરો',
    sentinelSubtitle: 'ફોન લૉક હોય ત્યારે પણ 24x7 આપોઆપ રક્ષણ.',
    sentinelStepNotifAccess: 'નોટિફિકેશન એક્સેસ',
    sentinelStepBattery: 'બેટરી સેવર મુક્તિ',
    sentinelStepPostNotif: 'બેકગ્રાઉન્ડ સુરક્ષા સક્ષમ કરો',
    sentinelLater: 'હમણાં છોડો',
    sentinelLockedNote: 'સેટિંગ્સ → Sentinel Health Center માંથી બદલી શકાય છે.',
    sentinelActionGrant: 'પરવાનગી આપો',
    sentinelActionGranted: 'મંજૂર ✓',
    sentinelActive: 'સક્રિય ✓',
    sentinelEnable: 'સક્ષમ કરો',
  );

  static const OnboardingStrings kn = OnboardingStrings(
    progressLabel: 'ಹಂತ',
    next: 'ಮುಂದೆ',
    back: 'ಹಿಂದೆ',
    skip: 'ಈಗ ಬಿಟ್ಟುಬಿಡಿ',
    finish: 'ಸೆಟಪ್ ಪೂರ್ಣಗೊಳಿಸಿ',
    langTitle: 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    langSubtitle: 'ನೀವು ಇದನ್ನು ನಂತರ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಬದಲಾಯಿಸಬಹುದು.',
    langComingSoonNote: 'ಸಂಪೂರ್ಣ ಭಾಷಾ ಬೆಂಬಲ ಸಕ್ರಿಯವಾಗಿದೆ.',
    modeTitle: 'ಆರಾಮದಾಯಕ ವೀಕ್ಷಣೆಯನ್ನು ಆರಿಸಿ',
    modeSubtitle: 'ದೊಡ್ಡ ಬಟನ್‌ಗಳು ಮತ್ತು ಧ್ವನಿ ಸಹಾಯ ಲಭ್ಯವಿದೆ.',
    modeStandardTitle: 'ಸಾಮಾನ್ಯ',
    modeStandardBullets: <String>[
      'ಸಾಮಾನ್ಯ ಗಾತ್ರದ ಬಟನ್‌ಗಳು ಮತ್ತು ಪಠ್ಯ',
      'ಕಾಂಪ್ಯಾಕ್ಟ್ ಮುಖಪುಟ ಪರದೆ',
    ],
    modeElderTitle: 'ಹಿರಿಯರ ಮೋಡ್',
    modeElderBullets: <String>[
      'ದೊಡ್ಡ ಪಠ್ಯ (1.4×)',
      'ದೊಡ್ಡ ಬಟನ್‌ಗಳು (64 dp)',
      'ಡೀಫಾಲ್ಟ್ ಧ್ವನಿ ವಿವರಣೆ',
    ],
    modePreviewSample: 'ಡಿಜಿಟಲ್ ಕವಚ ನಿಮ್ಮನ್ನು ವಂಚನೆಗಳಿಂದ ರಕ್ಷಿಸುತ್ತದೆ.',
    signInTitle: 'ಸೈನ್ ಇನ್ ಮಾಡಿ',
    signInSubtitle: 'ಸೈನ್ ಇನ್ ಮಾಡುವುದರಿಂದ ಫ್ಯಾಮಿಲಿ ಶೀಲ್ಡ್ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ.',
    signInGoogle: 'Google ನೊಂದಿಗೆ ಮುಂದುವರಿಯಿರಿ',
    signInGuest: 'ಸೈನ್ ಇನ್ ಇಲ್ಲದೆ ಪ್ರಯತ್ನಿಸಿ',
    signInGuestNote: 'ಅತಿಥಿ ಮೋಡ್ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ, ಕ್ಲೌಡ್ ಸಿಂಕ್ ನಿಷ್ಕ್ರಿಯಗೊಳ್ಳುತ್ತದೆ.',
    signInCancelled: 'ಸೈನ್ ಇನ್ ರದ್ದುಗೊಂಡಿದೆ.',
    consentTitle: 'ನಿಮ್ಮ ಡೇಟಾ, ನಿಮ್ಮ ಆಯ್ಕೆ',
    consentSubtitle: 'ಸರಳ ಭಾಷೆ — ಯಾವುದೇ ಗುಪ್ತ ನಿಯಮಗಳಿಲ್ಲ.',
    consentReadTitle: 'ನಾವು ಏನನ್ನು ಓದುತ್ತೇವೆ',
    consentReadBody: 'ನೀವು ಆಯ್ಕೆಮಾಡಿದ ಅಪ್ಲಿಕೇಶನ್‌ಗಳ ಅಧಿಸೂಚನೆಗಳು ಮಾತ್ರ.',
    consentLocalTitle: 'ಫೋನ್‌ನಲ್ಲಿ ಏನು ಉಳಿಯುತ್ತದೆ',
    consentLocalBody: 'ಎಲ್ಲಾ ವಿಶ್ಲೇಷಣೆ ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲಿ ಸ್ಥಳೀಯವಾಗಿ ನಡೆಯುತ್ತದೆ.',
    consentLeavesTitle: 'ಫೋನ್‌ನಿಂದ ಏನು ಹೊರಹೋಗುತ್ತದೆ',
    consentLeavesBody: 'ಅಪಾಯಕಾರಿ ಸಂದೇಶಗಳು ಮಾತ್ರ ನಿಮ್ಮ ಅನುಮತಿಯೊಂದಿಗೆ ಪರಿಶೀಲನೆಗೆ ಹೋಗುತ್ತವೆ.',
    consentStorageTitle: 'ನಾವು ಏನನ್ನು ಸಂಗ್ರಹಿಸುತ್ತೇವೆ',
    consentStorageBody: 'ಫಲಿತಾಂಶದ ಸಣ್ಣ ಫಿಂಗರ್‌ಪ್ರಿಂಟ್ (hash) ಮಾತ್ರ — ಮೂಲ ಸಂದೇಶವಲ್ಲ.',
    consentAllow: 'AI ಡೀಪ್ ಸ್ಕ್ಯಾನ್ ಅನುಮತಿಸಿ',
    consentOfflineOnly: 'ಆಫ್‌ಲೈನ್ ಪರಿಶೀಲನೆ ಮಾತ್ರ',
    consentFooter: 'ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಯಾವಾಗ ಬೇಕಾದರೂ ಬದಲಾಯಿಸಬಹುದು.',
    sentinelTitle: 'Kavach Sentinel ಆನ್ ಮಾಡಿ',
    sentinelSubtitle: 'ಫೋನ್ ಲಾಕ್ ಆಗಿದ್ದರೂ 24x7 ಸ್ವಯಂಚಾಲಿತ ರಕ್ಷಣೆ.',
    sentinelStepNotifAccess: 'ಅಧಿಸೂಚನೆ ಪ್ರವೇಶ',
    sentinelStepBattery: 'ಬ್ಯಾಟರಿ ಉಳಿತಾಯ ವಿನಾಯಿತಿ',
    sentinelStepPostNotif: 'ಹಿನ್ನೆಲೆ ರಕ್ಷಣೆಯನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ',
    sentinelLater: 'ಈಗ ಬಿಟ್ಟುಬಿಡಿ',
    sentinelLockedNote: 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು → Sentinel Health Center ನಿಂದ ಸರಿಹೊಂದಿಸಬಹುದು.',
    sentinelActionGrant: 'ಅನುಮತಿ ನೀಡಿ',
    sentinelActionGranted: 'ನೀಡಲಾಗಿದೆ ✓',
    sentinelActive: 'ಸಕ್ರಿಯ ✓',
    sentinelEnable: 'ಈಗಲೇ ಸಕ್ರಿಯಗೊಳಿಸಿ',
  );

  static const OnboardingStrings ml = OnboardingStrings(
    progressLabel: 'ഘട്ടം',
    next: 'തുടരുക',
    back: 'പിന്നോട്ട്',
    skip: 'ഇപ്പോൾ ഒഴിവാക്കുക',
    finish: 'സജ്ജീകരണം പൂർത്തിയാക്കുക',
    langTitle: 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക',
    langSubtitle: 'നിങ്ങൾക്ക് ഇത് പിന്നീട് ക്രമീകരണങ്ങളിൽ മാറ്റാം.',
    langComingSoonNote: 'പൂർണ്ണ ഭാഷാ പിന്തുണ പ്രവർത്തനക്ഷമമാണ്.',
    modeTitle: 'സൗകര്യപ്രദമായ കാഴ്ച തിരഞ്ഞെടുക്കുക',
    modeSubtitle: 'വലിയ ബട്ടണുകളും ശബ്ദ സഹായവും ലഭ്യമാണ്.',
    modeStandardTitle: 'സാധാരണ',
    modeStandardBullets: <String>[
      'സാധാരണ വലുപ്പമുള്ള ബട്ടണുകളും വാചകവും',
      'കോംപാക്റ്റ് ഹോം സ്ക്രീൻ',
    ],
    modeElderTitle: 'മുതിർന്നവർക്കുള്ള മോഡ്',
    modeElderBullets: <String>[
      'വലിയ വാചകം (1.4×)',
      'വലിയ ബട്ടണുകൾ (64 dp)',
      'സ്വതവേയുള്ള ശബ്ദ വിശദീകരണങ്ങൾ',
    ],
    modePreviewSample: 'ഡിജിറ്റൽ കവച് നിങ്ങളെ തട്ടിപ്പുകളിൽ നിന്ന് സംരക്ഷിക്കുന്നു.',
    signInTitle: 'സൈൻ ഇൻ ചെയ്യുക',
    signInSubtitle: 'സൈൻ ഇൻ ചെയ്യുന്നത് ഫാമിലി ഷീൽഡ് പ്രവർത്തനക്ഷമമാക്കുന്നു.',
    signInGoogle: 'Google ഉപയോഗിച്ച് തുടരുക',
    signInGuest: 'സൈൻ ഇൻ ചെയ്യാതെ ശ്രമിക്കുക',
    signInGuestNote: 'ഗസ്റ്റ് മോഡ് പ്രവർത്തിക്കും, ക്ലൗഡ് സിങ്ക് പ്രവർത്തനരഹിതമാകും.',
    signInCancelled: 'സൈൻ ഇൻ റദ്ദാക്കി.',
    consentTitle: 'നിങ്ങളുടെ ഡാറ്റ, നിങ്ങളുടെ തീരുമാനം',
    consentSubtitle: 'ലളിതമായ ഭാഷ — മറഞ്ഞിരിക്കുന്ന നിബന്ധനകളില്ല.',
    consentReadTitle: 'ഞങ്ങൾ എന്താണ് വായിക്കുന്നത്',
    consentReadBody: 'നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന ആപ്പുകളുടെ അറിയിപ്പുകൾ മാത്രം.',
    consentLocalTitle: 'ഫോണിൽ എന്താണ് അവശേഷിക്കുന്നത്',
    consentLocalBody: 'എല്ലാ വിശകലനങ്ങളും നിങ്ങളുടെ ഫോണിൽ പ്രാദേശികമായി നടക്കുന്നു.',
    consentLeavesTitle: 'ഫോണിൽ നിന്ന് എന്താണ് പുറത്തുപോകുന്നത്',
    consentLeavesBody: 'അപകടസാധ്യതയുള്ള സന്ദേശങ്ങൾ മാത്രമേ നിങ്ങളുടെ അനുമതിയോടെ പരിശോധിക്കൂ.',
    consentStorageTitle: 'ഞങ്ങൾ എന്താണ് സംഭരിക്കുന്നത്',
    consentStorageBody: 'ഫലത്തിന്റെ ചെറിയ വിരലടയാളം (hash) മാത്രം — യഥാർത്ഥ സന്ദേശമല്ല.',
    consentAllow: 'AI ഡീപ് സ്കാൻ അനുവദിക്കുക',
    consentOfflineOnly: 'ഓഫ്‌ലൈൻ പരിശോധന മാത്രം',
    consentFooter: 'ക്രമീകരണങ്ങളിൽ എപ്പോൾ വേണമെങ്കിലും മാറ്റാം.',
    sentinelTitle: 'Kavach Sentinel ഓൺ ചെയ്യുക',
    sentinelSubtitle: 'ഫോൺ ലോക്കായിരിക്കുമ്പോഴും 24x7 സ്വയമേവയുള്ള സംരക്ഷണം.',
    sentinelStepNotifAccess: 'അറിയിപ്പ് അനുമതി',
    sentinelStepBattery: 'ബാറ്ററി സേവർ ഇളവ്',
    sentinelStepPostNotif: 'പശ്ചാത്തല സംരക്ഷണം പ്രവർത്തനക്ഷമമാക്കുക',
    sentinelLater: 'ഇപ്പോൾ ഒഴിവാക്കുക',
    sentinelLockedNote: 'ക്രമീകരണങ്ങൾ → Sentinel Health Center വഴി മാറ്റാം.',
    sentinelActionGrant: 'അനുമതി നൽകുക',
    sentinelActionGranted: 'നൽകി ✓',
    sentinelActive: 'സജീവം ✓',
    sentinelEnable: 'പ്രവർത്തനക്ഷമമാക്കുക',
  );

  static const OnboardingStrings pa = OnboardingStrings(
    progressLabel: 'ਕਦਮ',
    next: 'ਅੱਗੇ ਵਧੋ',
    back: 'ਪਿੱਛੇ',
    skip: 'ਹੁਣ ਛੱਡੋ',
    finish: 'ਸੈੱਟਅੱਪ ਪੂਰਾ ਕਰੋ',
    langTitle: 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ',
    langSubtitle: 'ਤੁਸੀਂ ਇਸਨੂੰ ਬਾਅਦ ਵਿੱਚ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਬਦਲ ਸਕਦੇ ਹੋ।',
    langComingSoonNote: 'ਪੂਰਾ ਭਾਸ਼ਾ ਸਮਰਥਨ ਕਿਰਿਆਸ਼ੀਲ ਹੈ।',
    modeTitle: 'ਇੱਕ ਆਰਾਮਦਾਇਕ ਦ੍ਰਿਸ਼ ਚੁਣੋ',
    modeSubtitle: 'ਵੱਡੇ ਬਟਨ ਅਤੇ ਆਵਾਜ਼ ਸਹਾਇਤਾ ਇੱਕ ਟੈਪ ਦੂਰ।',
    modeStandardTitle: 'ਸਧਾਰਨ',
    modeStandardBullets: <String>[
      'ਆਮ ਆਕਾਰ ਦੇ ਬਟਨ ਅਤੇ ਟੈਕਸਟ',
      'ਕੌਮਪੈਕਟ ਹੋਮ ਸਕ੍ਰੀਨ',
    ],
    modeElderTitle: 'ਬਜ਼ੁਰਗ ਮੋਡ',
    modeElderBullets: <String>[
      'ਵੱਡਾ ਟੈਕਸਟ (1.4×)',
      'ਵੱਡੇ ਬਟਨ (64 dp)',
      'ਡਿਫੌਲਟ ਆਵਾਜ਼ ਵਿਆਖਿਆ',
    ],
    modePreviewSample: 'ਡਿਜੀਟਲ ਕਵਚ ਤੁਹਾਨੂੰ ਘੁਟਾਲਿਆਂ ਤੋਂ ਬਚਾਉਂਦਾ ਹੈ।',
    signInTitle: 'ਸਾਈਨ ਇਨ ਕਰੋ',
    signInSubtitle: 'ਸਾਈਨ ਇਨ ਕਰਨ ਨਾਲ ਫੈਮਿਲੀ ਸ਼ੀਲਡ ਕੰਮ ਕਰਦੀ ਹੈ।',
    signInGoogle: 'Google ਨਾਲ ਜਾਰੀ ਰੱਖੋ',
    signInGuest: 'ਬਿਨਾਂ ਸਾਈਨ ਇਨ ਦੇ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
    signInGuestNote: 'ਗੈਸਟ ਮੋਡ ਕੰਮ ਕਰੇਗਾ, ਕਲਾਉਡ ਸਿੰਕ ਬੰਦ ਰਹੇਗਾ।',
    signInCancelled: 'ਸਾਈਨ ਇਨ ਰੱਦ ਕੀਤਾ ਗਿਆ।',
    consentTitle: 'ਤੁਹਾਡਾ ਡੇਟਾ, ਤੁਹਾਡਾ ਫੈਸਲਾ',
    consentSubtitle: 'ਸਰਲ ਭਾਸ਼ਾ — ਕੋਈ ਲੁਕਵੀਂ ਸ਼ਰਤ ਨਹੀਂ।',
    consentReadTitle: 'ਅਸੀਂ ਕੀ ਪੜ੍ਹਦੇ ਹਾਂ',
    consentReadBody: 'ਸਿਰਫ਼ ਤੁਹਾਡੀਆਂ ਚੁਣੀਆਂ ਗਈਆਂ ਐਪਾਂ ਦੀਆਂ ਸੂਚਨਾਵਾਂ।',
    consentLocalTitle: 'ਫ਼ੋਨ ਵਿੱਚ ਕੀ ਰਹਿੰਦਾ ਹੈ',
    consentLocalBody: 'ਸਾਰਾ ਵਿਸ਼ਲੇਸ਼ਣ ਤੁਹਾਡੇ ਫ਼ੋਨ ਉੱਤੇ ਸਥਾਨਕ ਤੌਰ ਉੱਤੇ ਹੁੰਦਾ ਹੈ।',
    consentLeavesTitle: 'ਫ਼ੋਨ ਤੋਂ ਬਾਹਰ ਕੀ ਜਾਂਦਾ ਹੈ',
    consentLeavesBody: 'ਸਿਰਫ਼ ਖ਼ਤਰਨਾਕ ਸੁਨੇਹੇ ਤੁਹਾਡੀ ਇਜਾਜ਼ਤ ਨਾਲ AI ਕੋਲ ਜਾਂਦੇ ਹਨ।',
    consentStorageTitle: 'ਅਸੀਂ ਕੀ ਸਟੋਰ ਕਰਦੇ ਹਾਂ',
    consentStorageBody: 'ਸਿਰਫ਼ ਨਤੀਜੇ ਦਾ ਇੱਕ ਛੋਟਾ ਹੈਸ਼ — ਅਸਲ ਸੁਨੇਹਾ ਕਦੇ ਨਹੀਂ।',
    consentAllow: 'AI ਡੀਪ-ਸਕੈਨ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ',
    consentOfflineOnly: 'ਸਿਰਫ਼ ਔਫਲਾਈਨ ਜਾਂਚ',
    consentFooter: 'ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਕਿਸੇ ਵੀ ਸਮੇਂ ਬਦਲਿਆ ਜਾ ਸਕਦਾ ਹੈ।',
    sentinelTitle: 'Kavach Sentinel ਚਾਲੂ ਕਰੋ',
    sentinelSubtitle: 'ਫ਼ੋਨ ਲਾਕ ਹੋਣ ਤੇ ਵੀ 24x7 ਸਵੈਚਾਲਤ ਸੁਰੱਖਿਆ।',
    sentinelStepNotifAccess: 'ਸੂਚਨਾ ਪਹੁੰਚ',
    sentinelStepBattery: 'ਬੈਟਰੀ ਸੇਵਰ ਛੋਟ',
    sentinelStepPostNotif: 'ਬੈਕਗ੍ਰਾਊਂਡ ਸੁਰੱਖਿਆ ਸਮਰੱਥ ਕਰੋ',
    sentinelLater: 'ਹੁਣ ਛੱਡੋ',
    sentinelLockedNote: 'ਸੈਟਿੰਗਾਂ → Sentinel Health Center ਤੋਂ ਬਦਲ ਸਕਦੇ ਹੋ।',
    sentinelActionGrant: 'ਇਜਾਜ਼ਤ ਦਿਓ',
    sentinelActionGranted: 'ਮਨਜ਼ੂਰ ✓',
    sentinelActive: 'ਕਿਰਿਆਸ਼ੀਲ ✓',
    sentinelEnable: 'ਸਮਰੱਥ ਕਰੋ',
  );

  /// Resolves the OnboardingStrings instance for the chosen locale.
  static OnboardingStrings forLocale(AppLocale locale) {
    switch (locale) {
      case AppLocale.hi:
        return hi;
      case AppLocale.mr:
        return mr;
      case AppLocale.ta:
        return ta;
      case AppLocale.te:
        return te;
      case AppLocale.bn:
        return bn;
      case AppLocale.gu:
        return gu;
      case AppLocale.kn:
        return kn;
      case AppLocale.ml:
        return ml;
      case AppLocale.pa:
        return pa;
      case AppLocale.en:
        return en;
    }
  }
}

/// Global provider for onboarding screen strings.
final Provider<OnboardingStrings> onboardingStringsProvider =
Provider<OnboardingStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return OnboardingStrings.forLocale(locale);
});

/// The 10 languages users can pick from during onboarding (blueprint §2.1).
@immutable
class SupportedLanguage {
  const SupportedLanguage(this.code, this.nativeName, this.englishName);
  final String code;
  final String nativeName;
  final String englishName;

  bool get hasFullUiSupport => code == 'en' || code == 'hi' || code == 'mr';

  AppLocale toAppLocale() {
    switch (code) {
      case 'hi':
        return AppLocale.hi;
      case 'mr':
        return AppLocale.mr;
      default:
        return AppLocale.en;
    }
  }

  static const List<SupportedLanguage> all = <SupportedLanguage>[
    SupportedLanguage('en', 'English', 'English'),
    SupportedLanguage('hi', 'हिन्दी', 'Hindi'),
    SupportedLanguage('mr', 'मराठी', 'Marathi'),
    SupportedLanguage('ta', 'தமிழ்', 'Tamil'),
    SupportedLanguage('te', 'తెలుగు', 'Telugu'),
    SupportedLanguage('bn', 'বাংলা', 'Bengali'),
    SupportedLanguage('gu', 'ગુજરાતી', 'Gujarati'),
    SupportedLanguage('kn', 'ಕನ್ನಡ', 'Kannada'),
    SupportedLanguage('ml', 'മലയാളം', 'Malayalam'),
    SupportedLanguage('pa', 'ਪੰਜਾਬੀ', 'Punjabi'),
  ];

  static SupportedLanguage byCode(String code) => all.firstWhere(
        (SupportedLanguage l) => l.code == code,
    orElse: () => all.first,
  );
}