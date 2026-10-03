import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class RecoveryStrings {
  const RecoveryStrings({
    required this.wizardTitle,
    required this.calmTitle,
    required this.calmSubtitle,
    required this.call1930Title,
    required this.call1930Subtitle,
    required this.callButton,
    required this.bankFreezeTitle,
    required this.bankFreezeSubtitle,
    required this.evidenceTitle,
    required this.evidenceSubtitle,
    required this.complaintTitle,
    required this.complaintSubtitle,
    required this.copyComplaint,
    required this.nextStep,
    required this.backStep,
    required this.completedTitle,
  });

  final String wizardTitle;
  final String calmTitle;
  final String calmSubtitle;
  final String call1930Title;
  final String call1930Subtitle;
  final String callButton;
  final String bankFreezeTitle;
  final String bankFreezeSubtitle;
  final String evidenceTitle;
  final String evidenceSubtitle;
  final String complaintTitle;
  final String complaintSubtitle;
  final String copyComplaint;
  final String nextStep;
  final String backStep;
  final String completedTitle;

  static const RecoveryStrings en = RecoveryStrings(
    wizardTitle: 'Golden Hour Recovery Copilot',
    calmTitle: 'Take a Deep Breath',
    calmSubtitle: 'Do not panic. You have up to 24–48 hours to freeze siphoned money via government helpline 1930.',
    call1930Title: 'Step 1: Call 1930 Helpline',
    call1930Subtitle: 'Dial the National Cybercrime Reporting Helpline immediately to register a transaction freeze.',
    callButton: 'Call 1930 Now',
    bankFreezeTitle: 'Step 2: Contact Your Bank',
    bankFreezeSubtitle: 'Immediately request your bank to block your debit card, UPI ID, and net banking.',
    evidenceTitle: 'Step 3: Preserve Evidence',
    evidenceSubtitle: 'Keep transaction IDs, WhatsApp chat screenshots, and phone numbers ready.',
    complaintTitle: 'Step 4: Formal Police Complaint',
    complaintSubtitle: 'A legally compliant cybercrime complaint has been prepared for cybercrime.gov.in.',
    copyComplaint: 'Copy Complaint Text',
    nextStep: 'Continue to Next Step',
    backStep: 'Previous Step',
    completedTitle: 'Recovery Steps Completed',
  );

  static const RecoveryStrings hi = RecoveryStrings(
    wizardTitle: 'गोल्डन आवर रिकवरी कोपायलट',
    calmTitle: 'शांत रहें, घबराएँ नहीं',
    calmSubtitle: 'चिंता न करें। सरकारी हेल्पलाइन 1930 के माध्यम से निकाले गए पैसे को फ्रीज कराने के लिए आपके पास 24–48 घंटे हैं।',
    call1930Title: 'चरण 1: 1930 हेल्पलाइन पर कॉल करें',
    call1930Subtitle: 'लेनदेन फ्रीज कराने के लिए राष्ट्रीय साइबर अपराध हेल्पलाइन पर तुरंत कॉल करें।',
    callButton: '1930 पर कॉल करें',
    bankFreezeTitle: 'चरण 2: अपने बैंक से संपर्क करें',
    bankFreezeSubtitle: 'अपने डेबिट कार्ड, यूपीआई और नेट बैंकिंग को तुरंत ब्लॉक करने का अनुरोध करें।',
    evidenceTitle: 'चरण 3: सबूत सुरक्षित रखें',
    evidenceSubtitle: 'लेनदेन आईडी, व्हाट्सएप चैट के स्क्रीनशॉट और मोबाइल नंबर संभाल कर रखें।',
    complaintTitle: 'चरण 4: औपचारिक पुलिस शिकायत',
    complaintSubtitle: 'cybercrime.gov.in के लिए कानूनी रूप से मान्य शिकायत तैयार की गई है।',
    copyComplaint: 'शिकायत कॉपी करें',
    nextStep: 'अगले चरण पर जाएँ',
    backStep: 'पिछला चरण',
    completedTitle: 'रिकवरी चरण पूरे हुए',
  );

  static const RecoveryStrings mr = RecoveryStrings(
    wizardTitle: 'गोल्डन अवर रिकव्हरी कोपायलट',
    calmTitle: 'शांत राहा, घाबरू नका',
    calmSubtitle: 'काळजी करू नका. सरकारी हेल्पलाइन १९३० द्वारे पैसे गोठवण्यासाठी तुमच्याकडे २४ ते ४८ तास आहेत.',
    call1930Title: 'पायरी १: १९३० हेल्पलाइनला कॉल करा',
    call1930Subtitle: 'पैसे वाचवण्यासाठी राष्ट्रीय सायबर क्राईम हेल्पलाइनवर त्वरित संपर्क साधा.',
    callButton: '१९३० वर कॉल करा',
    bankFreezeTitle: 'पायरी २: आपल्या बँकेशी संपर्क साधा',
    bankFreezeSubtitle: 'आपले डेबिट कार्ड, यूपीआय आणि नेट बँकिंग त्वरित ब्लॉक करण्याची विनंती करा.',
    evidenceTitle: 'पायरी ३: पुरावे सुरक्षित ठेवा',
    evidenceSubtitle: 'व्यवहार क्रमांक (Transaction ID), व्हॉट्सअ‍ॅप चॅटचे स्क्रीनशॉट जपून ठेवा.',
    complaintTitle: 'पायरी ४: अधिकृत सायबर तक्रार',
    complaintSubtitle: 'cybercrime.gov.in साठी कायदेशीर तक्रार मसुदा तयार करण्यात आला आहे.',
    copyComplaint: 'तक्रार कॉपी करा',
    nextStep: 'पुढील पायरीवर जा',
    backStep: 'मागील पायरी',
    completedTitle: 'सर्व पायऱ्या पूर्ण झाल्या',
  );

  static const RecoveryStrings ta = RecoveryStrings(
    wizardTitle: 'கோல்டன் ஹவர் மீட்பு வழிகாட்டி',
    calmTitle: 'பயப்பட வேண்டாம், அமைதியாக இருங்கள்',
    calmSubtitle: '1930 உதவி எண் மூலம் பணத்தை முடக்க உங்களுக்கு 24–48 மணி நேரம் உள்ளது.',
    call1930Title: 'படி 1: 1930 உதவி எண்ணை அழைக்கவும்',
    call1930Subtitle: 'பரிவர்த்தனையை முடக்க உடனடியாக தேசிய சைபர் கிரைம் உதவி எண்ணை அழைக்கவும்.',
    callButton: '1930-ஐ அழைக்கவும்',
    bankFreezeTitle: 'படி 2: உங்கள் வங்கியைத் தொடர்பு கொள்ளவும்',
    bankFreezeSubtitle: 'உங்கள் டெபிட் கார்டு மற்றும் UPI-ஐ உடனடியாக முடக்கக் கோருங்கள்.',
    evidenceTitle: 'படி 3: ஆதாரங்களைப் பாதுகாக்கவும்',
    evidenceSubtitle: 'பரிவர்த்தனை எண்கள் மற்றும் அரட்டைத் திரைக்காட்சிகளைச் சேமிக்கவும்.',
    complaintTitle: 'படி 4: முறையான சைபர் புகார்',
    complaintSubtitle: 'cybercrime.gov.in தளத்திற்கான புகார் வரைவு தயார் செய்யப்பட்டுள்ளது.',
    copyComplaint: 'புகாரை நகலெடு',
    nextStep: 'அடுத்த படிக்குச் செல்லவும்',
    backStep: 'முந்தைய படி',
    completedTitle: 'மீட்பு படிகள் முடிந்தது',
  );

  static const RecoveryStrings te = RecoveryStrings(
    wizardTitle: 'గోల్డెన్ అవర్ రికవరీ కోపైలట్',
    calmTitle: 'ప్రశాంతంగా ఉండండి, భయపడవద్దు',
    calmSubtitle: '1930 హెల్ప్‌లైన్ ద్వారా పోయిన డబ్బును ఫ్రీజ్ చేయడానికి మీకు 24–48 గంటల సమయం ఉంది.',
    call1930Title: 'దశ 1: 1930 హెల్ప్‌లైన్‌కు కాల్ చేయండి',
    call1930Subtitle: 'లావాదేవీని నిలిపివేయడానికి వెంటనే జాతీయ సైబర్ క్రైమ్ హెల్ప్‌లైన్‌ను సంప్రదించండి.',
    callButton: 'ఇప్పుడే 1930 కి కాల్ చేయండి',
    bankFreezeTitle: 'దశ 2: మీ బ్యాంక్‌ను సంప్రదించండి',
    bankFreezeSubtitle: 'మీ డెబిట్ కార్డ్ మరియు UPI సేవలను వెంటనే నిలిపివేయమని అభ్యర్థించండి.',
    evidenceTitle: 'దశ 3: ఆధారాలను భద్రపరచండి',
    evidenceSubtitle: 'లావాదేవీ ఐడీలు మరియు స్క్రీన్‌షాట్‌లను సిద్ధంగా ఉంచుకోండి.',
    complaintTitle: 'దశ 4: అధికారిక సైబర్ ఫిర్యాదు',
    complaintSubtitle: 'cybercrime.gov.in కోసం అధికారిక ఫిర్యాదు సిద్ధం చేయబడింది.',
    copyComplaint: 'ఫిర్యాదును కాపీ చేయండి',
    nextStep: 'తదుపరి దశకు వెళ్లండి',
    backStep: 'మునుపటి దశ',
    completedTitle: 'రికవరీ దశలు పూర్తయ్యాయి',
  );

  static const RecoveryStrings bn = RecoveryStrings(
    wizardTitle: 'গোল্ডেন আওয়ার পুনরুদ্ধার সহায়ক',
    calmTitle: 'শান্ত থাকুন, আতঙ্কিত হবেন না',
    calmSubtitle: '১৯৩০ হেল্পলাইনের মাধ্যমে টাকা ফ্রিজ করার জন্য আপনার হাতে ২৪–৪৮ ঘণ্টা সময় আছে।',
    call1930Title: 'ধাপ ১: ১৯৩০ হেল্পলাইনে কল করুন',
    call1930Subtitle: 'লেনদেন বন্ধ করতে অবিলম্বে জাতীয় সাইবার ক্রাইম হেল্পলাইনে যোগাযোগ করুন।',
    callButton: '১৯৩০ নম্বরে কল করুন',
    bankFreezeTitle: 'ধাপ ২: ব্যাংকের সাথে যোগাযোগ করুন',
    bankFreezeSubtitle: 'আপনার ডেবিট কার্ড এবং ইউপিআই পরিষেবা অবিলম্বে ব্লক করার অনুরোধ করুন।',
    evidenceTitle: 'ধাপ ৩: প্রমাণ সংরক্ষণ করুন',
    evidenceSubtitle: 'লেনদেন আইডি এবং হোয়াটসঅ্যাপ চ্যাট স্ক্রিনশট সংগ্রহ করে রাখুন।',
    complaintTitle: 'ধাপ ৪: আইনি সাইবার অভিযোগ',
    complaintSubtitle: 'cybercrime.gov.in-এর জন্য অভিযোগের খসড়া তৈরি করা হয়েছে।',
    copyComplaint: 'অভিযোগ কপি করুন',
    nextStep: 'পরবর্তী ধাপে যান',
    backStep: 'পূর্ববর্তী ধাপ',
    completedTitle: 'পুনরুদ্ধার ধাপ সম্পন্ন হয়েছে',
  );

  static const RecoveryStrings gu = RecoveryStrings(
    wizardTitle: 'ગોલ્ડન અવર રિકવરી કોપાયલટ',
    calmTitle: 'શાંત રહો, ગભરાશો નહીં',
    calmSubtitle: '1930 હેલ્પલાઇન દ્વારા નાણાં ફ્રીઝ કરાવવા માટે તમારી પાસે 24–48 કલાક છે.',
    call1930Title: 'પગલું 1: 1930 હેલ્પલાઇન પર કોલ કરો',
    call1930Subtitle: 'ટ્રાન્ઝેક્શન અટકાવવા માટે તરત જ સાયબર ક્રાઇમ હેલ્પલાઇનનો સંપર્ક કરો.',
    callButton: '1930 પર કોલ કરો',
    bankFreezeTitle: 'પગલું 2: તમારી બેંકનો સંપર્ક કરો',
    bankFreezeSubtitle: 'તમારું ડેબિટ કાર્ડ અને યુપીઆઈ બ્લોક કરવાની વિનંતી કરો.',
    evidenceTitle: 'પગલું 3: પુરાવા સાચવી રાખો',
    evidenceSubtitle: 'ટ્રાન્ઝેક્શન આઈડી અને ચેટ સ્ક્રીનશોટ સુરક્ષિત રાખો.',
    complaintTitle: 'પગલું 4: કાનૂની સાયબર ફરિયાદ',
    complaintSubtitle: 'cybercrime.gov.in માટે ફરિયાદ ડ્રાફ્ટ તૈયાર કરવામાં આવ્યો છે.',
    copyComplaint: 'ફરિયાદ કોપી કરો',
    nextStep: 'આગળ વધો',
    backStep: 'પાછળ જાઓ',
    completedTitle: 'રિકવરી પૂર્ણ થઈ',
  );

  static const RecoveryStrings kn = RecoveryStrings(
    wizardTitle: 'ಗೋಲ್ಡನ್ ಅವರ್ ರಿಕವರಿ ಸಹಾಯಕ',
    calmTitle: 'ಶಾಂತರಾಗಿರಿ, ಆತಂಕಪಡಬೇಡಿ',
    calmSubtitle: '1930 ಸಹಾಯವಾಣಿ ಮೂಲಕ ಹಣವನ್ನು ಫ್ರೀಜ್ ಮಾಡಲು ನಿಮಗೆ 24–48 ಗಂಟೆಗಳ ಕಾಲಾವಕಾಶವಿದೆ.',
    call1930Title: 'ಹಂತ 1: 1930 ಸಹಾಯವಾಣಿಗೆ ಕರೆ ಮಾಡಿ',
    call1930Subtitle: 'ವಹಿವಾಟನ್ನು ಸ್ಥಗಿತಗೊಳಿಸಲು ತಕ್ಷಣ ಸೈಬರ್ ಕ್ರೈಮ್ ಸಹಾಯವಾಣಿಯನ್ನು ಸಂಪರ್ಕಿಸಿ.',
    callButton: '1930 ಗೆ ಕರೆ ಮಾಡಿ',
    bankFreezeTitle: 'ಹಂತ 2: ನಿಮ್ಮ ಬ್ಯಾಂಕ್ ಸಂಪರ್ಕಿಸಿ',
    bankFreezeSubtitle: 'ನಿಮ್ಮ ಡೆಬಿಟ್ ಕಾರ್ಡ್ ಮತ್ತು ಯುಪಿಐ ಸೇವೆಯನ್ನು ತಕ್ಷಣ ನಿರ್ಬಂಧಿಸಲು ವಿನಂತಿಸಿ.',
    evidenceTitle: 'ಹಂತ 3: ಸಾಕ್ಷ್ಯಗಳನ್ನು ಸಂಗ್ರಹಿಸಿ',
    evidenceSubtitle: 'ವಹಿವಾಟಿನ ವಿವರಗಳು ಮತ್ತು ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಿ.',
    complaintTitle: 'ಹಂತ 4: ಅಧಿಕೃತ ಸೈಬರ್ ದೂರು',
    complaintSubtitle: 'cybercrime.gov.in ಗಾಗಿ ದೂರಿನ ಕರಡು ಸಿದ್ಧಪಡಿಸಲಾಗಿದೆ.',
    copyComplaint: 'ದೂರು ನಕಲಿಸಿ',
    nextStep: 'ಮುಂದಿನ ಹಂತಕ್ಕೆ ಹೋಗಿ',
    backStep: 'ಹಿಂದಿನ ಹಂತ',
    completedTitle: 'ರಿಕವರಿ ಹಂತಗಳು ಮುಗಿದಿವೆ',
  );

  static const RecoveryStrings ml = RecoveryStrings(
    wizardTitle: 'ഗോൾഡൻ അവർ റിക്കവറി കോപൈലറ്റ്',
    calmTitle: 'ശാന്തത പാലിക്കുക, പരിഭ്രാന്തരാകരുത്',
    calmSubtitle: '1930 ഹെൽപ്പ് ലൈൻ വഴി പണം തടയാൻ നിങ്ങൾക്ക് 24–48 മണിക്കൂർ സമയമുണ്ട്.',
    call1930Title: 'ഘട്ടം 1: 1930 ഹെൽപ്പ് ലൈനിൽ വിളിക്കുക',
    call1930Subtitle: 'ഇടപാടുകൾ തടയുന്നതിന് ഉടൻ തന്നെ സൈബർ ഹെൽപ്പ് ലൈനുമായി ബന്ധപ്പെടുക.',
    callButton: '1930 ലേക്ക് വിളിക്കുക',
    bankFreezeTitle: 'ഘട്ടം 2: ബാങ്കുമായി ബന്ധപ്പെടുക',
    bankFreezeSubtitle: 'നിങ്ങളുടെ കാർഡും യുപിഐയും ബ്ലോക്ക് ചെയ്യാൻ ആവശ്യപ്പെടുക.',
    evidenceTitle: 'ഘട്ടം 3: തെളിവുകൾ സൂക്ഷിക്കുക',
    evidenceSubtitle: 'ഇടപാട് വിവരങ്ങളും സ്ക്രീൻഷോട്ടുകളും സുരക്ഷിതമായി വെക്കുക.',
    complaintTitle: 'ഘട്ടം 4: ഔദ്യോഗിക പരാതി',
    complaintSubtitle: 'cybercrime.gov.in നായി പരാതി തയ്യാറാക്കിയിട്ടുണ്ട്.',
    copyComplaint: 'പരാതി പകർത്തുക',
    nextStep: 'അടുത്ത ഘട്ടത്തിലേക്ക്',
    backStep: 'മുമ്പത്തെ ഘട്ടം',
    completedTitle: 'നടപടികൾ പൂർത്തിയായി',
  );

  static const RecoveryStrings pa = RecoveryStrings(
    wizardTitle: 'ਗੋਲਡਨ ਆਵਰ ਰਿਕਵਰੀ ਕੋਪਾਇਲਟ',
    calmTitle: 'ਸ਼ਾਂਤ ਰਹੋ, ਘਬਰਾਓ ਨਾ',
    calmSubtitle: '1930 ਹੈਲਪਲਾਈਨ ਰਾਹੀਂ ਪੈਸੇ ਫਰੀਜ਼ ਕਰਵਾਉਣ ਲਈ ਤੁਹਾਡੇ ਕੋਲ 24–48 ਘੰਟੇ ਹਨ।',
    call1930Title: 'ਕਦਮ 1: 1930 ਹੈਲਪਲਾਈਨ ਤੇ ਕਾਲ ਕਰੋ',
    call1930Subtitle: 'ਲੈਣ-ਦੇਣ ਰੋਕਣ ਲਈ ਤੁਰੰਤ ਸਾਈਬਰ ਕ੍ਰਾਈਮ ਹੈਲਪਲਾਈਨ ਨਾਲ ਸੰਪਰਕ ਕਰੋ।',
    callButton: '1930 ਤੇ ਕਾਲ ਕਰੋ',
    bankFreezeTitle: 'ਕਦਮ 2: ਆਪਣੇ ਬੈਂਕ ਨਾਲ ਸੰਪਰਕ ਕਰੋ',
    bankFreezeSubtitle: 'ਆਪਣਾ ਡੈਬਿਟ ਕਾਰਡ ਅਤੇ ਯੂਪੀਆਈ ਤੁਰੰਤ ਬਲਾਕ ਕਰਨ ਦੀ ਬੇਨਤੀ ਕਰੋ।',
    evidenceTitle: 'ਕਦਮ 3: ਸਬੂਤ ਸੁਰੱਖਿਅਤ ਰੱਖੋ',
    evidenceSubtitle: 'ਲੈਣ-ਦੇਣ ਆਈਡੀ ਅਤੇ ਚੈਟ ਸਕ੍ਰੀਨਸ਼ੌਟ ਸੰਭਾਲ ਕੇ ਰੱਖੋ।',
    complaintTitle: 'ਕਦਮ 4: ਰਸਮੀ ਸਾਈਬਰ ਸ਼ਿਕਾਇਤ',
    complaintSubtitle: 'cybercrime.gov.in ਲਈ ਸ਼ਿਕਾਇਤ ਦਾ ਖਰੜਾ ਤਿਆਰ ਕੀਤਾ ਗਿਆ ਹੈ।',
    copyComplaint: 'ਸ਼ਿਕਾਇਤ ਕਾਪੀ ਕਰੋ',
    nextStep: 'ਅਗਲੇ ਕਦਮ ਤੇ ਜਾਓ',
    backStep: 'ਪਿਛਲਾ ਕਦਮ',
    completedTitle: 'ਰਿਕਵਰੀ ਕਦਮ ਪੂਰੇ ਹੋਏ',
  );

  static RecoveryStrings forLocale(AppLocale locale) {
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

final Provider<RecoveryStrings> recoveryStringsProvider =
Provider<RecoveryStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return RecoveryStrings.forLocale(locale);
});
