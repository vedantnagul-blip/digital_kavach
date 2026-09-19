import 'strings_base.dart';

class StringsTa implements StringsBase {
  const StringsTa();

  @override String get appName => 'டிஜிட்டல் கவசம்';
  @override String get tagline => 'உங்கள் டிஜிட்டல் பாதுகாப்பு கவசம்';
  @override String get loading => 'ஏற்றுகிறது…';

  @override String get retry => 'மீண்டும் முயற்சிக்கவும்';
  @override String get cancel => 'ரத்துசெய்';
  @override String get confirm => 'உறுதிப்படுத்து';
  @override String get ok => 'சரி';
  @override String get close => 'மூடு';
  @override String get share => 'பகிர்';
  @override String get copy => 'நகலெடு';
  @override String get back => 'பின்';

  @override String get emptyDefaultTitle => 'எதுவும் இல்லை';
  @override String get emptyDefaultMessage => 'இங்கே காட்ட எதுவும் இல்லை';
  @override String get errorDefaultTitle => 'ஏதோ தவறு நடந்துவிட்டது';
  @override String get errorDefaultHint => 'மீண்டும் முயற்சிக்கவும்';
  @override String get errorNetworkTitle => 'இணைய இணைப்பு இல்லை';
  @override String get errorNetworkHint => 'உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்';
  @override String get errorTimeoutTitle => 'நேரம் முடிந்தது';
  @override String get errorTimeoutHint => 'கோரிக்கை அதிக நேரம் எடுத்தது';
  @override String get errorAiTitle => 'AI கிடைக்கவில்லை';
  @override String get errorAiHint => 'ஆஃப்லைன் முடிவைப் பயன்படுத்துகிறது';
  @override String get errorAiQuotaTitle => 'AI வரம்பு எட்டப்பட்டது';
  @override String get errorAiQuotaHint => 'இன்று மீதமுள்ள சரிபார்ப்புகள் இல்லை';
  @override String get errorPermissionTitle => 'அனுமதி தேவை';
  @override String get errorPermissionHint => 'அமைப்புகளில் அனுமதி அளிக்கவும்';
  @override String get errorStorageTitle => 'சேமிப்பக பிழை';
  @override String get errorStorageHint => 'உள்ளூர் தரவை அணுக முடியவில்லை';
  @override String get errorAuthTitle => 'உள்நுழைவு பிழை';
  @override String get errorAuthHint => 'மீண்டும் உள்நுழையவும்';
  @override String get errorUnknownTitle => 'தெரியாத பிழை';
  @override String get errorUnknownHint => 'மீண்டும் முயற்சிக்கவும்';

  @override String get severityScam => 'மோசடி';
  @override String get severitySuspicious => 'சந்தேகத்திற்குரியது';
  @override String get severitySafe => 'பாதுகாப்பானது';

  @override String get navHome => 'முகப்பு';
  @override String get navScan => 'ஸ்கேன்';
  @override String get navFeed => 'செயல்பாடு';
  @override String get navRecovery => 'மீட்பு';
  @override String get navFamily => 'குடும்பம்';
  @override String get navSettings => 'அமைப்புகள்';

  @override String get elderModeLabel => 'மூத்தவர் பயன்முறை';
  @override String get placeholderComingSoon => 'இந்த அம்சம் விரைவில் வரும்';
}