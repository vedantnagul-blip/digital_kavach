import 'package:digital_kavach/core/l10n/strings_base.dart';


class StringsEn implements StringsBase {
  const StringsEn();

  @override String get appName => 'Digital Kavach';
  @override String get tagline => 'AI-powered scam protection';
  @override String get loading => 'Loading…';

  @override String get retry => 'Retry';
  @override String get cancel => 'Cancel';
  @override String get confirm => 'Confirm';
  @override String get ok => 'OK';
  @override String get close => 'Close';
  @override String get share => 'Share';
  @override String get copy => 'Copy';
  @override String get back => 'Back';

  @override String get emptyDefaultTitle => 'Nothing here yet';
  @override String get emptyDefaultMessage => 'Content will appear here once available.';
  @override String get errorDefaultTitle => 'Something went wrong';
  @override String get errorDefaultHint => 'Please try again in a moment.';
  @override String get errorNetworkTitle => 'No internet';
  @override String get errorNetworkHint => 'Check your Wi-Fi or mobile data and retry.';
  @override String get errorTimeoutTitle => 'Slow connection';
  @override String get errorTimeoutHint => 'Server took too long. Try again.';
  @override String get errorAiTitle => 'AI check unavailable';
  @override String get errorAiHint => 'Offline check is still active. Retry when online.';
  @override String get errorAiQuotaTitle => 'Daily AI limit reached';
  @override String get errorAiQuotaHint => 'You can still use offline scanning.';
  @override String get errorPermissionTitle => 'Permission needed';
  @override String get errorPermissionHint => 'Grant the required permission in Settings.';
  @override String get errorStorageTitle => 'Storage error';
  @override String get errorStorageHint => 'Your device storage may be full.';
  @override String get errorAuthTitle => 'Sign-in problem';
  @override String get errorAuthHint => 'Please sign in again.';
  @override String get errorUnknownTitle => 'Unexpected error';
  @override String get errorUnknownHint => 'Please try again.';

  @override String get severityScam => 'SCAM';
  @override String get severitySuspicious => 'SUSPICIOUS';
  @override String get severitySafe => 'SAFE';

  @override String get navHome => 'Home';
  @override String get navScan => 'Scan';
  @override String get navFeed => 'Feed';
  @override String get navRecovery => 'Recovery';
  @override String get navFamily => 'Family';
  @override String get navSettings => 'Settings';

  @override String get elderModeLabel => 'Elder Mode';

  @override String get placeholderComingSoon => 'Coming soon';
}