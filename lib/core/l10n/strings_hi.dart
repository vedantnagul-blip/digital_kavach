import 'package:digital_kavach/core/l10n/strings_base.dart';


class StringsHi implements StringsBase {
  const StringsHi();

  @override String get appName => 'डिजिटल कवच';
  @override String get tagline => 'एआई द्वारा घोटाला सुरक्षा';
  @override String get loading => 'लोड हो रहा है…';

  @override String get retry => 'पुनः प्रयास';
  @override String get cancel => 'रद्द करें';
  @override String get confirm => 'पुष्टि करें';
  @override String get ok => 'ठीक है';
  @override String get close => 'बंद करें';
  @override String get share => 'साझा करें';
  @override String get copy => 'कॉपी';
  @override String get back => 'वापस';

  @override String get emptyDefaultTitle => 'यहाँ अभी कुछ नहीं है';
  @override String get emptyDefaultMessage => 'उपलब्ध होने पर सामग्री यहाँ दिखेगी।';
  @override String get errorDefaultTitle => 'कुछ गड़बड़ हुई';
  @override String get errorDefaultHint => 'कृपया थोड़ी देर में पुनः प्रयास करें।';
  @override String get errorNetworkTitle => 'इंटरनेट नहीं है';
  @override String get errorNetworkHint => 'वाई-फाई या मोबाइल डेटा जाँचें।';
  @override String get errorTimeoutTitle => 'धीमा कनेक्शन';
  @override String get errorTimeoutHint => 'सर्वर बहुत समय ले रहा है। पुनः प्रयास करें।';
  @override String get errorAiTitle => 'एआई जाँच उपलब्ध नहीं';
  @override String get errorAiHint => 'ऑफलाइन जाँच चालू है। ऑनलाइन आने पर पुनः प्रयास करें।';
  @override String get errorAiQuotaTitle => 'दैनिक एआई सीमा पूरी';
  @override String get errorAiQuotaHint => 'ऑफलाइन स्कैन अभी भी उपलब्ध है।';
  @override String get errorPermissionTitle => 'अनुमति चाहिए';
  @override String get errorPermissionHint => 'सेटिंग्स में अनुमति दें।';
  @override String get errorStorageTitle => 'स्टोरेज त्रुटि';
  @override String get errorStorageHint => 'आपके फ़ोन की जगह भर गई हो सकती है।';
  @override String get errorAuthTitle => 'लॉगिन समस्या';
  @override String get errorAuthHint => 'कृपया दोबारा साइन इन करें।';
  @override String get errorUnknownTitle => 'अनजान त्रुटि';
  @override String get errorUnknownHint => 'कृपया पुनः प्रयास करें।';

  @override String get severityScam => 'धोखा';
  @override String get severitySuspicious => 'संदिग्ध';
  @override String get severitySafe => 'सुरक्षित';

  @override String get navHome => 'होम';
  @override String get navScan => 'जाँच';
  @override String get navFeed => 'फ़ीड';
  @override String get navRecovery => 'रिकवरी';
  @override String get navFamily => 'परिवार';
  @override String get navSettings => 'सेटिंग्स';

  @override String get elderModeLabel => 'बुज़ुर्ग मोड';

  @override String get placeholderComingSoon => 'जल्द आ रहा है';
}