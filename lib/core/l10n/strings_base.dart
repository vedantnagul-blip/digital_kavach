/// Compile-time contract for chrome strings. Missing keys in any concrete
/// implementation surface as *compile* errors, not runtime.
///
/// AI-generated verdict explanations are NEVER routed through this — they
/// arrive natively from the model in the user's language.
abstract class StringsBase {
  // === APP CHROME ===
  String get appName;
  String get tagline;
  String get loading;

  // === COMMON ACTIONS ===
  String get retry;
  String get cancel;
  String get confirm;
  String get ok;
  String get close;
  String get share;
  String get copy;
  String get back;

  // === EMPTY / ERROR STATES ===
  String get emptyDefaultTitle;
  String get emptyDefaultMessage;
  String get errorDefaultTitle;
  String get errorDefaultHint;
  String get errorNetworkTitle;
  String get errorNetworkHint;
  String get errorTimeoutTitle;
  String get errorTimeoutHint;
  String get errorAiTitle;
  String get errorAiHint;
  String get errorAiQuotaTitle;
  String get errorAiQuotaHint;
  String get errorPermissionTitle;
  String get errorPermissionHint;
  String get errorStorageTitle;
  String get errorStorageHint;
  String get errorAuthTitle;
  String get errorAuthHint;
  String get errorUnknownTitle;
  String get errorUnknownHint;

  // === SEVERITY LABELS ===
  String get severityScam;
  String get severitySuspicious;
  String get severitySafe;

  // === NAV / PLACEHOLDERS ===
  String get navHome;
  String get navScan;
  String get navFeed;
  String get navRecovery;
  String get navFamily;
  String get navSettings;

  // === ELDER MODE ===
  String get elderModeLabel;

  // === PLACEHOLDER LABEL ===
  String get placeholderComingSoon;
}