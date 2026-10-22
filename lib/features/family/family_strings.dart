import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';

@immutable
class FamilyStrings {
  const FamilyStrings({
    required this.familyTitle,
    required this.familySubtitle,
    required this.addMember,
    required this.pairCodeTitle,
    required this.scanPairTitle,
    required this.emptyMembersTitle,
    required this.emptyMembersSubtitle,
    required this.alertSettings,
    required this.alertSettingsSubtitle,
    required this.elderProtectionBadge,
  });

  final String familyTitle;
  final String familySubtitle;
  final String addMember;
  final String pairCodeTitle;
  final String scanPairTitle;
  final String emptyMembersTitle;
  final String emptyMembersSubtitle;
  final String alertSettings;
  final String alertSettingsSubtitle;
  final String elderProtectionBadge;

  static const FamilyStrings en = FamilyStrings(
    familyTitle: 'Family Shield Hub',
    familySubtitle: 'Protect your parents and loved ones by receiving instant alerts when they receive cyber threats.',
    addMember: 'Add Family Member',
    pairCodeTitle: 'My Family Pairing QR',
    scanPairTitle: 'Scan Parent\'s QR Code',
    emptyMembersTitle: 'No Family Members Linked',
    emptyMembersSubtitle: 'Link your elderly parents\' phones to receive alerts if they encounter high-risk scams.',
    alertSettings: 'Alert Sensitivity',
    alertSettingsSubtitle: 'Choose which risk levels trigger guardian notifications.',
    elderProtectionBadge: 'Elder Shield Active',
  );

  static const FamilyStrings hi = FamilyStrings(
    familyTitle: 'फ़ैमिली शील्ड हब',
    familySubtitle: 'अपने माता-पिता और परिजनों को ऑनलाइन खतरों से बचाएं और तुरंत चेतावनी पाएं।',
    addMember: 'सदस्य जोड़ें',
    pairCodeTitle: 'मेरा पेयरिंग क्यूआर कोड',
    scanPairTitle: 'माता-पिता का क्यूआर स्कैन करें',
    emptyMembersTitle: 'कोई सदस्य नहीं जुड़ा है',
    emptyMembersSubtitle: 'माता-पिता के फ़ोन को जोड़ें ताकि घोटाला आने पर आपको तुरंत सूचना मिल सके।',
    alertSettings: 'चेतावनी संवेदनशीलता',
    alertSettingsSubtitle: 'चुनें कि किस स्तर के खतरे पर अलर्ट भेजा जाए।',
    elderProtectionBadge: 'बुज़ुर्ग सुरक्षा चालू',
  );

  static const FamilyStrings mr = FamilyStrings(
    familyTitle: 'फॅमिली शील्ड हब',
    familySubtitle: 'आपल्या पालकांना आणि कुटुंबीयांना ऑनलाइन फसवणुकीपासून सुरक्षित ठेवा आणि त्वरित इशारे मिळवा.',
    addMember: 'कुटुंब सदस्य जोडा',
    pairCodeTitle: 'माझा पेअरिंग क्यूआर कोड',
    scanPairTitle: 'पालकांचा क्यूआर कोड स्कॅन करा',
    emptyMembersTitle: 'कोणतेही सदस्य जोडलेले नाहीत',
    emptyMembersSubtitle: 'पालकांचा फोन जोडा जेणेकरून धोका आल्यास आपल्याला त्वरित अलर्ट मिळेल.',
    alertSettings: 'इशारा संवेदनशीलता',
    alertSettingsSubtitle: 'पालकांसाठी कोणत्या धोक्याचे इशारे पाठवायचे ते निवडा.',
    elderProtectionBadge: 'ज्येष्ठ संरक्षण सुरू',
  );

  static const FamilyStrings ta = FamilyStrings(
    familyTitle: 'குடும்பக் கவசம் மையம்',
    familySubtitle: 'உங்கள் பெற்றோரைப் பாதுகாக்கவும், அச்சுறுத்தல்கள் வந்தால் உடனடி எச்சரிக்கைகளைப் பெறவும்.',
    addMember: 'உறுப்பினரைச் சேர்',
    pairCodeTitle: 'எனது QR குறியீடு',
    scanPairTitle: 'பெற்றோரின் QR குறியீட்டை ஸ்கேன் செய்',
    emptyMembersTitle: 'உறுப்பினர்கள் யாரும் இணைக்கப்படவில்லை',
    emptyMembersSubtitle: 'மோசடிகள் வரும்போது எச்சரிக்கைகளைப் பெற பெற்றோரின் தொலைபேசியை இணைக்கவும்.',
    alertSettings: 'எச்சரிக்கை அமைப்புகள்',
    alertSettingsSubtitle: 'அறிவிப்புகளைத் தூண்டும் ஆபத்து நிலைகளைத் தேர்ந்தெடுக்கவும்.',
    elderProtectionBadge: 'முதியோர் பாதுகாப்பு இயக்கப்பட்டது',
  );

  static const FamilyStrings te = FamilyStrings(
    familyTitle: 'ఫ్యామిలీ షీల్డ్ హబ్',
    familySubtitle: 'మీ తల్లిదండ్రులను మోసాల నుండి కాపాడండి మరియు ముప్పు వచ్చినప్పుడు తక్షణ హెచ్చరికలను పొందండి.',
    addMember: 'సభ్యుడిని జోడించండి',
    pairCodeTitle: 'నా జతచేసే QR కోడ్',
    scanPairTitle: 'తల్లిదండ్రుల QR కోడ్‌ను స్కాన్ చేయండి',
    emptyMembersTitle: 'కుటుంబ సభ్యులు ఎవరూ లింక్ చేయబడలేదు',
    emptyMembersSubtitle: 'మోసాలు జరిగినప్పుడు హెచ్చరికలు పొందడానికి తల్లిదండ్రుల ఫోన్‌ను లింక్ చేయండి.',
    alertSettings: 'హెచ్చరిక సెట్టింగ్‌లు',
    alertSettingsSubtitle: 'ఏ స్థాయి ముప్పు వచ్చినప్పుడు అలర్ట్ రావాలో ఎంచుకోండి.',
    elderProtectionBadge: 'సీనియర్ రక్షణ యాక్టివ్',
  );

  static const FamilyStrings bn = FamilyStrings(
    familyTitle: 'ফ্যামিলি শিল্ড হাব',
    familySubtitle: 'সাইবার হুমকি এলে তাৎক্ষণিক সতর্কতা পেতে আপনার বাবা-মা ও প্রিয়জনদের সুরক্ষা দিন।',
    addMember: 'সদস্য যোগ করুন',
    pairCodeTitle: 'আমার পেয়ারিং কিউআর কোড',
    scanPairTitle: 'পিতামাতার কিউআর স্ক্যান করুন',
    emptyMembersTitle: 'কোনো সদস্য যুক্ত নেই',
    emptyMembersSubtitle: 'বিপদ এলে সতর্কতা পেতে আপনার পরিবারের সদস্যদের ফোন লিঙ্ক করুন।',
    alertSettings: 'সতর্কতা সংবেদনশীলতা',
    alertSettingsSubtitle: 'কোন ঝুঁকির স্তরে নোটিফিকেশন পাঠানো হবে তা নির্বাচন করুন।',
    elderProtectionBadge: 'প্রবীণ সুরক্ষা সক্রিয়',
  );

  static const FamilyStrings gu = FamilyStrings(
    familyTitle: 'ફેમિલી શિલ્ડ હબ',
    familySubtitle: 'તમારા માતાપિતા અને પરિવારને સાયબર જોખમોથી બચાવો અને તુરંત એલર્ટ મેળવો.',
    addMember: 'સભ્ય ઉમેરો',
    pairCodeTitle: 'મારો પેરિંગ QR કોડ',
    scanPairTitle: 'વાલીનો QR કોડ સ્કેન કરો',
    emptyMembersTitle: 'કોઈ સભ્ય જોડાયેલ નથી',
    emptyMembersSubtitle: 'છેતરપિંડી સમયે ચેતવણી મેળવવા માટે પરિવારના ફોનને લિંક કરો.',
    alertSettings: 'ચેતવણી સેટિંગ્સ',
    alertSettingsSubtitle: 'ક્યા જોખમ સ્તરે સૂચના મોકલવી તે પસંદ કરો.',
    elderProtectionBadge: 'વરિષ્ઠ સુરક્ષા સક્રિય',
  );

  static const FamilyStrings kn = FamilyStrings(
    familyTitle: 'ಫ್ಯಾಮಿಲಿ ಶೀಲ್ಡ್ ಹಬ್',
    familySubtitle: 'ಸೈಬರ್ ಬೆದರಿಕೆಗಳು ಬಂದಾಗ ತಕ್ಷಣ ಎಚ್ಚರಿಕೆಗಳನ್ನು ಸ್ವೀಕರಿಸಲು ನಿಮ್ಮ ಪೋಷಕರನ್ನು ರಕ್ಷಿಸಿ.',
    addMember: 'ಸದಸ್ಯರನ್ನು ಸೇರಿಸಿ',
    pairCodeTitle: 'ನನ್ನ ಜೋಡಣೆ QR ಕೋಡ್',
    scanPairTitle: 'ಪೋಷಕರ QR ಕೋಡ್ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
    emptyMembersTitle: 'ಯಾವುದೇ ಸದಸ್ಯರು ಲಿಂಕ್ ಆಗಿಲ್ಲ',
    emptyMembersSubtitle: 'ವಂಚನೆ ಸಂದೇಶ ಬಂದಾಗ ಎಚ್ಚರಿಕೆ ಪಡೆಯಲು ಪೋಷಕರ ಫೋನ್ ಲಿಂಕ್ ಮಾಡಿ.',
    alertSettings: 'ಎಚ್ಚರಿಕೆ ಸೂಕ್ಷ್ಮತೆ',
    alertSettingsSubtitle: 'ಯಾವ ಹಂತದ ಅಪಾಯಕ್ಕೆ ಸೂಚನೆ ಕಳುಹಿಸಬೇಕೆಂದು ಆಯ್ಕೆಮಾಡಿ.',
    elderProtectionBadge: 'ಹಿರಿಯರ ರಕ್ಷಣೆ ಸಕ್ರಿಯವಾಗಿದೆ',
  );

  static const FamilyStrings ml = FamilyStrings(
    familyTitle: 'ഫാമിലി ഷീൽഡ് ഹബ്ബ്',
    familySubtitle: 'സൈബർ തട്ടിപ്പുകൾ ഉണ്ടാകുമ്പോൾ തത്സമയം മുന്നറിയിപ്പുകൾ ലഭിക്കാൻ മാതാപിതാക്കളെ സുരക്ഷിതരാക്കുക.',
    addMember: 'അംഗത്തെ ചേർക്കുക',
    pairCodeTitle: 'എന്റെ ക്യുആർ കോഡ്',
    scanPairTitle: 'രക്ഷിതാവിന്റെ ക്യുആർ സ്കാൻ ചെയ്യുക',
    emptyMembersTitle: 'കുടുംബാംഗങ്ങളാരും ലിങ്ക് ചെയ്തിട്ടില്ല',
    emptyMembersSubtitle: 'അപകടസാധ്യതയുള്ള തട്ടിപ്പുകൾ വരുമ്പോൾ അലേർട്ടുകൾ ലഭിക്കാൻ രക്ഷിതാക്കളുടെ ഫോൺ ലിങ്ക് ചെയ്യുക.',
    alertSettings: 'അലേർട്ട് ക്രമീകരണങ്ങൾ',
    alertSettingsSubtitle: 'ഏത് തലത്തിലുള്ള ഭീഷണികൾക്കാണ് മുന്നറിയിപ്പ് വേണ്ടതെന്ന് തിരഞ്ഞെടുക്കുക.',
    elderProtectionBadge: 'മുതിർന്നവർക്കുള്ള സംരക്ഷണം സജീവം',
  );

  static const FamilyStrings pa = FamilyStrings(
    familyTitle: 'ਫੈਮਿਲੀ ਸ਼ੀਲਡ ਹੱਬ',
    familySubtitle: 'ਸਾਈਬਰ ਖ਼ਤਰੇ ਆਉਣ ਤੇ ਤੁਰੰਤ ਅਲਰਟ ਪ੍ਰਾਪਤ ਕਰਨ ਲਈ ਆਪਣੇ ਮਾਪਿਆਂ ਦੀ ਸੁਰੱਖਿਆ ਕਰੋ।',
    addMember: 'ਮੈਂਬਰ ਸ਼ਾਮਲ ਕਰੋ',
    pairCodeTitle: 'ਮੇਰਾ ਪੇਅਰਿੰਗ QR ਕੋਡ',
    scanPairTitle: 'ਮਾਪਿਆਂ ਦਾ QR ਕੋਡ ਸਕੈਨ ਕਰੋ',
    emptyMembersTitle: 'ਕੋਈ ਮੈਂਬਰ ਲਿੰਕ ਨਹੀਂ ਹੈ',
    emptyMembersSubtitle: 'ਧੋਖਾਧੜੀ ਆਉਣ ਤੇ ਚੇਤਾਵਨੀ ਪ੍ਰਾਪਤ ਕਰਨ ਲਈ ਮਾਪਿਆਂ ਦੇ ਫ਼ੋਨ ਨੂੰ ਲਿੰਕ ਕਰੋ।',
    alertSettings: 'ਅਲਰਟ ਸੈਟਿੰਗਾਂ',
    alertSettingsSubtitle: 'ਚੁਣੋ ਕਿ ਕਿਹੜੇ ਖ਼ਤਰੇ ਦੇ ਪੱਧਰ ਤੇ ਸੂਚਨਾ ਭੇਜੀ ਜਾਵੇ।',
    elderProtectionBadge: 'ਬਜ਼ੁਰਗ ਸੁਰੱਖਿਆ ਚਾਲੂ ਹੈ',
  );

  static FamilyStrings forLocale(AppLocale locale) {
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

final Provider<FamilyStrings> familyStringsProvider =
Provider<FamilyStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return FamilyStrings.forLocale(locale);
});
