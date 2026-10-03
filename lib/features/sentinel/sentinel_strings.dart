import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class SentinelStrings {
  const SentinelStrings({
    required this.feedTitle,
    required this.filterAll,
    required this.filterHighRisk,
    required this.filterSuspicious,
    required this.emptyFeedTitle,
    required this.emptyFeedSubtitle,
    required this.healthTitle,
    required this.serviceActive,
    required this.serviceActiveSubtitle,
    required this.serviceInactive,
    required this.serviceInactiveSubtitle,
    required this.batteryOptimization,
    required this.batteryOptimizationSubtitle,
    required this.notificationPermission,
    required this.notificationPermissionSubtitle,
    required this.grantPermission,
    required this.detailTitle,
    required this.viewEvidence,
    required this.threatDetected,
  });

  final String feedTitle;
  final String filterAll;
  final String filterHighRisk;
  final String filterSuspicious;
  final String emptyFeedTitle;
  final String emptyFeedSubtitle;
  final String healthTitle;
  final String serviceActive;
  final String serviceActiveSubtitle;
  final String serviceInactive;
  final String serviceInactiveSubtitle;
  final String batteryOptimization;
  final String batteryOptimizationSubtitle;
  final String notificationPermission;
  final String notificationPermissionSubtitle;
  final String grantPermission;
  final String detailTitle;
  final String viewEvidence;
  final String threatDetected;

  static const SentinelStrings en = SentinelStrings(
    feedTitle: 'Sentinel Activity Feed',
    filterAll: 'All Scans',
    filterHighRisk: 'High Risk (Red)',
    filterSuspicious: 'Suspicious (Amber)',
    emptyFeedTitle: 'No Alerts Yet',
    emptyFeedSubtitle: 'Messages intercepted from WhatsApp and SMS will appear here.',
    healthTitle: 'Sentinel Health Center',
    serviceActive: 'Sentinel Service is Active',
    serviceActiveSubtitle: 'Monitoring WhatsApp and SMS notifications in real-time.',
    serviceInactive: 'Sentinel Service Inactive',
    serviceInactiveSubtitle: 'Enable notification access to protect your device.',
    batteryOptimization: 'Battery Saver Exemption',
    batteryOptimizationSubtitle: 'Allows background threat checks without being killed by Android.',
    notificationPermission: 'Notification Access',
    notificationPermissionSubtitle: 'Required to scan incoming scam messages.',
    grantPermission: 'Grant Permission',
    detailTitle: 'Alert Details',
    viewEvidence: 'View Intercepted Payload',
    threatDetected: 'Threat Detected',
  );

  static const SentinelStrings hi = SentinelStrings(
    feedTitle: 'प्रहरी गतिविधि लॉग',
    filterAll: 'सभी स्कैन',
    filterHighRisk: 'उच्च जोखिम (लाल)',
    filterSuspicious: 'संदिग्ध (पीला)',
    emptyFeedTitle: 'अभी कोई चेतावनी नहीं है',
    emptyFeedSubtitle: 'व्हाट्सएप और एसएमएस से पकड़े गए संदेश यहाँ दिखाई देंगे।',
    healthTitle: 'सेंटिनल स्वास्थ्य केंद्र',
    serviceActive: 'सेंटिनल सेवा सक्रिय है',
    serviceActiveSubtitle: 'व्हाट्सएप और एसएमएस सूचनाओं की वास्तविक समय में निगरानी हो रही है।',
    serviceInactive: 'सेंटिनल सेवा बंद है',
    serviceInactiveSubtitle: 'अपने फ़ोन की सुरक्षा के लिए नोटिफिकेशन अनुमति दें।',
    batteryOptimization: 'बैटरी सेवर छूट',
    batteryOptimizationSubtitle: 'सुरक्षा सेवा को बैकग्राउंड में चालू रखने के लिए आवश्यक है।',
    notificationPermission: 'नोटिफिकेशन एक्सेस',
    notificationPermissionSubtitle: 'आने वाले धोखाधड़ी वाले संदेशों को जांचने के लिए आवश्यक।',
    grantPermission: 'अनुमति दें',
    detailTitle: 'चेतावनी विवरण',
    viewEvidence: 'संदेश सामग्री देखें',
    threatDetected: 'खतरा पाया गया',
  );

  static const SentinelStrings mr = SentinelStrings(
    feedTitle: 'सेंटिनेल क्रियाकलाप नोंद',
    filterAll: 'सर्व स्कॅन',
    filterHighRisk: 'धोकादायक (लाल)',
    filterSuspicious: 'संशयास्पद (पिवळा)',
    emptyFeedTitle: 'अद्याप कोणतेही इशारे नाहीत',
    emptyFeedSubtitle: 'व्हॉट्सअ‍ॅप व एसएमएसवरून तपासलेले संदेश येथे दिसतील.',
    healthTitle: 'सेंटिनेल आरोग्य केंद्र',
    serviceActive: 'सेंटिनेल सेवा सक्रिय आहे',
    serviceActiveSubtitle: 'व्हॉट्सअ‍ॅप व एसएमएस संदेशांचे 24x7 संरक्षण सुरू आहे.',
    serviceInactive: 'सेंटिनेल सेवा बंद आहे',
    serviceInactiveSubtitle: 'संरक्षणासाठी कृपया सूचना परवानगी सक्षम करा.',
    batteryOptimization: 'बॅटरी सेव्हर सूट',
    batteryOptimizationSubtitle: 'पार्श्वभूमीत संरक्षण अखंड चालू ठेवण्यासाठी आवश्यक.',
    notificationPermission: 'सूचना परवानगी',
    notificationPermissionSubtitle: 'फसवणूक संदेश तपासण्यासाठी आवश्यक.',
    grantPermission: 'परवानगी द्या',
    detailTitle: 'इशारा तपशील',
    viewEvidence: 'तपासलेला संदेश पहा',
    threatDetected: 'धोका आढळला',
  );

  static const SentinelStrings ta = SentinelStrings(
    feedTitle: 'சென்டினல் செயல்பாட்டு ஊட்டம்',
    filterAll: 'அனைத்து ஸ்கேன்களும்',
    filterHighRisk: 'அதிக ஆபத்து (சிவப்பு)',
    filterSuspicious: 'சந்தேகத்திற்குரியது (மஞ்சள்)',
    emptyFeedTitle: 'எச்சரிக்கைகள் எதுவும் இல்லை',
    emptyFeedSubtitle: 'WhatsApp மற்றும் SMS செய்திகள் இங்கே தோன்றும்.',
    healthTitle: 'சென்டினல் சுகாதார மையம்',
    serviceActive: 'சென்டினல் சேவை செயலில் உள்ளது',
    serviceActiveSubtitle: 'நிகழ்நேர கண்காணிப்பு இயக்கப்பட்டது.',
    serviceInactive: 'சென்டினல் சேவை முடக்கப்பட்டுள்ளது',
    serviceInactiveSubtitle: 'பாதுகாப்பிற்கு அறிவிப்பு அணுகலை இயக்கவும்.',
    batteryOptimization: 'பேட்டரி சேமிப்பு விலக்கு',
    batteryOptimizationSubtitle: 'பின்னணியில் இயங்க அனுமதிக்கிறது.',
    notificationPermission: 'அறிவிப்பு அணுகல்',
    notificationPermissionSubtitle: 'மோசடி செய்திகளை ஸ்கேன் செய்ய தேவை.',
    grantPermission: 'அனுமதி வழங்கு',
    detailTitle: 'எச்சரிக்கை விவரங்கள்',
    viewEvidence: 'செய்தியைப் பார்',
    threatDetected: 'அச்சுறுத்தல் கண்டறியப்பட்டது',
  );

  static const SentinelStrings te = SentinelStrings(
    feedTitle: 'సెంటినెల్ యాక్టివిటీ ఫీడ్',
    filterAll: 'అన్ని స్కాన్‌లు',
    filterHighRisk: 'అధిక ప్రమాదం (ఎరుపు)',
    filterSuspicious: 'అనుమానాస్పద (పసుపు)',
    emptyFeedTitle: 'ఇంకా హెచ్చరికలు లేవు',
    emptyFeedSubtitle: 'WhatsApp మరియు SMS సందేశాలు ఇక్కడ కనిపిస్తాయి.',
    healthTitle: 'సెంటినెల్ హెల్త్ సెంటర్',
    serviceActive: 'సెంటినెల్ సేవ యాక్టివ్‌గా ఉంది',
    serviceActiveSubtitle: 'రియల్ టైమ్ పర్యవేక్షణ ఆన్‌లో ఉంది.',
    serviceInactive: 'సెంటినెల్ సేవ నిలిపివేయబడింది',
    serviceInactiveSubtitle: 'రక్షణ కోసం నోటిఫికేషన్ యాక్సెస్‌ను ప్రారంభించండి.',
    batteryOptimization: 'బ్యాటరీ ఆదా మినహాయింపు',
    batteryOptimizationSubtitle: 'నేపథ్యంలో రక్షణ కొనసాగించడానికి అవసరం.',
    notificationPermission: 'నోటిఫికేషన్ యాక్సెస్',
    notificationPermissionSubtitle: 'మోసపూరిత సందేశాలను స్కాన్ చేయడానికి అవసరం.',
    grantPermission: 'అనుమతి ఇవ్వండి',
    detailTitle: 'హెచ్చరిక వివరాలు',
    viewEvidence: 'సందేశాన్ని వీక్షించండి',
    threatDetected: 'ముప్పు కనుగొనబడింది',
  );

  static const SentinelStrings bn = SentinelStrings(
    feedTitle: 'সেন্টিনেল কার্যকলাপ ফিড',
    filterAll: 'সমস্ত স্ক্যান',
    filterHighRisk: 'উচ্চ ঝুঁকি (লাল)',
    filterSuspicious: 'সন্দেহজনক (হলুদ)',
    emptyFeedTitle: 'এখনও কোনো সতর্কতা নেই',
    emptyFeedSubtitle: 'হোয়াটসঅ্যাপ এবং এসএমএস থেকে আসা বার্তা এখানে দেখাবে।',
    healthTitle: 'সেন্টিনেল হেলথ সেন্টার',
    serviceActive: 'সেন্টিনেল পরিষেবা সক্রিয়',
    serviceActiveSubtitle: 'রিয়েল-টাইম নজরদারি সক্রিয় রয়েছে।',
    serviceInactive: 'সেন্টিনেল পরিষেবা নিষ্ক্রিয়',
    serviceInactiveSubtitle: 'সুরক্ষার জন্য নোটিফিকেশন অ্যাক্সেস চালু করুন।',
    batteryOptimization: 'ব্যাটারি সেভার ছাড়',
    batteryOptimizationSubtitle: 'ব্যাকগ্রাউন্ড সুরক্ষার জন্য প্রয়োজনীয়।',
    notificationPermission: 'নোটিফিকেশন অনুমতি',
    notificationPermissionSubtitle: 'স্ক্যান করার জন্য অনুমতি প্রয়োজন।',
    grantPermission: 'অনুমতি দিন',
    detailTitle: 'সতর্কতার বিবরণ',
    viewEvidence: 'বার্তা দেখুন',
    threatDetected: 'হুমকি সনাক্ত হয়েছে',
  );

  static const SentinelStrings gu = SentinelStrings(
    feedTitle: 'સેન્ટિનલ પ્રવૃત્તિ ફીડ',
    filterAll: 'બધા સ્કેન',
    filterHighRisk: 'ઉચ્ચ જોખમ (લાલ)',
    filterSuspicious: 'શંકાસ્પદ (પીળો)',
    emptyFeedTitle: 'હજુ કોઈ ચેતવણી નથી',
    emptyFeedSubtitle: 'WhatsApp અને SMS સંદેશાઓ અહીં દેખાશે.',
    healthTitle: 'સેન્ટિનલ હેલ્થ સેન્ટર',
    serviceActive: 'સેન્ટિનલ સેવા સક્રિય છે',
    serviceActiveSubtitle: 'રિયલ-ટાઇમ મોનિટરિંગ ચાલુ છે.',
    serviceInactive: 'સેન્ટિનલ સેવા નિષ્ક્રિય છે',
    serviceInactiveSubtitle: 'સુરક્ષા માટે નોટિફિકેશન ઍક્સેસ આપો.',
    batteryOptimization: 'બેટરી સેવર મુક્તિ',
    batteryOptimizationSubtitle: 'બેકગ્રાઉન્ડમાં સેવા ચાલુ રાખવા માટે જરૂરી.',
    notificationPermission: 'નોટિફિકેશન ઍક્સેસ',
    notificationPermissionSubtitle: 'સંદેશા ચકાસવા માટે જરૂરી.',
    grantPermission: 'પરવાનગી આપો',
    detailTitle: 'ચેતવણી વિગતો',
    viewEvidence: 'સંદેશ જુઓ',
    threatDetected: 'જોખમ મળ્યું',
  );

  static const SentinelStrings kn = SentinelStrings(
    feedTitle: 'ಸೆಂಟಿನೆಲ್ ಚಟುವಟಿಕೆ ಫೀಡ್',
    filterAll: 'ಎಲ್ಲಾ ಸ್ಕ್ಯಾನ್‌ಗಳು',
    filterHighRisk: 'ಹೆಚ್ಚಿನ ಅಪಾಯ (ಕೆಂಪು)',
    filterSuspicious: 'ಅನುಮಾನಾಸ್ಪದ (ಹಳದಿ)',
    emptyFeedTitle: 'ಇನ್ನೂ ಯಾವುದೇ ಎಚ್ಚರಿಕೆಗಳಿಲ್ಲ',
    emptyFeedSubtitle: 'WhatsApp ಮತ್ತು SMS ಸಂದೇಶಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ.',
    healthTitle: 'ಸೆಂಟಿನೆಲ್ ಹೆಲ್ತ್ ಸೆಂಟರ್',
    serviceActive: 'ಸೆಂಟಿನೆಲ್ ಸೇವೆ ಸಕ್ರಿಯವಾಗಿದೆ',
    serviceActiveSubtitle: 'ನೈಜ-ಸಮಯದ ರಕ್ಷಣೆ ಸಕ್ರಿಯವಾಗಿದೆ.',
    serviceInactive: 'ಸೆಂಟಿನೆಲ್ ಸೇವೆ ನಿಷ್ಕ್ರಿಯಗೊಂಡಿದೆ',
    serviceInactiveSubtitle: 'ರಕ್ಷಣೆಗಾಗಿ ಅಧಿಸೂಚನೆ ಪ್ರವೇಶವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.',
    batteryOptimization: 'ಬ್ಯಾಟರಿ ಉಳಿತಾಯ ವಿನಾಯಿತಿ',
    batteryOptimizationSubtitle: 'ಹಿನ್ನೆಲೆಯಲ್ಲಿ ರಕ್ಷಣೆ ಮುಂದುವರಿಸಲು ಅಗತ್ಯವಿದೆ.',
    notificationPermission: 'ಅಧಿಸೂಚನೆ ಪ್ರವೇಶ',
    notificationPermissionSubtitle: 'ವಂಚನೆ ಸಂದೇಶಗಳನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಅಗತ್ಯವಿದೆ.',
    grantPermission: 'ಅನುಮತಿ ನೀಡಿ',
    detailTitle: 'ಎಚ್ಚರಿಕೆ ವಿವರಗಳು',
    viewEvidence: 'ಸಂದೇಶವನ್ನು ವೀಕ್ಷಿಸಿ',
    threatDetected: 'ಬೆದರಿಕೆ ಪತ್ತೆಯಾಗಿದೆ',
  );

  static const SentinelStrings ml = SentinelStrings(
    feedTitle: 'സെന്റിനൽ ആക്റ്റിവിറ്റി ഫീഡ്',
    filterAll: 'എല്ലാ സ്കാനുകളും',
    filterHighRisk: 'ഉയർന്ന അപകടസാധ്യത (ചുവപ്പ്)',
    filterSuspicious: 'സംശയാസ്പദമായത് (മഞ്ഞ)',
    emptyFeedTitle: 'ഇതുവരെ മുന്നറിയിപ്പുകളൊന്നുമില്ല',
    emptyFeedSubtitle: 'വാട്ട്‌സ്ആപ്പിൽ നിന്നും എസ്എംഎസിൽ നിന്നുമുള്ള സന്ദേശങ്ങൾ ഇവിടെ കാണാം.',
    healthTitle: 'സെന്റിനൽ ഹെൽത്ത് സെന്റർ',
    serviceActive: 'സെന്റിനൽ സേവനം സജീവമാണ്',
    serviceActiveSubtitle: 'തത്സമയ നിരീക്ഷണം പ്രവർത്തനക്ഷമമാണ്.',
    serviceInactive: 'സെന്റിനൽ സേവനം നിർജ്ജീവമാണ്',
    serviceInactiveSubtitle: 'സുരക്ഷയ്ക്കായി അറിയിപ്പ് അനുമതി നൽകുക.',
    batteryOptimization: 'ബാറ്ററി സേവർ ഇളവ്',
    batteryOptimizationSubtitle: 'പശ്ചാത്തലത്തിൽ പ്രവർത്തിക്കാൻ അനുവദിക്കുന്നു.',
    notificationPermission: 'അറിയിപ്പ് അനുമതി',
    notificationPermissionSubtitle: 'തട്ടിപ്പ് സന്ദേശങ്ങൾ പരിശോധിക്കാൻ ആവശ്യമാണ്.',
    grantPermission: 'അനുമതി നൽകുക',
    detailTitle: 'മുന്നറിയിപ്പ് വിവരങ്ങൾ',
    viewEvidence: 'സന്ദേശം കാണുക',
    threatDetected: 'ഭീഷണി കണ്ടെത്തി',
  );

  static const SentinelStrings pa = SentinelStrings(
    feedTitle: 'ਸੈਂਟੀਨੇਲ ਗਤੀਵਿਧੀ ਫੀਡ',
    filterAll: 'ਸਾਰੇ ਸਕੈਨ',
    filterHighRisk: 'ਉੱਚ ਖਤਰਾ (ਲਾਲ)',
    filterSuspicious: 'ਸ਼ੱਕੀ (ਪੀਲਾ)',
    emptyFeedTitle: 'ਅਜੇ ਕੋਈ ਚੇਤਾਵਨੀ ਨਹੀਂ',
    emptyFeedSubtitle: 'ਵਟਸਐਪ ਅਤੇ ਐਸਐਮਐਸ ਤੋਂ ਆਏ ਸੁਨੇਹੇ ਇੱਥੇ ਦਿਖਾਈ ਦੇਣਗੇ।',
    healthTitle: 'ਸੈਂਟੀਨੇਲ ਹੈਲਥ ਸੈਂਟਰ',
    serviceActive: 'ਸੈਂਟੀਨੇਲ ਸੇਵਾ ਕਿਰਿਆਸ਼ੀਲ ਹੈ',
    serviceActiveSubtitle: 'ਰੀਅਲ-ਟਾਈਮ ਨਿਗਰਾਨੀ ਚਾਲੂ ਹੈ।',
    serviceInactive: 'ਸੈਂਟੀਨੇਲ ਸੇਵਾ ਬੰਦ ਹੈ',
    serviceInactiveSubtitle: 'ਸੁਰੱਖਿਆ ਲਈ ਨੋਟੀਫਿਕੇਸ਼ਨ ਪਹੁੰਚ ਦੀ ਆਗਿਆ ਦਿਓ।',
    batteryOptimization: 'ਬੈਟਰੀ ਸੇਵਰ ਛੋਟ',
    batteryOptimizationSubtitle: 'ਬੈਕਗ੍ਰਾਊਂਡ ਵਿੱਚ ਸੁਰੱਖਿਆ ਜਾਰੀ ਰੱਖਣ ਲਈ ਲੋੜੀਂਦਾ।',
    notificationPermission: 'ਨੋਟੀਫਿਕੇਸ਼ਨ ਪਹੁੰਚ',
    notificationPermissionSubtitle: 'ਸੁਨੇਹਿਆਂ ਦੀ ਜਾਂਚ ਕਰਨ ਲਈ ਲੋੜੀਂਦਾ।',
    grantPermission: 'ਇਜਾਜ਼ਤ ਦਿਓ',
    detailTitle: 'ਚੇਤਾਵਨੀ ਵੇਰਵਾ',
    viewEvidence: 'ਸੁਨੇਹਾ ਵੇਖੋ',
    threatDetected: 'ਖ਼ਤਰਾ ਪਾਇਆ ਗਿਆ',
  );

  static SentinelStrings forLocale(AppLocale locale) {
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

final Provider<SentinelStrings> sentinelStringsProvider =
Provider<SentinelStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return SentinelStrings.forLocale(locale);
});
