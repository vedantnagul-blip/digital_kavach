import 'strings_base.dart';

class StringsBn implements StringsBase {
  const StringsBn();

  @override String get appName => 'ডিজিটাল কবচ';
  @override String get tagline => 'আপনার ডিজিটাল সুরক্ষা বর্ম';
  @override String get loading => 'লোড হচ্ছে…';

  @override String get retry => 'আবার চেষ্টা করুন';
  @override String get cancel => 'বাতিল';
  @override String get confirm => 'নিশ্চিত করুন';
  @override String get ok => 'ঠিক আছে';
  @override String get close => 'বন্ধ করুন';
  @override String get share => 'শেয়ার';
  @override String get copy => 'কপি';
  @override String get back => 'পিছনে';

  @override String get emptyDefaultTitle => 'কিছুই নেই';
  @override String get emptyDefaultMessage => 'এখানে দেখানোর কিছু নেই';
  @override String get errorDefaultTitle => 'কিছু ভুল হয়েছে';
  @override String get errorDefaultHint => 'আবার চেষ্টা করুন';
  @override String get errorNetworkTitle => 'ইন্টারনেট সংযোগ নেই';
  @override String get errorNetworkHint => 'আপনার সংযোগ পরীক্ষা করে আবার চেষ্টা করুন';
  @override String get errorTimeoutTitle => 'সময় শেষ';
  @override String get errorTimeoutHint => 'অনুরোধ অনেক সময় নিয়েছে';
  @override String get errorAiTitle => 'AI উপলব্ধ নয়';
  @override String get errorAiHint => 'অফলাইন ফলাফল ব্যবহার করা হচ্ছে';
  @override String get errorAiQuotaTitle => 'AI সীমা পৌঁছেছে';
  @override String get errorAiQuotaHint => 'আজ কোনো চেক অবশিষ্ট নেই';
  @override String get errorPermissionTitle => 'অনুমতি প্রয়োজন';
  @override String get errorPermissionHint => 'সেটিংসে অনুমতি দিন';
  @override String get errorStorageTitle => 'স্টোরেজ ত্রুটি';
  @override String get errorStorageHint => 'স্থানীয় ডেটা অ্যাক্সেস করা যায়নি';
  @override String get errorAuthTitle => 'লগইন ত্রুটি';
  @override String get errorAuthHint => 'আবার লগইন করুন';
  @override String get errorUnknownTitle => 'অজানা ত্রুটি';
  @override String get errorUnknownHint => 'আবার চেষ্টা করুন';

  @override String get severityScam => 'প্রতারণা';
  @override String get severitySuspicious => 'সন্দেহজনক';
  @override String get severitySafe => 'নিরাপদ';

  @override String get navHome => 'হোম';
  @override String get navScan => 'স্ক্যান';
  @override String get navFeed => 'কার্যকলাপ';
  @override String get navRecovery => 'পুনরুদ্ধার';
  @override String get navFamily => 'পরিবার';
  @override String get navSettings => 'সেটিংস';

  @override String get elderModeLabel => 'প্রবীণ মোড';
  @override String get placeholderComingSoon => 'এই ফিচার শীঘ্রই আসবে';
}