import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class ScannerStrings {
  const ScannerStrings({
    required this.hubTitle,
    required this.tabPaste,
    required this.tabScreenshot,
    required this.tabLiveQr,
    required this.inspectText,
    required this.pasteClipboard,
    required this.hintText,
    required this.scanButton,
    required this.screenshotTitle,
    required this.screenshotSubtitle,
    required this.gallery,
    required this.camera,
    required this.ocrLoading,
    required this.verdictTitle,
    required this.shareTooltip,
    required this.doneButton,
    required this.viewScannedContent,
  });

  final String hubTitle;
  final String tabPaste;
  final String tabScreenshot;
  final String tabLiveQr;
  final String inspectText;
  final String pasteClipboard;
  final String hintText;
  final String scanButton;
  final String screenshotTitle;
  final String screenshotSubtitle;
  final String gallery;
  final String camera;
  final String ocrLoading;
  final String verdictTitle;
  final String shareTooltip;
  final String doneButton;
  final String viewScannedContent;

  static const ScannerStrings en = ScannerStrings(
    hubTitle: 'Scanner Hub',
    tabPaste: 'Paste Text',
    tabScreenshot: 'Screenshot',
    tabLiveQr: 'Live QR',
    inspectText: 'Inspect Text',
    pasteClipboard: 'Paste Clipboard',
    hintText: 'Paste WhatsApp message, SMS, or link here...',
    scanButton: 'Scan Text',
    screenshotTitle: 'Screenshot OCR Scan',
    screenshotSubtitle: 'Upload a payment screenshot, WhatsApp chat image, or fake offer banner.',
    gallery: 'Gallery',
    camera: 'Camera',
    ocrLoading: 'Reading text via ML Kit OCR...',
    verdictTitle: 'Scan Verdict',
    shareTooltip: 'Share Verdict',
    doneButton: 'Done / Back to Home',
    viewScannedContent: 'View Scanned Content',
  );

  static const ScannerStrings hi = ScannerStrings(
    hubTitle: 'स्कैनर हब',
    tabPaste: 'टेक्स्ट चिपकाएँ',
    tabScreenshot: 'स्क्रीनशॉट',
    tabLiveQr: 'लाइव क्यूआर',
    inspectText: 'टेक्स्ट जाँचें',
    pasteClipboard: 'क्लिपबोर्ड से लें',
    hintText: 'यहाँ व्हाट्सएप संदेश, एसएमएस या लिंक चिपकाएँ...',
    scanButton: 'संदेश जाँचें',
    screenshotTitle: 'स्क्रीनशॉट ओसीआर स्कैन',
    screenshotSubtitle: 'पेमेंट स्क्रीनशॉट, व्हाट्सएप चैट या फ़र्ज़ी ऑफ़र की फ़ोटो अपलोड करें।',
    gallery: 'गैलरी',
    camera: 'कैमरा',
    ocrLoading: 'एमएल किट ओसीआर द्वारा टेक्स्ट पढ़ा जा रहा है...',
    verdictTitle: 'जाँच का परिणाम',
    shareTooltip: 'परिणाम साझा करें',
    doneButton: 'हो गया / होम पर वापस',
    viewScannedContent: 'स्कैन की गई सामग्री देखें',
  );

  static const ScannerStrings mr = ScannerStrings(
    hubTitle: 'स्कॅनर हब',
    tabPaste: 'मजकूर टाका',
    tabScreenshot: 'स्क्रीनशॉट',
    tabLiveQr: 'थेट क्यूआर',
    inspectText: 'मजकूर तपासा',
    pasteClipboard: 'क्लिपबोर्डवरून घ्या',
    hintText: 'येथे व्हॉट्सअ‍ॅप संदेश, एसएमएस किंवा लिंक टाका...',
    scanButton: 'मजकूर तपासा',
    screenshotTitle: 'स्क्रीनशॉट ओसीआर स्कॅन',
    screenshotSubtitle: 'पेमेंट स्क्रीनशॉट, व्हॉट्सअ‍ॅप चॅट किंवा बनावट ऑफर बॅनर अपलोड करा.',
    gallery: 'गॅलरी',
    camera: 'कॅमेरा',
    ocrLoading: 'एमएल किट ओसीआर द्वारे मजकूर वाचत आहे...',
    verdictTitle: 'तपासणी निकाल',
    shareTooltip: 'निकाल शेअर करा',
    doneButton: 'पूर्ण झाले / होमवर जा',
    viewScannedContent: 'स्कॅन केलेली सामग्री पहा',
  );

  static const ScannerStrings ta = ScannerStrings(
    hubTitle: 'ஸ்கேனர் மையம்',
    tabPaste: 'உரையை ஒட்டவும்',
    tabScreenshot: 'திரைக்காட்சி',
    tabLiveQr: 'நேரலை QR',
    inspectText: 'உரையை ஆய்வு செய்',
    pasteClipboard: 'கிளிப்போர்டிலிருந்து ஒட்டு',
    hintText: 'WhatsApp செய்தி, SMS அல்லது இணைப்பை இங்கே ஒட்டவும்...',
    scanButton: 'உரையை ஸ்கேன் செய்',
    screenshotTitle: 'திரைக்காட்சி OCR ஸ்கேன்',
    screenshotSubtitle: 'பணம் செலுத்திய திரைக்காட்சி அல்லது WhatsApp அரட்டையைப் பதிவேற்றவும்.',
    gallery: 'கேலரி',
    camera: 'கேமரா',
    ocrLoading: 'OCR மூலம் உரை படிக்கப்படுகிறது...',
    verdictTitle: 'ஸ்கேன் முடிவு',
    shareTooltip: 'முடிவைப் பகிரவும்',
    doneButton: 'முடிந்தது / முகப்புக்கு செல்',
    viewScannedContent: 'ஸ்கேன் செய்யப்பட்ட உள்ளடக்கத்தைக் காண்க',
  );

  static const ScannerStrings te = ScannerStrings(
    hubTitle: 'స్కానర్ హబ్',
    tabPaste: 'టెక్స్ట్ అతికించు',
    tabScreenshot: 'స్క్రీన్‌షాట్',
    tabLiveQr: 'లైవ్ QR',
    inspectText: 'టెక్స్ట్‌ను పరిశీలించండి',
    pasteClipboard: 'క్లిప్‌బోర్డ్ నుండి అతికించు',
    hintText: 'WhatsApp సందేశం, SMS లేదా లింక్‌ను ఇక్కడ అతికించండి...',
    scanButton: 'టెక్స్ట్‌ను స్కాన్ చేయండి',
    screenshotTitle: 'స్క్రీన్‌షాట్ OCR స్కాన్',
    screenshotSubtitle: 'చెల్లింపు స్క్రీన్‌షాట్ లేదా WhatsApp చాట్ చిత్రాన్ని అప్‌లోడ్ చేయండి.',
    gallery: 'గ్యాలరీ',
    camera: 'కెమెరా',
    ocrLoading: 'OCR ద్వారా వచనాన్ని చదువుతోంది...',
    verdictTitle: 'స్కాన్ ఫలితం',
    shareTooltip: 'ఫలితాన్ని పంచుకోండి',
    doneButton: 'పూర్తయింది / హోమ్‌కి వెళ్లండి',
    viewScannedContent: 'స్కాన్ చేసిన కంటెంట్‌ను వీక్షించండి',
  );

  static const ScannerStrings bn = ScannerStrings(
    hubTitle: 'স্ক্যানার হাব',
    tabPaste: 'টেক্সট পেস্ট করুন',
    tabScreenshot: 'স্ক্রিনশট',
    tabLiveQr: 'লাইভ কিউআর',
    inspectText: 'টেক্সট পরীক্ষা করুন',
    pasteClipboard: 'ক্লিপবোর্ড থেকে নিন',
    hintText: 'এখানে হোয়াটসঅ্যাপ বার্তা, এসএমএস বা লিঙ্ক পেস্ট করুন...',
    scanButton: 'টেক্সট স্ক্যান করুন',
    screenshotTitle: 'স্ক্রিনশট ওসিআর স্ক্যান',
    screenshotSubtitle: 'পেমেন্ট স্ক্রিনশট বা হোয়াটসঅ্যাপ চ্যাট ছবি আপলোড করুন।',
    gallery: 'গ্যালারি',
    camera: 'ক্যামেরা',
    ocrLoading: 'ওসিআর দ্বারা লেখা পড়া হচ্ছে...',
    verdictTitle: 'স্ক্যানের ফলাফল',
    shareTooltip: 'ফলাফল শেয়ার করুন',
    doneButton: 'সম্পন্ন / হোমে ফিরুন',
    viewScannedContent: 'স্ক্যান করা বিষয়বস্তু দেখুন',
  );

  static const ScannerStrings gu = ScannerStrings(
    hubTitle: 'સ્કેનર હબ',
    tabPaste: 'ટેક્સ્ટ પેસ્ટ કરો',
    tabScreenshot: 'સ્ક્રીનશોટ',
    tabLiveQr: 'લાઇવ ક્યૂઆર',
    inspectText: 'ટેક્સ્ટ તપાસો',
    pasteClipboard: 'ક્લિપબોર્ડ પરથી લો',
    hintText: 'અહીં WhatsApp સંદેશ, SMS અથવા લિંક પેસ્ટ કરો...',
    scanButton: 'સંદેશ તપાસો',
    screenshotTitle: 'સ્ક્રીનશોટ OCR સ્કેન',
    screenshotSubtitle: 'પેમેન્ટ સ્ક્રીનશોટ અથવા WhatsApp ચેટ છબી અપલોડ કરો.',
    gallery: 'ગેલેરી',
    camera: 'કેમેરા',
    ocrLoading: 'OCR દ્વારા ટેક્સ્ટ વાંચવામાં આવી રહ્યો છે...',
    verdictTitle: 'તપાસ પરિણામ',
    shareTooltip: 'પરિણામ શેર કરો',
    doneButton: 'પૂર્ણ / હોમ પર પાછા',
    viewScannedContent: 'સ્કેન કરેલી સામગ્રી જુઓ',
  );

  static const ScannerStrings kn = ScannerStrings(
    hubTitle: 'ಸ್ಕ್ಯಾನರ್ ಹಬ್',
    tabPaste: 'ಪಠ್ಯವನ್ನು ಅಂಟಿಸಿ',
    tabScreenshot: 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್',
    tabLiveQr: 'ಲೈವ್ QR',
    inspectText: 'ಪಠ್ಯವನ್ನು ಪರೀಕ್ಷಿಸಿ',
    pasteClipboard: 'ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ನಿಂದ ಅಂಟಿಸಿ',
    hintText: 'WhatsApp ಸಂದೇಶ, SMS ಅಥವಾ ಲಿಂಕ್ ಅನ್ನು ಇಲ್ಲಿ ಅಂಟಿಸಿ...',
    scanButton: 'ಪಠ್ಯವನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
    screenshotTitle: 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ OCR ಸ್ಕ್ಯಾನ್',
    screenshotSubtitle: 'ಪಾವತಿ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅಥವಾ WhatsApp ಚಾಟ್ ಚಿತ್ರವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.',
    gallery: 'ಗ್ಯಾಲರಿ',
    camera: 'ಕ್ಯಾಮೆರಾ',
    ocrLoading: 'OCR ಮೂಲಕ ಪಠ್ಯವನ್ನು ಓದಲಾಗುತ್ತಿದೆ...',
    verdictTitle: 'ಸ್ಕ್ಯಾನ್ ಫಲಿತಾಂಶ',
    shareTooltip: 'ಫಲಿತಾಂಶವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ',
    doneButton: 'ಮುಗಿದಿದೆ / ಮುಖಪುಟಕ್ಕೆ ಹಿಂತಿರುಗಿ',
    viewScannedContent: 'ಸ್ಕ್ಯಾನ್ ಮಾಡಿದ ವಿಷಯವನ್ನು ವೀಕ್ಷಿಸಿ',
  );

  static const ScannerStrings ml = ScannerStrings(
    hubTitle: 'സ്കാനർ ഹബ്ബ്',
    tabPaste: 'ടെക്സ്റ്റ് ഒട്ടിക്കുക',
    tabScreenshot: 'സ്ക്രീൻഷോട്ട്',
    tabLiveQr: 'തത്സമയ QR',
    inspectText: 'ടെക്സ്റ്റ് പരിശോധിക്കുക',
    pasteClipboard: 'ക്ലിപ്പ്ബോർഡിൽ നിന്ന് ഒട്ടിക്കുക',
    hintText: 'WhatsApp സന്ദേശം, SMS അല്ലെങ്കിൽ ലിങ്ക് ഇവിടെ ഒട്ടിക്കുക...',
    scanButton: 'സന്ദേശം സ്കാൻ ചെയ്യുക',
    screenshotTitle: 'സ്ക്രീൻഷോട്ട് OCR സ്കാൻ',
    screenshotSubtitle: 'പേയ്‌മെന്റ് സ്ക്രീൻഷോട്ടോ ചാറ്റ് ചിത്രമോ അപ്‌ലോഡ് ചെയ്യുക.',
    gallery: 'ഗാലറി',
    camera: 'ക്യാമറ',
    ocrLoading: 'ടെക്സ്റ്റ് വായിക്കുന്നു...',
    verdictTitle: 'സ്കാൻ ഫലം',
    shareTooltip: 'ഫലം പങ്കിടുക',
    doneButton: 'പൂർത്തിയായി / ഹോമിലേക്ക്',
    viewScannedContent: 'സ്കാൻ ചെയ്ത വിവരങ്ങൾ കാണുക',
  );

  static const ScannerStrings pa = ScannerStrings(
    hubTitle: 'ਸਕੈਨਰ ਹੱਬ',
    tabPaste: 'ਟੈਕਸਟ ਪੇਸਟ ਕਰੋ',
    tabScreenshot: 'ਸਕ੍ਰੀਨਸ਼ੌਟ',
    tabLiveQr: 'ਲਾਈਵ QR',
    inspectText: 'ਟੈਕਸਟ ਦੀ ਜਾਂਚ ਕਰੋ',
    pasteClipboard: 'ਕਲਿੱਪਬੋਰਡ ਤੋਂ ਪੇਸਟ ਕਰੋ',
    hintText: 'ਇੱਥੇ WhatsApp ਸੁਨੇਹਾ, SMS ਜਾਂ ਲਿੰਕ ਪੇਸਟ ਕਰੋ...',
    scanButton: 'ਸੁਨੇਹਾ ਸਕੈਨ ਕਰੋ',
    screenshotTitle: 'ਸਕ੍ਰੀਨਸ਼ੌਟ OCR ਸਕੈਨ',
    screenshotSubtitle: 'ਭੁਗਤਾਨ ਸਕ੍ਰੀਨਸ਼ੌਟ ਜਾਂ WhatsApp ਗੱਲਬਾਤ ਦੀ ਤਸਵੀਰ ਅੱਪਲੋਡ ਕਰੋ।',
    gallery: 'ਗੈਲਰੀ',
    camera: 'ਕੈਮਰਾ',
    ocrLoading: 'OCR ਰਾਹੀਂ ਟੈਕਸਟ ਪੜ੍ਹਿਆ ਜਾ ਰਿਹਾ ਹੈ...',
    verdictTitle: 'ਸਕੈਨ ਨਤੀਜਾ',
    shareTooltip: 'ਨਤੀਜਾ ਸਾਂਝਾ ਕਰੋ',
    doneButton: 'ਮੁਕੰਮਲ / ਹੋਮ ਤੇ ਵਾਪਸ',
    viewScannedContent: 'ਸਕੈਨ ਕੀਤੀ ਸਮੱਗਰੀ ਵੇਖੋ',
  );

  static ScannerStrings forLocale(AppLocale locale) {
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

final Provider<ScannerStrings> scannerStringsProvider =
Provider<ScannerStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return ScannerStrings.forLocale(locale);
});
