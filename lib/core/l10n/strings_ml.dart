import 'strings_base.dart';

class StringsMl implements StringsBase {
  const StringsMl();

  @override String get appName => 'ഡിജിറ്റൽ കവചം';
  @override String get tagline => 'നിങ്ങളുടെ ഡിജിറ്റൽ സുരക്ഷാ കവചം';
  @override String get loading => 'ലോഡ് ചെയ്യുന്നു…';

  @override String get retry => 'വീണ്ടും ശ്രമിക്കുക';
  @override String get cancel => 'റദ്ദാക്കുക';
  @override String get confirm => 'സ്ഥിരീകരിക്കുക';
  @override String get ok => 'ശരി';
  @override String get close => 'അടയ്ക്കുക';
  @override String get share => 'പങ്കിടുക';
  @override String get copy => 'പകർത്തുക';
  @override String get back => 'തിരികെ';

  @override String get emptyDefaultTitle => 'ഒന്നും ഇല്ല';
  @override String get emptyDefaultMessage => 'കാണിക്കാൻ ഒന്നും ഇല്ല';
  @override String get errorDefaultTitle => 'എന്തോ തെറ്റ് സംഭവിച്ചു';
  @override String get errorDefaultHint => 'വീണ്ടും ശ്രമിക്കുക';
  @override String get errorNetworkTitle => 'ഇന്റർനെറ്റ് കണക്ഷൻ ഇല്ല';
  @override String get errorNetworkHint => 'നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക';
  @override String get errorTimeoutTitle => 'സമയപരിധി കഴിഞ്ഞു';
  @override String get errorTimeoutHint => 'അഭ്യർത്ഥന വളരെ സമയമെടുത്തു';
  @override String get errorAiTitle => 'AI ലഭ്യമല്ല';
  @override String get errorAiHint => 'ഓഫ്‌ലൈൻ ഫലം ഉപയോഗിക്കുന്നു';
  @override String get errorAiQuotaTitle => 'AI പരിധി എത്തി';
  @override String get errorAiQuotaHint => 'ഇന്ന് പരിശോധനകൾ ബാക്കിയില്ല';
  @override String get errorPermissionTitle => 'അനുമതി ആവശ്യമാണ്';
  @override String get errorPermissionHint => 'ക്രമീകരണങ്ങളിൽ അനുമതി നൽകുക';
  @override String get errorStorageTitle => 'സംഭരണ പിശക്';
  @override String get errorStorageHint => 'പ്രാദേശിക ഡാറ്റ ആക്‌സസ്സ് ചെയ്യാൻ കഴിഞ്ഞില്ല';
  @override String get errorAuthTitle => 'ലോഗിൻ പിശക്';
  @override String get errorAuthHint => 'വീണ്ടും ലോഗിൻ ചെയ്യുക';
  @override String get errorUnknownTitle => 'അജ്ഞാത പിശക്';
  @override String get errorUnknownHint => 'വീണ്ടും ശ്രമിക്കുക';

  @override String get severityScam => 'തട്ടിപ്പ്';
  @override String get severitySuspicious => 'സംശയാസ്പദം';
  @override String get severitySafe => 'സുരക്ഷിതം';

  @override String get navHome => 'ഹോം';
  @override String get navScan => 'സ്കാൻ';
  @override String get navFeed => 'പ്രവർത്തനം';
  @override String get navRecovery => 'വീണ്ടെടുക്കൽ';
  @override String get navFamily => 'കുടുംബം';
  @override String get navSettings => 'ക്രമീകരണങ്ങൾ';

  @override String get elderModeLabel => 'മുതിർന്നവർ മോഡ്';
  @override String get placeholderComingSoon => 'ഈ ഫീച്ചർ ഉടൻ വരും';
}