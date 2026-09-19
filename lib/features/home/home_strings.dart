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

  /// Resolves the HomeStrings instance for the chosen locale.
  /// Automatically falls back to English for any other regional languages (Phase 10).
  static HomeStrings forLocale(AppLocale locale) {
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

/// Global provider for home screen strings.
final Provider<HomeStrings> homeStringsProvider =
Provider<HomeStrings>((Ref ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return HomeStrings.forLocale(locale);
});