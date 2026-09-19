import 'strings_base.dart';

class StringsTe implements StringsBase {
  const StringsTe();

  @override String get appName => 'డిజిటల్ కవచం';
  @override String get tagline => 'మీ డిజిటల్ భద్రతా కవచం';
  @override String get loading => 'లోడ్ అవుతోంది…';

  @override String get retry => 'మళ్లీ ప్రయత్నించండి';
  @override String get cancel => 'రద్దు';
  @override String get confirm => 'నిర్ధారించు';
  @override String get ok => 'సరే';
  @override String get close => 'మూసివేయి';
  @override String get share => 'పంచుకోండి';
  @override String get copy => 'కాపీ';
  @override String get back => 'వెనుక';

  @override String get emptyDefaultTitle => 'ఏమీ లేదు';
  @override String get emptyDefaultMessage => 'ఇక్కడ చూపించడానికి ఏమీ లేదు';
  @override String get errorDefaultTitle => 'ఏదో తప్పు జరిగింది';
  @override String get errorDefaultHint => 'మళ్లీ ప్రయత్నించండి';
  @override String get errorNetworkTitle => 'ఇంటర్నెట్ కనెక్షన్ లేదు';
  @override String get errorNetworkHint => 'మీ కనెక్షన్ తనిఖీ చేసి మళ్లీ ప్రయత్నించండి';
  @override String get errorTimeoutTitle => 'సమయం మించిపోయింది';
  @override String get errorTimeoutHint => 'అభ్యర్థన చాలా సమయం తీసుకుంది';
  @override String get errorAiTitle => 'AI అందుబాటులో లేదు';
  @override String get errorAiHint => 'ఆఫ్‌లైన్ ఫలితం ఉపయోగిస్తోంది';
  @override String get errorAiQuotaTitle => 'AI పరిమితి చేరుకుంది';
  @override String get errorAiQuotaHint => 'ఈరోజు మిగిలిన తనిఖీలు లేవు';
  @override String get errorPermissionTitle => 'అనుమతి అవసరం';
  @override String get errorPermissionHint => 'సెట్టింగ్‌లలో అనుమతి ఇవ్వండి';
  @override String get errorStorageTitle => 'నిల్వ లోపం';
  @override String get errorStorageHint => 'స్థానిక డేటాను యాక్సెస్ చేయలేకపోయింది';
  @override String get errorAuthTitle => 'లాగిన్ లోపం';
  @override String get errorAuthHint => 'మళ్లీ లాగిన్ చేయండి';
  @override String get errorUnknownTitle => 'తెలియని లోపం';
  @override String get errorUnknownHint => 'మళ్లీ ప్రయత్నించండి';

  @override String get severityScam => 'మోసం';
  @override String get severitySuspicious => 'అనుమానాస్పదం';
  @override String get severitySafe => 'సురక్షితం';

  @override String get navHome => 'హోమ్';
  @override String get navScan => 'స్కాన్';
  @override String get navFeed => 'కార్యాచరణ';
  @override String get navRecovery => 'పునరుద్ధరణ';
  @override String get navFamily => 'కుటుంబం';
  @override String get navSettings => 'సెట్టింగ్‌లు';

  @override String get elderModeLabel => 'పెద్దల మోడ్';
  @override String get placeholderComingSoon => 'ఈ ఫీచర్ త్వరలో వస్తుంది';
}