import 'strings_base.dart';

class StringsGu implements StringsBase {
  const StringsGu();

  @override String get appName => 'ડિજિટલ કવચ';
  @override String get tagline => 'તમારું ડિજિટલ સુરક્ષા કવચ';
  @override String get loading => 'લોડ થઈ રહ્યું છે…';

  @override String get retry => 'ફરી પ્રયાસ કરો';
  @override String get cancel => 'રદ કરો';
  @override String get confirm => 'પુષ્ટિ કરો';
  @override String get ok => 'બરાબર';
  @override String get close => 'બંધ કરો';
  @override String get share => 'શેર કરો';
  @override String get copy => 'નકલ';
  @override String get back => 'પાછળ';

  @override String get emptyDefaultTitle => 'કંઈ નથી';
  @override String get emptyDefaultMessage => 'બતાવવા માટે કંઈ નથી';
  @override String get errorDefaultTitle => 'કંઈક ખોટું થયું';
  @override String get errorDefaultHint => 'ફરી પ્રયાસ કરો';
  @override String get errorNetworkTitle => 'ઇન્ટરનેટ કનેક્શન નથી';
  @override String get errorNetworkHint => 'તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો';
  @override String get errorTimeoutTitle => 'સમય સમાપ્ત';
  @override String get errorTimeoutHint => 'વિનંતી ખૂબ સમય લે છે';
  @override String get errorAiTitle => 'AI ઉપલબ્ધ નથી';
  @override String get errorAiHint => 'ઑફલાઇન પરિણામ વાપરી રહ્યાં છીએ';
  @override String get errorAiQuotaTitle => 'AI મર્યાદા પહોંચી ગઈ';
  @override String get errorAiQuotaHint => 'આજે કોઈ ચકાસણી બાકી નથી';
  @override String get errorPermissionTitle => 'પરવાનગી જરૂરી';
  @override String get errorPermissionHint => 'સેટિંગ્સમાં પરવાનગી આપો';
  @override String get errorStorageTitle => 'સ્ટોરેજ ભૂલ';
  @override String get errorStorageHint => 'સ્થાનિક ડેટા ઍક્સેસ કરી શકાયો નથી';
  @override String get errorAuthTitle => 'લોગિન ભૂલ';
  @override String get errorAuthHint => 'ફરી લોગિન કરો';
  @override String get errorUnknownTitle => 'અજ્ઞાત ભૂલ';
  @override String get errorUnknownHint => 'ફરી પ્રયાસ કરો';

  @override String get severityScam => 'છેતરપિંડી';
  @override String get severitySuspicious => 'શંકાસ્પદ';
  @override String get severitySafe => 'સુરક્ષિત';

  @override String get navHome => 'હોમ';
  @override String get navScan => 'સ્કેન';
  @override String get navFeed => 'પ્રવૃત્તિ';
  @override String get navRecovery => 'પુનઃપ્રાપ્તિ';
  @override String get navFamily => 'પરિવાર';
  @override String get navSettings => 'સેટિંગ્સ';

  @override String get elderModeLabel => 'વડીલ મોડ';
  @override String get placeholderComingSoon => 'આ સુવિધા ટૂંક સમયમાં આવશે';
}