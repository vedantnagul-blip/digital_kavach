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

  static const HomeStrings en = HomeStrings(
    goodMorning: 'Good morning',
    goodAfternoon: 'Good afternoon',
    goodEvening: 'Good evening',
    guestBadge: 'Guest',
    elderBadge: 'Elder Mode',
    standardBadge: 'Standard',
    langBadgePrefix: 'Lang',
    navHome: 'Home',
    navFeed: 'Feed',
    navSettings: 'Settings',
    centralScanTooltip: 'Scan a message',
    notImplementedYet: 'Available in a future update.',
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
  );

  /// Resolves the HomeStrings instance for the chosen locale.
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

/// Global provider for home screen strings.
final Provider<HomeStrings> homeStringsProvider =
Provider<HomeStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return HomeStrings.forLocale(locale);
});