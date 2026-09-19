import 'package:digital_kavach/core/l10n/strings_base.dart';


class StringsMr implements StringsBase {
  const StringsMr();

  @override String get appName => 'डिजिटल कवच';
  @override String get tagline => 'एआयद्वारे फसवणूक संरक्षण';
  @override String get loading => 'लोड होत आहे…';

  @override String get retry => 'पुन्हा प्रयत्न';
  @override String get cancel => 'रद्द करा';
  @override String get confirm => 'पुष्टी करा';
  @override String get ok => 'ठीक आहे';
  @override String get close => 'बंद करा';
  @override String get share => 'शेअर';
  @override String get copy => 'कॉपी';
  @override String get back => 'मागे';

  @override String get emptyDefaultTitle => 'येथे अजून काही नाही';
  @override String get emptyDefaultMessage => 'उपलब्ध झाल्यावर सामग्री येथे दिसेल.';
  @override String get errorDefaultTitle => 'काहीतरी चूक झाली';
  @override String get errorDefaultHint => 'कृपया काही वेळाने पुन्हा प्रयत्न करा.';
  @override String get errorNetworkTitle => 'इंटरनेट नाही';
  @override String get errorNetworkHint => 'वाय-फाय किंवा मोबाइल डेटा तपासा.';
  @override String get errorTimeoutTitle => 'हळू कनेक्शन';
  @override String get errorTimeoutHint => 'सर्व्हरला वेळ लागत आहे. पुन्हा प्रयत्न करा.';
  @override String get errorAiTitle => 'एआय तपासणी उपलब्ध नाही';
  @override String get errorAiHint => 'ऑफलाइन तपासणी चालू आहे. ऑनलाइन आल्यावर प्रयत्न करा.';
  @override String get errorAiQuotaTitle => 'दैनंदिन एआय मर्यादा पूर्ण';
  @override String get errorAiQuotaHint => 'ऑफलाइन स्कॅन अजून उपलब्ध.';
  @override String get errorPermissionTitle => 'परवानगी हवी';
  @override String get errorPermissionHint => 'सेटिंग्जमध्ये परवानगी द्या.';
  @override String get errorStorageTitle => 'स्टोरेज त्रुटी';
  @override String get errorStorageHint => 'तुमच्या फोनमधील जागा संपली असू शकते.';
  @override String get errorAuthTitle => 'लॉगिन समस्या';
  @override String get errorAuthHint => 'कृपया पुन्हा साइन इन करा.';
  @override String get errorUnknownTitle => 'अज्ञात त्रुटी';
  @override String get errorUnknownHint => 'कृपया पुन्हा प्रयत्न करा.';

  @override String get severityScam => 'धोका';
  @override String get severitySuspicious => 'संशयास्पद';
  @override String get severitySafe => 'सुरक्षित';

  @override String get navHome => 'होम';
  @override String get navScan => 'तपासा';
  @override String get navFeed => 'फीड';
  @override String get navRecovery => 'रिकव्हरी';
  @override String get navFamily => 'कुटुंब';
  @override String get navSettings => 'सेटिंग्ज';

  @override String get elderModeLabel => 'ज्येष्ठ मोड';

  @override String get placeholderComingSoon => 'लवकरच येत आहे';
}