import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class HomeStrings {
  const HomeStrings({
    required this.goodMorning,
    required this.goodAfternoon,
    required this.goodEvening,
    required this.guestBadge,
    required this.elderBadge,
    required this.standardBadge,
    required this.langBadgePrefix,
    required this.navHome,
    required this.navFeed,
    required this.navSettings,
    required this.centralScanTooltip,
    required this.notImplementedYet,
    required this.recoveryCardTitle,
    required this.recoveryCardSubtitle,
    required this.shieldActiveTitle,
    required this.shieldActiveSubtitle,
    required this.actionScanText,
    required this.actionScanScreenshot,
    required this.actionQrPay,
    required this.recentScamsTitle,
    required this.threatTrendsTitle,
    required this.emergencyNotice,
    required this.emergencyNoticeBody,
  });

  final String goodMorning;
  final String goodAfternoon;
  final String goodEvening;
  final String guestBadge;
  final String elderBadge;
  final String standardBadge;
  final String langBadgePrefix;
  final String navHome;
  final String navFeed;
  final String navSettings;
  final String centralScanTooltip;
  final String notImplementedYet;
  final String recoveryCardTitle;
  final String recoveryCardSubtitle;

  // Production Home Additions
  final String shieldActiveTitle;
  final String shieldActiveSubtitle;
  final String actionScanText;
  final String actionScanScreenshot;
  final String actionQrPay;
  final String recentScamsTitle;
  final String threatTrendsTitle;
  final String emergencyNotice;
  final String emergencyNoticeBody;

  static const HomeStrings en = HomeStrings(
    goodMorning: 'Good morning',
    goodAfternoon: 'Good afternoon',
    goodEvening: 'Good evening',
    guestBadge: 'Guest',
    elderBadge: 'Elder Mode',
    standardBadge: 'Standard',
    langBadgePrefix: 'Language',
    navHome: 'Home',
    navFeed: 'Feed',
    navSettings: 'Settings',
    centralScanTooltip: 'Scan a message',
    notImplementedYet: 'Available in a future update.',
    recoveryCardTitle: 'Scammed? Start Recovery',
    recoveryCardSubtitle: '1930 Helpline call, Bank complaint & FIR draft',
    shieldActiveTitle: 'Sentinel Active & Defending',
    shieldActiveSubtitle: 'On-device real-time monitoring enabled for WhatsApp & SMS',
    actionScanText: 'Check Message',
    actionScanScreenshot: 'Scan Image',
    actionQrPay: 'Verify QR',
    recentScamsTitle: 'Trending Cyber Threats in India',
    threatTrendsTitle: 'Protection Health Status',
    emergencyNotice: 'Emergency Fraud Protocol',
    emergencyNoticeBody: 'Report financial fraud within 24 hours to freeze stolen money via 1930.',
  );

  static const HomeStrings hi = HomeStrings(
    goodMorning: 'शुभ प्रभात',
    goodAfternoon: 'नमस्कार',
    goodEvening: 'शुभ संध्या',
    guestBadge: 'गेस्ट',
    elderBadge: 'बुज़ुर्ग मोड',
    standardBadge: 'सामान्य',
    langBadgePrefix: 'भाषा',
    navHome: 'होम',
    navFeed: 'फ़ीड',
    navSettings: 'सेटिंग्स',
    centralScanTooltip: 'संदेश जाँचें',
    notImplementedYet: 'अगले अपडेट में उपलब्ध।',
    recoveryCardTitle: 'धोखा हुआ? रिकवरी शुरू करें',
    recoveryCardSubtitle: '1930 कॉल, बैंक शिकायत व FIR ड्राफ्ट',
    shieldActiveTitle: 'कवच प्रहरी सक्रिय और सुरक्षित',
    shieldActiveSubtitle: 'व्हाट्सएप और एसएमएस के लिए ऑन-डिवाइस सुरक्षा चालू है',
    actionScanText: 'संदेश जाँचें',
    actionScanScreenshot: 'फ़ोटो स्कैन',
    actionQrPay: 'क्यूआर जाँच',
    recentScamsTitle: 'भारत में सक्रिय प्रमुख ऑनलाइन घोटाले',
    threatTrendsTitle: 'सुरक्षा स्थिति और स्वास्थ्य',
    emergencyNotice: 'आपातकालीन वित्तीय सहायता',
    emergencyNoticeBody: 'धोखा होने पर 24 घंटे में 1930 पर कॉल करें ताकि बैंक खाते फ्रीज हो सकें।',
  );

  static const HomeStrings mr = HomeStrings(
    goodMorning: 'शुभ सकाळ',
    goodAfternoon: 'नमस्कार',
    goodEvening: 'शुभ संध्याकाळ',
    guestBadge: 'गेस्ट',
    elderBadge: 'ज्येष्ठ मोड',
    standardBadge: 'सामान्य',
    langBadgePrefix: 'भाषा',
    navHome: 'होम',
    navFeed: 'फीड',
    navSettings: 'सेटिंग्ज',
    centralScanTooltip: 'संदेश तपासा',
    notImplementedYet: 'पुढील अपडेटमध्ये उपलब्ध.',
    recoveryCardTitle: 'फसवणूक झाली? रिकव्हरी सुरू करा',
    recoveryCardSubtitle: '1930 कॉल, बँक तक्रार आणि FIR मसुदा',
    shieldActiveTitle: 'कवच सेंटिनेल सक्रिय आणि सज्ज',
    shieldActiveSubtitle: 'व्हॉट्सअ‍ॅप व एसएमएससाठी ऑन-डिव्हाइस संरक्षण सुरू आहे',
    actionScanText: 'संदेश तपासा',
    actionScanScreenshot: 'फोटो स्कॅन',
    actionQrPay: 'क्यूआर पडताळणी',
    recentScamsTitle: 'भारतातील चालू ऑनलाईन फसवणूक प्रकार',
    threatTrendsTitle: 'संरक्षण स्थिती व आरोग्य',
    emergencyNotice: 'तातडीची मदत नियमावली',
    emergencyNoticeBody: 'पैसे वाचवण्यासाठी फसवणूक झाल्यावर २४ तासांत १९३० वर त्वरित तक्रार नोंदवा.',
  );

  static const HomeStrings ta = HomeStrings(
    goodMorning: 'காலை வணக்கம்',
    goodAfternoon: 'மதிய வணக்கம்',
    goodEvening: 'மாலை வணக்கம்',
    guestBadge: 'விருந்தினர்',
    elderBadge: 'முதியோர் முறைமை',
    standardBadge: 'நிலையானது',
    langBadgePrefix: 'மொழி',
    navHome: 'முகப்பு',
    navFeed: 'ஊட்டம்',
    navSettings: 'அமைப்புகள்',
    centralScanTooltip: 'செய்தியை ஸ்கேன் செய்',
    notImplementedYet: 'அடுத்த பதிப்பில் கிடைக்கும்.',
    recoveryCardTitle: 'ஏமாற்றப்பட்டீர்களா? மீட்பைத் தொடங்குங்கள்',
    recoveryCardSubtitle: '1930 உதவி எண், வங்கி புகார் & FIR வரைவு',
    shieldActiveTitle: 'கவசம் பாதுகாப்பில் உள்ளது',
    shieldActiveSubtitle: 'WhatsApp மற்றும் SMS செய்திகளுக்கு நிகழ்நேர பாதுகாப்பு இயக்கப்பட்டது',
    actionScanText: 'செய்தியை சோதி',
    actionScanScreenshot: 'படத்தை ஸ்கேன் செய்',
    actionQrPay: 'QR சரிபார்',
    recentScamsTitle: 'தற்போது பரவி வரும் இணைய மோசடிகள்',
    threatTrendsTitle: 'பாதுகாப்பு நிலை',
    emergencyNotice: 'அவசர உதவி வழிகாட்டல்',
    emergencyNoticeBody: 'பணத்தை மீட்க 24 மணி நேரத்திற்குள் 1930 எண்ணை அழைக்கவும்.',
  );

  static const HomeStrings te = HomeStrings(
    goodMorning: 'శుభోదయం',
    goodAfternoon: 'నమస్కారం',
    goodEvening: 'శుభ సాయంత్రం',
    guestBadge: 'అతిథి',
    elderBadge: 'సీనియర్ మోడ్',
    standardBadge: 'ప్రామాణిక',
    langBadgePrefix: 'భాష',
    navHome: 'హోమ్',
    navFeed: 'ఫీడ్',
    navSettings: 'సెట్టింగ్‌లు',
    centralScanTooltip: 'సందేశాన్ని స్కాన్ చేయండి',
    notImplementedYet: 'తదుపరి అప్‌డేట్‌లో లభిస్తుంది.',
    recoveryCardTitle: 'మోసపోయారా? రికవరీ ప్రారంభించండి',
    recoveryCardSubtitle: '1930 హెల్ప్‌లైన్, బ్యాంక్ ఫిర్యాదు & FIR డ్రాఫ్ట్',
    shieldActiveTitle: 'కవచ్ రక్షణలో ఉంది',
    shieldActiveSubtitle: 'వాట్సాప్ మరియు ఎస్ఎమ్ఎస్ కోసం రియల్ టైమ్ రక్షణ ఆన్‌లో ఉంది',
    actionScanText: 'సందేశం తనిఖీ',
    actionScanScreenshot: 'ఫోటో స్కాన్',
    actionQrPay: 'QR తనిఖీ',
    recentScamsTitle: 'ప్రస్తుతం ఎక్కువగా జరుగుతున్న సైబర్ మోసాలు',
    threatTrendsTitle: 'రక్షణ స్థితి',
    emergencyNotice: 'అత్యవసర మోసం రికవరీ',
    emergencyNoticeBody: 'డబ్బును కాపాడటానికి మోసం జరిగిన 24 గంటల్లో 1930 కి కాల్ చేయండి.',
  );

  static const HomeStrings bn = HomeStrings(
    goodMorning: 'সুপ্রভাত',
    goodAfternoon: 'নমস্কার',
    goodEvening: 'শুভ সন্ধ্যা',
    guestBadge: 'অতিথি',
    elderBadge: 'প্রবীণ মোড',
    standardBadge: 'সাধারণ',
    langBadgePrefix: 'ভাষা',
    navHome: 'হোম',
    navFeed: 'ফিড',
    navSettings: 'সেটিংস',
    centralScanTooltip: 'বার্তা স্ক্যান করুন',
    notImplementedYet: 'পরবর্তী আপডেটে উপলব্ধ।',
    recoveryCardTitle: 'প্রতারিত হয়েছেন? পুনরুদ্ধার শুরু করুন',
    recoveryCardSubtitle: '১৯৩০ হেল্পলাইন, ব্যাংক অভিযোগ ও এফআইআর ড্রাফট',
    shieldActiveTitle: 'কবচ সুরক্ষা সক্রিয় রয়েছে',
    shieldActiveSubtitle: 'হোয়াটসঅ্যাপ এবং এসএমএসের জন্য রিয়েল-টাইম সুরক্ষা চালু আছে',
    actionScanText: 'বার্তা পরীক্ষা',
    actionScanScreenshot: 'ছবি স্ক্যান',
    actionQrPay: 'কিউআর যাচাই',
    recentScamsTitle: 'ভারতে সাম্প্রতিক সাইবার প্রতারণার ধরণ',
    threatTrendsTitle: 'নিরাপত্তা স্বাস্থ্য স্থিতি',
    emergencyNotice: 'জরুরী প্রতারণা নির্দেশিকা',
    emergencyNoticeBody: 'টাকা ফেরত পেতে প্রতারণার ২৪ ঘণ্টার মধ্যে ১৯৩০ নম্বরে যোগাযোগ করুন।',
  );

  static const HomeStrings gu = HomeStrings(
    goodMorning: 'સુપ્રભાત',
    goodAfternoon: 'નમસ્તે',
    goodEvening: 'શુભ સંધ્યા',
    guestBadge: 'મહેમાન',
    elderBadge: 'વરિષ્ઠ મોડ',
    standardBadge: 'સામાન્ય',
    langBadgePrefix: 'ભાષા',
    navHome: 'હોમ',
    navFeed: 'ફીડ',
    navSettings: 'સેટિંગ્સ',
    centralScanTooltip: 'સંદેશ સ્કેન કરો',
    notImplementedYet: 'આગામી અપડેટમાં ઉપલબ્ધ.',
    recoveryCardTitle: 'છેતરાયા છો? પુનઃપ્રાપ્તિ શરૂ કરો',
    recoveryCardSubtitle: '1930 હેલ્પલાઇન, બેંક ફરિયાદ અને FIR ડ્રાફ્ટ',
    shieldActiveTitle: 'કવચ સુરક્ષા સક્રિય છે',
    shieldActiveSubtitle: 'WhatsApp અને SMS માટે રિયલ-ટાઇમ રક્ષણ સક્ષમ છે',
    actionScanText: 'સંદેશ તપાસો',
    actionScanScreenshot: 'ફોટો સ્કેન',
    actionQrPay: 'QR ચકાસો',
    recentScamsTitle: 'ભારતમાં પ્રચલિત સાયબર ફ્રોડ',
    threatTrendsTitle: 'સુરક્ષા સ્થિતિ',
    emergencyNotice: 'ઇમરજન્સી હેલ્પલાઇન પ્રોટોકોલ',
    emergencyNoticeBody: 'નાણાં બ્લોક કરવા માટે છેતરપિંડીના 24 કલાકમાં 1930 પર કોલ કરો.',
  );

  static const HomeStrings kn = HomeStrings(
    goodMorning: 'ಶುಭೋದಯ',
    goodAfternoon: 'ನಮಸ್ಕಾರ',
    goodEvening: 'ಶುಭ ಸಂಜೆ',
    guestBadge: 'ಅತಿಥಿ',
    elderBadge: 'ಹಿರಿಯರ ಮೋಡ್',
    standardBadge: 'ಸಾಮಾನ್ಯ',
    langBadgePrefix: 'ಭಾಷೆ',
    navHome: 'ಮುಖಪುಟ',
    navFeed: 'ಫೀಡ್',
    navSettings: 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    centralScanTooltip: 'ಸಂದೇಶ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
    notImplementedYet: 'ಮುಂದಿನ ಅಪ್ಡೇಟ್‌ನಲ್ಲಿ ಲಭ್ಯವಿದೆ.',
    recoveryCardTitle: 'ವಂಚನೆಗೊಳಗಾಗಿದ್ದೀರಾ? ಚೇತರಿಕೆ ಪ್ರಾರಂಭಿಸಿ',
    recoveryCardSubtitle: '1930 ಸಹಾಯವಾಣಿ, ಬ್ಯಾಂಕ್ ದೂರು ಮತ್ತು ಎಫ್‌ಐಆರ್ ಕರಡು',
    shieldActiveTitle: 'ಕವಚ ರಕ್ಷಣೆ ಸಕ್ರಿಯವಾಗಿದೆ',
    shieldActiveSubtitle: 'ವಾಟ್ಸಾಪ್ ಮತ್ತು ಎಸ್‌ಎಂಎಸ್‌ಗಾಗಿ ನೈಜ ಸಮಯದ ರಕ್ಷಣೆ ಸಕ್ರಿಯವಾಗಿದೆ',
    actionScanText: 'ಸಂದೇಶ ಪರೀಕ್ಷಿಸಿ',
    actionScanScreenshot: 'ಚಿತ್ರ ಸ್ಕ್ಯಾನ್',
    actionQrPay: 'QR ಪರಿಶೀಲಿಸಿ',
    recentScamsTitle: 'ಭಾರತದಲ್ಲಿ ಪ್ರಸ್ತುತ ಸೈಬರ್ ವಂಚನೆಗಳು',
    threatTrendsTitle: 'ರಕ್ಷಣಾ ಸ್ಥಿತಿ',
    emergencyNotice: 'ತುರ್ತು ವಂಚನೆ ಮಾರ್ಗದರ್ಶಿ',
    emergencyNoticeBody: 'ಹಣ ಉಳಿಸಲು ವಂಚನೆ ನಡೆದ 24 ಗಂಟೆಗಳ ಒಳಗೆ 1930 ಗೆ ಕರೆ ಮಾಡಿ.',
  );

  static const HomeStrings ml = HomeStrings(
    goodMorning: 'സുപ്രഭാതം',
    goodAfternoon: 'നമസ്കാരം',
    goodEvening: 'ശുഭ സായാഹ്നം',
    guestBadge: 'അതിഥി',
    elderBadge: 'മുതിർന്നവർക്കുള്ള മോഡ്',
    standardBadge: 'സാധാരണ',
    langBadgePrefix: 'ഭാഷ',
    navHome: 'ഹോം',
    navFeed: 'ഫീഡ്',
    navSettings: 'ക്രമീകരണങ്ങൾ',
    centralScanTooltip: 'സന്ദേശം സ്കാൻ ചെയ്യുക',
    notImplementedYet: 'അടുത്ത അപ്‌ഡേറ്റിൽ ലഭ്യമാകും.',
    recoveryCardTitle: 'തട്ടിപ്പിനിരയായോ? വീണ്ടെടുക്കൽ ആരംഭിക്കുക',
    recoveryCardSubtitle: '1930 ഹെൽപ്പ് ലൈൻ, ബാങ്ക് പരാതി, FIR ഡ്രാഫ്റ്റ്',
    shieldActiveTitle: 'കവച സംരക്ഷണം സജീവമാണ്',
    shieldActiveSubtitle: 'വാട്ട്‌സ്ആപ്പിലും എസ്എംഎസിലും തത്സമയ സുരക്ഷ പ്രവർത്തനക്ഷമമാണ്',
    actionScanText: 'സന്ദേശം പരിശോധിക്കുക',
    actionScanScreenshot: 'ചിത്രം സ്കാൻ',
    actionQrPay: 'ക്യുആർ പരിശോധിക്കുക',
    recentScamsTitle: 'ഇന്ത്യയിലെ നിലവിലെ സൈബർ തട്ടിപ്പുകൾ',
    threatTrendsTitle: 'സുരക്ഷാ നില',
    emergencyNotice: 'അടിയന്തര സഹായം',
    emergencyNoticeBody: 'പണം തിരികെ ലഭിക്കാൻ തട്ടിപ്പ് നടന്ന് 24 മണിക്കൂറിനകം 1930 ൽ ബന്ധപ്പെടുക.',
  );

  static const HomeStrings pa = HomeStrings(
    goodMorning: 'ਸ਼ੁਭ ਸਵੇਰ',
    goodAfternoon: 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ',
    goodEvening: 'ਸ਼ਾਮ ਮੁਬਾਰਕ',
    guestBadge: 'ਮਹਿਮਾਨ',
    elderBadge: 'ਬਜ਼ੁਰਗ ਮੋਡ',
    standardBadge: 'ਸਧਾਰਨ',
    langBadgePrefix: 'ਭਾਸ਼ਾ',
    navHome: 'ਹੋਮ',
    navFeed: 'ਫੀਡ',
    navSettings: 'ਸੈਟਿੰਗਾਂ',
    centralScanTooltip: 'ਸੁਨੇਹਾ ਸਕੈਨ ਕਰੋ',
    notImplementedYet: 'ਅਗਲੇ ਅਪਡੇਟ ਵਿੱਚ ਉਪਲਬਧ ਹੋਵੇਗਾ।',
    recoveryCardTitle: 'ਧੋਖਾ ਹੋਇਆ? ਰਿਕਵਰੀ ਸ਼ੁਰੂ ਕਰੋ',
    recoveryCardSubtitle: '1930 ਹੈਲਪਲਾਈਨ, ਬੈਂਕ ਸ਼ਿਕਾਇਤ ਅਤੇ FIR ਡਰਾਫਟ',
    shieldActiveTitle: 'ਕਵਚ ਸੁਰੱਖਿਆ ਸਰਗਰਮ ਹੈ',
    shieldActiveSubtitle: 'ਵਟਸਐਪ ਅਤੇ ਐਸਐਮਐਸ ਲਈ ਰੀਅਲ-ਟਾਈਮ ਸੁਰੱਖਿਆ ਚਾਲੂ ਹੈ',
    actionScanText: 'ਸੁਨੇਹਾ ਚੈੱਕ ਕਰੋ',
    actionScanScreenshot: 'ਫੋਟੋ ਸਕੈਨ',
    actionQrPay: 'QR ਜਾਂਚ',
    recentScamsTitle: 'ਭਾਰਤ ਵਿੱਚ ਚੱਲ ਰਹੇ ਆਨਲਾਈਨ ਘੁਟਾਲੇ',
    threatTrendsTitle: 'ਸੁਰੱਖਿਆ ਸਥਿਤੀ',
    emergencyNotice: 'ਐਮਰਜੈਂਸੀ ਰਿਕਵਰੀ ਪ੍ਰੋਟੋਕੋਲ',
    emergencyNoticeBody: 'ਪੈਸੇ ਬਚਾਉਣ ਲਈ ਧੋਖਾ ਹੋਣ ਦੇ 24 ਘੰਟਿਆਂ ਦੇ ਅੰਦਰ 1930 ਤੇ ਕਾਲ ਕਰੋ।',
  );

  static HomeStrings forLocale(AppLocale locale) {
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

final Provider<HomeStrings> homeStringsProvider =
Provider<HomeStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return HomeStrings.forLocale(locale);
});