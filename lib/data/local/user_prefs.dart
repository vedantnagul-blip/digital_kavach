import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/app_logger.dart';

/// Single global declaration for [userPrefsProvider].
final Provider<UserPrefs> userPrefsProvider = Provider<UserPrefs>((Ref ref) {
  return UserPrefs.create();
});

/// Typed accessor over Hive `prefs` box.
abstract class UserPrefs {
  factory UserPrefs.create() {
    try {
      if (!Hive.isBoxOpen('prefs')) {
        AppLogger.w('prefs box not open — using in-memory fallback');
        return _InMemoryUserPrefs();
      }
      return _HiveUserPrefs(Hive.box<dynamic>('prefs'));
    } catch (e) {
      AppLogger.w('UserPrefs fallback (Hive unavailable): $e');
      return _InMemoryUserPrefs();
    }
  }

  // Onboarding flow state
  String? get langCode;
  Future<void> setLangCode(String v);

  String? get modeCode; // 'standard' | 'elder'
  Future<void> setModeCode(String v);

  bool get signInDone;
  Future<void> setSignInDone(bool v);

  bool get isGuest;
  Future<void> setIsGuest(bool v);

  bool? get consentAi;
  Future<void> setConsentAi(bool v);

  DateTime? get consentTs;
  Future<void> setConsentTs(DateTime v);

  int get consentVersion;
  Future<void> setConsentVersion(int v);

  bool get sentinelSetupDone;
  Future<void> setSentinelSetupDone(bool v);

  bool get isOnboarded;
  Future<void> setOnboarded(bool v);

  Future<void> clearAll();
}

// === Hive-backed implementation ===
class _HiveUserPrefs implements UserPrefs {
  _HiveUserPrefs(this._box);
  final Box<dynamic> _box;

  static const String _kLang = 'onboarding.lang';
  static const String _kMode = 'onboarding.mode';
  static const String _kSignIn = 'onboarding.signInDone';
  static const String _kGuest = 'onboarding.isGuest';
  static const String _kConsentAi = 'onboarding.consentAi';
  static const String _kConsentTs = 'onboarding.consentTs';
  static const String _kConsentVer = 'onboarding.consentVersion';
  static const String _kSentinel = 'onboarding.sentinelSetupDone';
  static const String _kOnboarded = 'onboarding.done';

  @override
  String? get langCode => _box.get(_kLang) as String?;
  @override
  Future<void> setLangCode(String v) => _box.put(_kLang, v);

  @override
  String? get modeCode => _box.get(_kMode) as String?;
  @override
  Future<void> setModeCode(String v) => _box.put(_kMode, v);

  @override
  bool get signInDone =>
      _box.get(_kSignIn, defaultValue: false) as bool;
  @override
  Future<void> setSignInDone(bool v) => _box.put(_kSignIn, v);

  @override
  bool get isGuest => _box.get(_kGuest, defaultValue: false) as bool;
  @override
  Future<void> setIsGuest(bool v) => _box.put(_kGuest, v);

  @override
  bool? get consentAi => _box.get(_kConsentAi) as bool?;
  @override
  Future<void> setConsentAi(bool v) => _box.put(_kConsentAi, v);

  @override
  DateTime? get consentTs {
    final int? ms = _box.get(_kConsentTs) as int?;
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  Future<void> setConsentTs(DateTime v) =>
      _box.put(_kConsentTs, v.millisecondsSinceEpoch);

  @override
  int get consentVersion =>
      _box.get(_kConsentVer, defaultValue: 0) as int;
  @override
  Future<void> setConsentVersion(int v) => _box.put(_kConsentVer, v);

  @override
  bool get sentinelSetupDone =>
      _box.get(_kSentinel, defaultValue: false) as bool;
  @override
  Future<void> setSentinelSetupDone(bool v) =>
      _box.put(_kSentinel, v);

  @override
  bool get isOnboarded =>
      _box.get(_kOnboarded, defaultValue: false) as bool;
  @override
  Future<void> setOnboarded(bool v) => _box.put(_kOnboarded, v);

  @override
  Future<void> clearAll() async {
    await _box.deleteAll(<String>[
      _kLang,
      _kMode,
      _kSignIn,
      _kGuest,
      _kConsentAi,
      _kConsentTs,
      _kConsentVer,
      _kSentinel,
      _kOnboarded,
    ]);
  }
}

// === In-memory fallback ===
class _InMemoryUserPrefs implements UserPrefs {
  final Map<String, dynamic> _m = <String, dynamic>{};

  @override
  String? get langCode => _m['lang'] as String?;
  @override
  Future<void> setLangCode(String v) async => _m['lang'] = v;

  @override
  String? get modeCode => _m['mode'] as String?;
  @override
  Future<void> setModeCode(String v) async => _m['mode'] = v;

  @override
  bool get signInDone => (_m['signIn'] as bool?) ?? false;
  @override
  Future<void> setSignInDone(bool v) async => _m['signIn'] = v;

  @override
  bool get isGuest => (_m['guest'] as bool?) ?? false;
  @override
  Future<void> setIsGuest(bool v) async => _m['guest'] = v;

  @override
  bool? get consentAi => _m['consentAi'] as bool?;
  @override
  Future<void> setConsentAi(bool v) async => _m['consentAi'] = v;

  @override
  DateTime? get consentTs => _m['consentTs'] as DateTime?;
  @override
  Future<void> setConsentTs(DateTime v) async => _m['consentTs'] = v;

  @override
  int get consentVersion => (_m['cVer'] as int?) ?? 0;
  @override
  Future<void> setConsentVersion(int v) async => _m['cVer'] = v;

  @override
  bool get sentinelSetupDone => (_m['sentinel'] as bool?) ?? false;
  @override
  Future<void> setSentinelSetupDone(bool v) async => _m['sentinel'] = v;

  @override
  bool get isOnboarded => (_m['done'] as bool?) ?? false;
  @override
  Future<void> setOnboarded(bool v) async => _m['done'] = v;

  @override
  Future<void> clearAll() async => _m.clear();
}