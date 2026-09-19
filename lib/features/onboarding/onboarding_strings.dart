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

  static const OnboardingStrings en = OnboardingStrings(
    progressLabel: 'Step',
    next: 'Continue',
    back: 'Back',
    skip: 'Skip',
    finish: 'Finish',
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
    sentinelSubtitle: 'Automatic protection while your phone stays locked.',
    sentinelStepNotifAccess: 'Notification Access',
    sentinelStepBattery: 'Battery-saver exemption',
    sentinelStepPostNotif: 'Show warnings on lock screen',
    sentinelLater: 'Set up later',
    sentinelLockedNote:
    'Setup wizard available in the next app update. You can enable it any time from Settings → Sentinel.',
  );

  static const OnboardingStrings hi = OnboardingStrings(
    progressLabel: 'चरण',
    next: 'आगे बढ़ें',
    back: 'वापस',
    skip: 'छोड़ें',
    finish: 'पूरा करें',
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
    sentinelSubtitle: 'फ़ोन बंद हो तब भी अपने-आप सुरक्षा।',
    sentinelStepNotifAccess: 'Notification Access',
    sentinelStepBattery: 'बैटरी-सेवर से छूट',
    sentinelStepPostNotif: 'लॉक स्क्रीन पर चेतावनी दिखाएँ',
    sentinelLater: 'बाद में सेट-अप करें',
    sentinelLockedNote:
    'सेटअप विज़ार्ड अगले ऐप अपडेट में। सेटिंग्स → Sentinel से कभी भी चालू कर सकते हैं।',
  );

  static const OnboardingStrings mr = OnboardingStrings(
    progressLabel: 'पायरी',
    next: 'पुढे',
    back: 'मागे',
    skip: 'वगळा',
    finish: 'पूर्ण करा',
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
    'فक्त तुम्ही निवडलेल्या अ‍ॅप्सचे notifications (WhatsApp, SMS, Telegram). कधीही call log किंवा contacts नाही.',
    consentLocalTitle: 'फोनमध्ये काय राहते',
    consentLocalBody:
    'सर्व तपासणी आधी तुमच्या फोनवरच होते. सुरक्षित संदेश कधीच बाहेर जात नाहीत.',
    consentLeavesTitle: 'फोनमधून काय जाते',
    consentLeavesBody:
    'فक्त धोकादायक वाटलेले संदेश — तुमच्या परवानगीने AI (Gemini) कडे पाठवले जातात.',
    consentStorageTitle: 'आम्ही काय साठवतो',
    consentStorageBody:
    'فक्त निकालाचा छोटा fingerprint (hash) — मूळ संदेश कधीच नाही.',
    consentAllow: 'AI डीप-स्कॅन ला परवानगी द्या',
    consentOfflineOnly: 'فक्त ऑफलाइन तपासणी',
    consentFooter:
    'सेटिंग्जमध्ये कधीही बदलू शकता. AI चे मत — अंतिम निर्णय तुमचा.',
    sentinelTitle: 'Kavach Sentinel चालू करा',
    sentinelSubtitle: 'फोन लॉक असतानाही आपोआप संरक्षण.',
    sentinelStepNotifAccess: 'Notification Access',
    sentinelStepBattery: 'बॅटरी-सेव्हर सूट',
    sentinelStepPostNotif: 'लॉक स्क्रीनवर इशारे दाखवा',
    sentinelLater: 'नंतर सेट-अप करा',
    sentinelLockedNote:
    'सेटअप विझार्ड पुढच्या अ‍ॅप अपडेटमध्ये. सेटिंग्ज → Sentinel वरून कधीही सुरू करू शकता.',
  );

  /// Resolves the OnboardingStrings instance for the chosen locale.
  /// Automatically falls back to English for any other regional languages (Phase 10).
  static OnboardingStrings forLocale(AppLocale locale) {
    switch (locale) {
      case AppLocale.hi:
        return hi;
      case AppLocale.mr:
        return mr;
      case AppLocale.en:
      default:
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