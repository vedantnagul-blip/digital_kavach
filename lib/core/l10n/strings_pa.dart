import 'strings_base.dart';

class StringsPa implements StringsBase {
  const StringsPa();

  @override String get appName => 'ਡਿਜੀਟਲ ਕਵਚ';
  @override String get tagline => 'ਤੁਹਾਡਾ ਡਿਜੀਟਲ ਸੁਰੱਖਿਆ ਕਵਚ';
  @override String get loading => 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…';

  @override String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';
  @override String get cancel => 'ਰੱਦ ਕਰੋ';
  @override String get confirm => 'ਪੁਸ਼ਟੀ ਕਰੋ';
  @override String get ok => 'ਠੀਕ ਹੈ';
  @override String get close => 'ਬੰਦ ਕਰੋ';
  @override String get share => 'ਸਾਂਝਾ ਕਰੋ';
  @override String get copy => 'ਨਕਲ';
  @override String get back => 'ਪਿੱਛੇ';

  @override String get emptyDefaultTitle => 'ਕੁਝ ਨਹੀਂ';
  @override String get emptyDefaultMessage => 'ਦਿਖਾਉਣ ਲਈ ਕੁਝ ਨਹੀਂ ਹੈ';
  @override String get errorDefaultTitle => 'ਕੁਝ ਗਲਤ ਹੋ ਗਿਆ';
  @override String get errorDefaultHint => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';
  @override String get errorNetworkTitle => 'ਇੰਟਰਨੈੱਟ ਕਨੈਕਸ਼ਨ ਨਹੀਂ ਹੈ';
  @override String get errorNetworkHint => 'ਆਪਣਾ ਕਨੈਕਸ਼ਨ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';
  @override String get errorTimeoutTitle => 'ਸਮਾਂ ਖ਼ਤਮ';
  @override String get errorTimeoutHint => 'ਬੇਨਤੀ ਨੇ ਬਹੁਤ ਸਮਾਂ ਲਿਆ';
  @override String get errorAiTitle => 'AI ਉਪਲਬਧ ਨਹੀਂ';
  @override String get errorAiHint => 'ਆਫ਼ਲਾਈਨ ਨਤੀਜਾ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ';
  @override String get errorAiQuotaTitle => 'AI ਸੀਮਾ ਪਹੁੰਚ ਗਈ';
  @override String get errorAiQuotaHint => 'ਅੱਜ ਕੋਈ ਜਾਂਚ ਬਾਕੀ ਨਹੀਂ';
  @override String get errorPermissionTitle => 'ਇਜਾਜ਼ਤ ਲੋੜੀਂਦੀ';
  @override String get errorPermissionHint => 'ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਇਜਾਜ਼ਤ ਦਿਓ';
  @override String get errorStorageTitle => 'ਸਟੋਰੇਜ ਗਲਤੀ';
  @override String get errorStorageHint => 'ਸਥਾਨਕ ਡਾਟਾ ਪ੍ਰਾਪਤ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ';
  @override String get errorAuthTitle => 'ਲੌਗਇਨ ਗਲਤੀ';
  @override String get errorAuthHint => 'ਦੁਬਾਰਾ ਲੌਗਇਨ ਕਰੋ';
  @override String get errorUnknownTitle => 'ਅਣਜਾਣ ਗਲਤੀ';
  @override String get errorUnknownHint => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override String get severityScam => 'ਧੋਖਾ';
  @override String get severitySuspicious => 'ਸ਼ੱਕੀ';
  @override String get severitySafe => 'ਸੁਰੱਖਿਅਤ';

  @override String get navHome => 'ਹੋਮ';
  @override String get navScan => 'ਸਕੈਨ';
  @override String get navFeed => 'ਸਰਗਰਮੀ';
  @override String get navRecovery => 'ਰਿਕਵਰੀ';
  @override String get navFamily => 'ਪਰਿਵਾਰ';
  @override String get navSettings => 'ਸੈਟਿੰਗਾਂ';

  @override String get elderModeLabel => 'ਬਜ਼ੁਰਗ ਮੋਡ';
  @override String get placeholderComingSoon => 'ਇਹ ਫੀਚਰ ਜਲਦੀ ਆਵੇਗਾ';
}