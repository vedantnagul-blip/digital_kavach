import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class SettingsStrings {
  const SettingsStrings({
    required this.appBarTitle,
    required this.sectionAppearance,
    required this.appLanguage,
    required this.elderMode,
    required this.elderModeSubtitle,
    required this.darkMode,
    required this.sectionProtection,
    required this.sentinelHealth,
    required this.sentinelHealthSubtitle,
    required this.activityFeed,
    required this.activityFeedSubtitle,
    required this.scannerHub,
    required this.scannerHubSubtitle,
    required this.sectionEmergency,
    required this.recoveryCopilot,
    required this.recoveryCopilotSubtitle,
    required this.sectionPrivacy,
    required this.clearCache,
    required this.clearCacheSubtitle,
    required this.cacheCleared,
    required this.appVersion,
    required this.appVersionSubtitle,
    required this.licenses,
    required this.selectLanguage,
  });

  final String appBarTitle;
  final String sectionAppearance;
  final String appLanguage;
  final String elderMode;
  final String elderModeSubtitle;
  final String darkMode;
  final String sectionProtection;
  final String sentinelHealth;
  final String sentinelHealthSubtitle;
  final String activityFeed;
  final String activityFeedSubtitle;
  final String scannerHub;
  final String scannerHubSubtitle;
  final String sectionEmergency;
  final String recoveryCopilot;
  final String recoveryCopilotSubtitle;
  final String sectionPrivacy;
  final String clearCache;
  final String clearCacheSubtitle;
  final String cacheCleared;
  final String appVersion;
  final String appVersionSubtitle;
  final String licenses;
  final String selectLanguage;

  static const SettingsStrings en = SettingsStrings(
    appBarTitle: 'Settings & Navigation Hub',
    sectionAppearance: 'Appearance & Accessibility',
    appLanguage: 'App Language',
    elderMode: 'Elder Mode',
    elderModeSubtitle: 'Bigger text and buttons',
    darkMode: 'Dark Mode',
    sectionProtection: 'Protection & Sentinel',
    sentinelHealth: 'Sentinel Health Center',
    sentinelHealthSubtitle: 'Uptime, gap logs, OEM battery settings',
    activityFeed: 'Activity Feed',
    activityFeedSubtitle: 'Live alert log and scan history',
    scannerHub: 'Scanner Hub',
    scannerHubSubtitle: 'Text, screenshot OCR, and QR scanner',
    sectionEmergency: 'Emergency Recovery',
    recoveryCopilot: 'Golden Hour Recovery Copilot',
    recoveryCopilotSubtitle: '1930 helpline, bank complaint, FIR generator',
    sectionPrivacy: 'Privacy & Data',
    clearCache: 'Clear Local Verdict Cache',
    clearCacheSubtitle: 'Frees up on-device storage space',
    cacheCleared: 'Local cache cleared successfully',
    appVersion: 'App Version',
    appVersionSubtitle: '1.0.0 (Production Build)',
    licenses: 'Open Source Licenses',
    selectLanguage: 'Select Language',
  );

  static const SettingsStrings hi = SettingsStrings(
    appBarTitle: 'सेटिंग्स और नेविगेशन',
    sectionAppearance: 'दिखावट और सुगमता',
    appLanguage: 'ऐप की भाषा',
    elderMode: 'बुज़ुर्ग मोड',
    elderModeSubtitle: 'बड़े अक्षर और बड़े बटन',
    darkMode: 'डार्क मोड',
    sectionProtection: 'सुरक्षा और प्रहरी',
    sentinelHealth: 'सेंटिनल स्वास्थ्य केंद्र',
    sentinelHealthSubtitle: 'अप-टाइम, बैटरी सेटिंग और लॉग',
    activityFeed: 'गतिविधि लॉग',
    activityFeedSubtitle: 'चेतावनी इतिहास और स्कैन रिकॉर्ड',
    scannerHub: 'स्कैनर हब',
    scannerHubSubtitle: 'टेक्स्ट, स्क्रीनशॉट ओसीआर व क्यूआर स्कैनर',
    sectionEmergency: 'आपातकालीन सहायता',
    recoveryCopilot: 'गोल्डन आवर रिकवरी',
    recoveryCopilotSubtitle: '1930 हेल्पलाइन, बैंक शिकायत व एफआईआर ड्राफ्ट',
    sectionPrivacy: 'गोपनीयता और डेटा',
    clearCache: 'लोकल कैश साफ़ करें',
    clearCacheSubtitle: 'फ़ोन का स्टोरेज खाली करें',
    cacheCleared: 'कैश सफलतापूर्वक साफ़ किया गया',
    appVersion: 'ऐप संस्करण',
    appVersionSubtitle: '1.0.0 (प्रोडक्शन संस्करण)',
    licenses: 'ओपन सोर्स लाइसेंस',
    selectLanguage: 'भाषा चुनें',
  );

  static const SettingsStrings mr = SettingsStrings(
    appBarTitle: 'सेटिंग्ज आणि नेव्हिगेशन',
    sectionAppearance: 'दिसणे आणि सुलभता',
    appLanguage: 'अ‍ॅपची भाषा',
    elderMode: 'ज्येष्ठ मोड',
    elderModeSubtitle: 'मोठा मजकूर आणि मोठी बटणे',
    darkMode: 'डार्क मोड',
    sectionProtection: 'संरक्षण आणि सेंटिनेल',
    sentinelHealth: 'सेंटिनेल आरोग्य केंद्र',
    sentinelHealthSubtitle: 'अप-टाइम, बॅटरी सेटिंग्ज आणि लॉग',
    activityFeed: 'क्रियाकलाप नोंद',
    activityFeedSubtitle: 'इशारे इतिहास आणि स्कॅन नोंदणी',
    scannerHub: 'स्कॅनर हब',
    scannerHubSubtitle: 'मजकूर, स्क्रीनशॉट ओसीआर आणि क्यूआर स्कॅनर',
    sectionEmergency: 'तातडीची मदत',
    recoveryCopilot: 'गोल्डन अवर रिकव्हरी',
    recoveryCopilotSubtitle: '1930 हेल्पलाइन, बँक तक्रार आणि एफआयआर ड्राफ्ट',
    sectionPrivacy: 'गोपनीयता आणि डेटा',
    clearCache: 'लोकल कॅशे साफ करा',
    clearCacheSubtitle: 'फोनमधील जागा मोकळी करा',
    cacheCleared: 'कॅशे यशस्वीरित्या साफ केले',
    appVersion: 'अ‍ॅप आवृत्ती',
    appVersionSubtitle: '1.0.0 (उत्पादन आवृत्ती)',
    licenses: 'ओपन सोर्स परवाने',
    selectLanguage: 'भाषा निवडा',
  );

  static const SettingsStrings ta = SettingsStrings(
    appBarTitle: 'அமைப்புகள் மற்றும் வழிசெலுத்தல்',
    sectionAppearance: 'தோற்றம் மற்றும் அணுகல்',
    appLanguage: 'பயன்பாட்டு மொழி',
    elderMode: 'முதியோர் முறைமை',
    elderModeSubtitle: 'பெரிய உரை மற்றும் பெரிய பொத்தான்கள்',
    darkMode: 'இருண்ட பயன்முறை',
    sectionProtection: 'பாதுகாப்பு & சென்டினல்',
    sentinelHealth: 'சென்டினல் சுகாதார மையம்',
    sentinelHealthSubtitle: 'செயல்நேரம், பேட்டரி அமைப்புகள்',
    activityFeed: 'செயல்பாட்டு ஊட்டம்',
    activityFeedSubtitle: 'நேரலை எச்சரிக்கை பதிவு மற்றும் ஸ்கேன் வரலாறு',
    scannerHub: 'ஸ்கேனர் மையம்',
    scannerHubSubtitle: 'உரை, திரைக்காட்சி மற்றும் QR ஸ்கேனர்',
    sectionEmergency: 'அவசர மீட்பு',
    recoveryCopilot: 'கோல்டன் ஹவர் மீட்பு',
    recoveryCopilotSubtitle: '1930 உதவி எண், வங்கி புகார் மற்றும் FIR வரைவு',
    sectionPrivacy: 'தனியுரிமை மற்றும் தரவு',
    clearCache: 'தற்காலிக சேமிப்பை அழிக்கவும்',
    clearCacheSubtitle: 'சாதன சேமிப்பிடத்தை விடுவிக்கிறது',
    cacheCleared: 'தற்காலிக சேமிப்பு அழிக்கப்பட்டது',
    appVersion: 'பயன்பாட்டு பதிப்பு',
    appVersionSubtitle: '1.0.0 (தயாரிப்பு பதிப்பு)',
    licenses: 'திறந்த மூல உரிமங்கள்',
    selectLanguage: 'மொழியைத் தேர்ந்தெடுக்கவும்',
  );

  static const SettingsStrings te = SettingsStrings(
    appBarTitle: 'సెట్టింగ్‌లు & నావిగేషన్',
    sectionAppearance: 'స్వరూపం & ప్రాప్యత',
    appLanguage: 'యాప్ భాష',
    elderMode: 'సీనియర్ మోడ్',
    elderModeSubtitle: 'పెద్ద అక్షరాలు మరియు పెద్ద బటన్లు',
    darkMode: 'డార్క్ మోడ్',
    sectionProtection: 'రక్షణ & సెంటినెల్',
    sentinelHealth: 'సెంటినెల్ హెల్త్ సెంటర్',
    sentinelHealthSubtitle: 'అప్‌టైమ్, బ్యాటరీ సెట్టింగ్‌లు',
    activityFeed: 'యాక్టివిటీ ఫీడ్',
    activityFeedSubtitle: 'లైవ్ హెచ్చరిక లాగ్ మరియు స్కాన్ చరిత్ర',
    scannerHub: 'స్కానర్ హబ్',
    scannerHubSubtitle: 'టెక్స్ట్, స్క్రీన్‌షాట్ OCR మరియు QR స్కానర్',
    sectionEmergency: 'అత్యవసర పునరుద్ధరణ',
    recoveryCopilot: 'గోల్డెన్ అవర్ రికవరీ',
    recoveryCopilotSubtitle: '1930 హెల్ప్‌లైన్, బ్యాంక్ ఫిర్యాదు & ఎఫ్‌ఐఆర్ డ్రాఫ్ట్',
    sectionPrivacy: 'గోప్యత మరియు డేటా',
    clearCache: 'కాష్ క్లియర్ చేయండి',
    clearCacheSubtitle: 'ఫోన్ నిల్వ స్థలాన్ని ఖాళీ చేస్తుంది',
    cacheCleared: 'కాష్ విజయవంతంగా క్లియర్ చేయబడింది',
    appVersion: 'యాప్ వెర్షన్',
    appVersionSubtitle: '1.0.0 (ప్రొడక్షన్ వెర్షన్)',
    licenses: 'ఓపెన్ సోర్స్ లైసెన్స్‌లు',
    selectLanguage: 'భాషను ఎంచుకోండి',
  );

  static const SettingsStrings bn = SettingsStrings(
    appBarTitle: 'সেটিংস ও নেভিগেশন',
    sectionAppearance: 'রূপ ও অ্যাক্সেসযোগ্যতা',
    appLanguage: 'অ্যাপের ভাষা',
    elderMode: 'প্রবীণ মোড',
    elderModeSubtitle: 'বড় লেখা এবং বড় বোতাম',
    darkMode: 'ডার্ক মোড',
    sectionProtection: 'সুরক্ষা ও সেন্টিনেল',
    sentinelHealth: 'সেন্টিনেল হেলথ সেন্টার',
    sentinelHealthSubtitle: 'আপটাইম, ব্যাটারি সেটিংস ও লগ',
    activityFeed: 'কার্যকলাপ ফিড',
    activityFeedSubtitle: 'সতর্কতা ও স্ক্যান ইতিহাস',
    scannerHub: 'স্ক্যানার হাব',
    scannerHubSubtitle: 'টেক্সট, স্ক্রিনশট এবং কিউআর স্ক্যানার',
    sectionEmergency: 'জরুরী পুনরুদ্ধার',
    recoveryCopilot: 'গোল্ডেন আওয়ার রিকভারি',
    recoveryCopilotSubtitle: '১৯৩০ হেল্পলাইন, ব্যাংক অভিযোগ ও এফআইআর ড্রাফট',
    sectionPrivacy: 'গোপনীয়তা ও ডেটা',
    clearCache: 'লোকাল ক্যাশ মুছুন',
    clearCacheSubtitle: 'ডিভাইস স্টোরেজ খালি করুন',
    cacheCleared: 'ক্যাশ সফলভাবে মুছে ফেলা হয়েছে',
    appVersion: 'অ্যাপ সংস্করণ',
    appVersionSubtitle: '১.০.০ (প্রোডাকশন সংস্করণ)',
    licenses: 'ওপেন সোর্স লাইসেন্স',
    selectLanguage: 'ভাষা নির্বাচন করুন',
  );

  static const SettingsStrings gu = SettingsStrings(
    appBarTitle: 'સેટિંગ્સ અને નેવિગેશન',
    sectionAppearance: 'દેખાવ અને સુલભતા',
    appLanguage: 'એપ્લિકેશન ભાષા',
    elderMode: 'વરિષ્ઠ મોડ',
    elderModeSubtitle: 'મોટા અક્ષરો અને મોટા બટનો',
    darkMode: 'ડાર્ક મોડ',
    sectionProtection: 'સુરક્ષા અને સેન્ટિનલ',
    sentinelHealth: 'સેન્ટિનલ હેલ્થ સેન્ટર',
    sentinelHealthSubtitle: 'અપટાઇમ, બેટરી સેટિંગ્સ',
    activityFeed: 'પ્રવૃત્તિ ફીડ',
    activityFeedSubtitle: 'ચેતવણી ઇતિહાસ અને સ્કેન રેકોર્ડ',
    scannerHub: 'સ્કેનર હબ',
    scannerHubSubtitle: 'ટેક્સ્ટ, સ્ક્રીનશોટ અને ક્યૂઆર સ્કેનર',
    sectionEmergency: 'ઇમરજન્સી રિકવરી',
    recoveryCopilot: 'ગોલ્ડન અવર રિકવરી',
    recoveryCopilotSubtitle: '1930 હેલ્પલાઇન, બેંક ફરિયાદ અને એફઆઈઆર ડ્રાફ્ટ',
    sectionPrivacy: 'ગોપનીયતા અને ડેટા',
    clearCache: 'કેશ સાફ કરો',
    clearCacheSubtitle: 'ફોન સ્ટોરેજ ખાલી કરે છે',
    cacheCleared: 'કેશ સફળતાપૂર્વક સાફ થઈ ગઈ',
    appVersion: 'એપ્લિકેશન આવૃત્તિ',
    appVersionSubtitle: '1.0.0 (પ્રોડક્શન આવૃત્તિ)',
    licenses: 'ઓપન સોર્સ લાઇસન્સ',
    selectLanguage: 'ભાષા પસંદ કરો',
  );

  static const SettingsStrings kn = SettingsStrings(
    appBarTitle: 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಮತ್ತು ನ್ಯಾವಿಗೇಷನ್',
    sectionAppearance: 'ಗೋಚರತೆ ಮತ್ತು ಪ್ರವೇಶಿಸುವಿಕೆ',
    appLanguage: 'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ',
    elderMode: 'ಹಿರಿಯರ ಮೋಡ್',
    elderModeSubtitle: 'ದೊಡ್ಡ ಪಠ್ಯ ಮತ್ತು ದೊಡ್ಡ ಬಟನ್‌ಗಳು',
    darkMode: 'ಡಾರ್ಕ್ ಮೋಡ್',
    sectionProtection: 'ರಕ್ಷಣೆ ಮತ್ತು ಸೆಂಟಿನೆಲ್',
    sentinelHealth: 'ಸೆಂಟಿನೆಲ್ ಹೆಲ್ತ್ ಸೆಂಟರ್',
    sentinelHealthSubtitle: 'ಅಪ್‌ಟೈಮ್, ಬ್ಯಾಟರಿ ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    activityFeed: 'ಚಟುವಟಿಕೆ ಫೀಡ್',
    activityFeedSubtitle: 'ಎಚ್ಚರಿಕೆ ಇತಿಹಾಸ ಮತ್ತು ಸ್ಕ್ಯಾನ್ ದಾಖಲೆಗಳು',
    scannerHub: 'ಸ್ಕ್ಯಾನರ್ ಹಬ್',
    scannerHubSubtitle: 'ಪಠ್ಯ, ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಮತ್ತು ಕ್ಯೂಆರ್ ಸ್ಕ್ಯಾನರ್',
    sectionEmergency: 'ತುರ್ತು ಚೇತರಿಕೆ',
    recoveryCopilot: 'ಗೋಲ್ಡನ್ ಅವರ್ ರಿಕವರಿ',
    recoveryCopilotSubtitle: '1930 ಸಹಾಯವಾಣಿ, ಬ್ಯಾಂಕ್ ದೂರು ಮತ್ತು ಎಫ್‌ಐಆರ್ ಕರಡು',
    sectionPrivacy: 'ಗೌಪ್ಯತೆ ಮತ್ತು ಡೇಟಾ',
    clearCache: 'ಕ್ಯಾಶ್ ತೆರವುಗೊಳಿಸಿ',
    clearCacheSubtitle: 'ಫೋನ್ ಸಂಗ್ರಹಣೆಯನ್ನು ಮುಕ್ತಗೊಳಿಸುತ್ತದೆ',
    cacheCleared: 'ಕ್ಯಾಶ್ ಯಶಸ್ವಿಯಾಗಿ ತೆರವುಗೊಂಡಿದೆ',
    appVersion: 'ಅಪ್ಲಿಕೇಶನ್ ಆವೃತ್ತಿ',
    appVersionSubtitle: '1.0.0 (ಉತ್ಪಾದನಾ ಆವೃತ್ತಿ)',
    licenses: 'ಓಪನ್ ಸೋರ್ಸ್ ಪರವಾನಗಿಗಳು',
    selectLanguage: 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
  );

  static const SettingsStrings ml = SettingsStrings(
    appBarTitle: 'ക്രമീകരണങ്ങളും നാവിഗേഷനും',
    sectionAppearance: 'രൂപവും പ്രവേശനക്ഷമതയും',
    appLanguage: 'ആപ്പ് ഭാഷ',
    elderMode: 'മുതിർന്നവർക്കുള്ള മോഡ്',
    elderModeSubtitle: 'വലിയ അക്ഷരങ്ങളും വലിയ ബട്ടണുകളും',
    darkMode: 'ഡാർക്ക് മോഡ്',
    sectionProtection: 'സംരക്ഷണവും സെന്റിനലും',
    sentinelHealth: 'സെന്റിനൽ ഹെൽത്ത് സെന്റർ',
    sentinelHealthSubtitle: 'അപ്‌ടൈം, ബാറ്ററി ക്രമീകരണങ്ങൾ',
    activityFeed: 'ആക്റ്റിവിറ്റി ഫീഡ്',
    activityFeedSubtitle: 'തത്സമയ മുന്നറിയിപ്പ് ലോഗും സ്കാൻ ചരിത്രവും',
    scannerHub: 'സ്കാനർ ഹബ്ബ്',
    scannerHubSubtitle: 'ടെക്സ്റ്റ്, സ്ക്രീൻഷോട്ട്, ക്യുആർ സ്കാനർ',
    sectionEmergency: 'അടിയന്തര വീണ്ടെടുക്കൽ',
    recoveryCopilot: 'ഗോൾഡൻ അവർ വീണ്ടെടുക്കൽ',
    recoveryCopilotSubtitle: '1930 ഹെൽപ്പ് ലൈൻ, ബാങ്ക് പരാതി, എഫ്.ഐ.ആർ ഡ്രാഫ്റ്റ്',
    sectionPrivacy: 'സ്വകാര്യതയും ഡാറ്റയും',
    clearCache: 'കാഷെ മായ്‌ക്കുക',
    clearCacheSubtitle: 'ഫോൺ സംഭരണം ശൂന്യമാക്കുന്നു',
    cacheCleared: 'കാഷെ വിജയകരമായി മായ്‌ച്ചു',
    appVersion: 'ആപ്പ് പതിപ്പ്',
    appVersionSubtitle: '1.0.0 (പ്രൊഡക്ഷൻ പതിപ്പ്)',
    licenses: 'ഓപ്പൺ സോഴ്സ് ലൈസൻസുകൾ',
    selectLanguage: 'ഭാഷ തിരഞ്ഞെടുക്കുക',
  );

  static const SettingsStrings pa = SettingsStrings(
    appBarTitle: 'ਸੈਟਿੰਗਾਂ ਅਤੇ ਨੇਵੀਗੇਸ਼ਨ',
    sectionAppearance: 'ਦਿੱਖ ਅਤੇ ਪਹੁੰਚਯੋਗਤਾ',
    appLanguage: 'ਐਪ ਦੀ ਭਾਸ਼ਾ',
    elderMode: 'ਬਜ਼ੁਰਗ ਮੋਡ',
    elderModeSubtitle: 'ਵੱਡਾ ਟੈਕਸਟ ਅਤੇ ਵੱਡੇ ਬਟਨ',
    darkMode: 'ਡਾਰਕ ਮੋਡ',
    sectionProtection: 'ਸੁਰੱਖਿਆ ਅਤੇ ਸੈਂਟੀਨੇਲ',
    sentinelHealth: 'ਸੈਂਟੀਨੇਲ ਹੈਲਥ ਸੈਂਟਰ',
    sentinelHealthSubtitle: 'ਅੱਪਟਾਈਮ, ਬੈਟਰੀ ਸੈਟਿੰਗਾਂ',
    activityFeed: 'ਗਤੀਵਿਧੀ ਫੀਡ',
    activityFeedSubtitle: 'ਚੇਤਾਵਨੀ ਇਤਿਹਾਸ ਅਤੇ ਸਕੈਨ ਰਿਕਾਰਡ',
    scannerHub: 'ਸਕੈਨਰ ਹੱਬ',
    scannerHubSubtitle: 'ਟੈਕਸਟ, ਸਕ੍ਰੀਨਸ਼ੌਟ ਅਤੇ ਕਿਊਆਰ ਸਕੈਨਰ',
    sectionEmergency: 'ਐਮਰਜੈਂਸੀ ਰਿਕਵਰੀ',
    recoveryCopilot: 'ਗੋਲਡਨ ਆਵਰ ਰਿਕਵਰੀ',
    recoveryCopilotSubtitle: '1930 ਹੈਲਪਲਾਈਨ, ਬੈਂਕ ਸ਼ਿਕਾਇਤ ਅਤੇ ਐਫਆਈਆਰ ਡਰਾਫਟ',
    sectionPrivacy: 'ਪ੍ਰਾਈਵੇਸੀ ਅਤੇ ਡਾਟਾ',
    clearCache: 'ਕੈਸ਼ ਸਾਫ਼ ਕਰੋ',
    clearCacheSubtitle: 'ਫ਼ੋਨ ਸਟੋਰੇਜ ਖਾਲੀ ਕਰੋ',
    cacheCleared: 'ਕੈਸ਼ ਸਫਲਤਾਪੂਰਵਕ ਸਾਫ਼ ਹੋ ਗਿਆ',
    appVersion: 'ਐਪ ਵਰਜ਼ਨ',
    appVersionSubtitle: '1.0.0 (ਪ੍ਰੋਡਕਸ਼ਨ ਵਰਜ਼ਨ)',
    licenses: 'ਓਪਨ ਸੋਰਸ ਲਾਇਸੰਸ',
    selectLanguage: 'ਭਾਸ਼ਾ ਚੁਣੋ',
  );

  static SettingsStrings forLocale(AppLocale locale) {
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

final Provider<SettingsStrings> settingsStringsProvider =
Provider<SettingsStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return SettingsStrings.forLocale(locale);
});
