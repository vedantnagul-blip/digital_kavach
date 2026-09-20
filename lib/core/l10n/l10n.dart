import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/user_prefs.dart';
import 'strings_base.dart';
import 'strings_bn.dart';
import 'strings_en.dart';
import 'strings_gu.dart';
import 'strings_hi.dart';
import 'strings_kn.dart';
import 'strings_ml.dart';
import 'strings_mr.dart';
import 'strings_pa.dart';
import 'strings_ta.dart';
import 'strings_te.dart';

/// Supported UI languages for Digital Kavach (10 Languages).
enum AppLocale {
  en('en', 'English'),
  hi('hi', 'हिंदी'),
  mr('mr', 'मराठी'),
  ta('ta', 'தமிழ்'),
  te('te', 'తెలుగు'),
  bn('bn', 'বাংলা'),
  gu('gu', 'ગુજરાતી'),
  kn('kn', 'ಕನ್ನಡ'),
  ml('ml', 'മലയാളം'),
  pa('pa', 'ਪੰਜਾਬੀ');

  const AppLocale(this.code, this.nativeName);
  final String code;
  final String nativeName;

  Locale toLocale() => Locale(code);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
          (AppLocale l) => l.code == code,
      orElse: () => AppLocale.en,
    );
  }
}

/// L10n singleton — resolves current [StringsBase] impl by [AppLocale].
class L10n {
  const L10n(this.locale, this.strings);

  final AppLocale locale;
  final StringsBase strings;

  static L10n forLocale(AppLocale locale) {
    switch (locale) {
      case AppLocale.hi:
        return const L10n(AppLocale.hi, StringsHi());
      case AppLocale.mr:
        return const L10n(AppLocale.mr, StringsMr());
      case AppLocale.ta:
        return const L10n(AppLocale.ta, StringsTa());
      case AppLocale.te:
        return const L10n(AppLocale.te, StringsTe());
      case AppLocale.bn:
        return const L10n(AppLocale.bn, StringsBn());
      case AppLocale.gu:
        return const L10n(AppLocale.gu, StringsGu());
      case AppLocale.kn:
        return const L10n(AppLocale.kn, StringsKn());
      case AppLocale.ml:
        return const L10n(AppLocale.ml, StringsMl());
      case AppLocale.pa:
        return const L10n(AppLocale.pa, StringsPa());
      case AppLocale.en:
        return const L10n(AppLocale.en, StringsEn());
    }
  }

  /// Bilingual convenience: "native / English" — for error surfaces where we
  /// deliberately show both to reassure non-English readers.
  String bilingual(String Function(StringsBase) selector) {
    if (locale == AppLocale.en) return selector(strings);
    final String native = selector(strings);
    final String english = selector(const StringsEn());
    if (native == english) return native;
    return '$native / $english';
  }
}

/// Selected locale — restored from user preferences.
final StateProvider<AppLocale> localeProvider =
StateProvider<AppLocale>((StateProviderRef<AppLocale> ref) {
  final UserPrefs prefs = ref.watch(userPrefsProvider);
  final String? saved = prefs.langCode;
  if (saved != null && saved.isNotEmpty) {
    return AppLocale.fromCode(saved);
  }
  return AppLocale.en;
});

/// Derived L10n bundle.
final Provider<L10n> l10nProvider = Provider<L10n>((Ref<L10n> ref) {
  final AppLocale locale = ref.watch(localeProvider);
  return L10n.forLocale(locale);
});