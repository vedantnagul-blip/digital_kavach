import 'package:flutter/foundation.dart';

import '../../../data/rules/rule.dart';
import '../../../data/rules/score_aggregator.dart';

/// Which engine produced this verdict.
enum AiProvider { tier1, gemini, grok, cached }

extension AiProviderX on AiProvider {
  String get wire {
    switch (this) {
      case AiProvider.tier1:   return 'tier1';
      case AiProvider.gemini:  return 'gemini';
      case AiProvider.grok:    return 'grok';
      case AiProvider.cached:  return 'cached';
    }
  }
  static AiProvider fromWire(String? s) {
    switch (s) {
      case 'gemini':  return AiProvider.gemini;
      case 'grok':
      case 'chatgpt':
      case 'openai':  return AiProvider.grok;
      case 'cached':  return AiProvider.cached;
      default:        return AiProvider.tier1;
    }
  }
}

@immutable
class AiProviderInfo {
  const AiProviderInfo({required this.provider, this.model});
  final AiProvider provider;
  final String? model;

  factory AiProviderInfo.tier1() =>
      const AiProviderInfo(provider: AiProvider.tier1, model: 'on-device');

  Map<String, dynamic> toJson() => <String, dynamic>{
        'provider': provider.wire,
        'model': model,
      };

  factory AiProviderInfo.fromJson(Map<String, dynamic> j) => AiProviderInfo(
        provider: AiProviderX.fromWire(j['provider'] as String?),
        model: j['model'] as String?,
      );
}

/// The final verdict emitted by either Tier-1 (offline) or Tier-2 (AI).
@immutable
class Verdict {
  const Verdict({
    required this.verdict,
    required this.riskScore,
    required this.patternMatched,
    required this.confidence,
    required this.redFlags,
    required this.explanationNative,
    required this.recommendedActions,
    required this.provider,
  });

  final VerdictLevel verdict;
  final int riskScore; // 0..100
  final String patternMatched; // Rule family or novel scam name
  final double confidence; // 0.0..1.0
  final List<String> redFlags;
  final String explanationNative;
  final List<String> recommendedActions;
  final AiProviderInfo provider;

  Verdict copyWith({
    VerdictLevel? verdict,
    int? riskScore,
    String? patternMatched,
    double? confidence,
    List<String>? redFlags,
    String? explanationNative,
    List<String>? recommendedActions,
    AiProviderInfo? provider,
  }) =>
      Verdict(
        verdict: verdict ?? this.verdict,
        riskScore: riskScore ?? this.riskScore,
        patternMatched: patternMatched ?? this.patternMatched,
        confidence: confidence ?? this.confidence,
        redFlags: redFlags ?? this.redFlags,
        explanationNative: explanationNative ?? this.explanationNative,
        recommendedActions: recommendedActions ?? this.recommendedActions,
        provider: provider ?? this.provider,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'verdict': verdict.wire,
        'riskScore': riskScore,
        'patternMatched': patternMatched,
        'confidence': confidence,
        'redFlags': redFlags,
        'explanationNative': explanationNative,
        'recommendedActions': recommendedActions,
        'provider': provider.toJson(),
      };

  factory Verdict.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic>? prov =
        j['provider'] as Map<String, dynamic>?;
    return Verdict(
      verdict: VerdictLevelX.fromWire((j['verdict'] as String?) ?? 'SAFE'),
      riskScore: (j['riskScore'] as num?)?.toInt() ?? 0,
      patternMatched: j['patternMatched'] as String? ?? 'Unknown',
      confidence: (j['confidence'] as num?)?.toDouble() ?? 0.0,
      redFlags: (j['redFlags'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      explanationNative: j['explanationNative'] as String? ?? '',
      recommendedActions: (j['recommendedActions'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      provider: prov != null
          ? AiProviderInfo.fromJson(prov)
          : AiProviderInfo.tier1(),
    );
  }
}

/// Utility builder for Tier-1 verdicts and hybrid mergers.
class VerdictBuild {
  static Verdict fromTier1({
    required List<RuleHit> hits,
    required int score,
    required VerdictLevel level,
    required String langCode,
  }) {
    final String pattern = hits.isNotEmpty ? hits.first.family.wireName : 'None';
    final List<String> flags =
        hits.map((RuleHit h) => h.hint).toList();
    final List<String> actions = _actionsFor(level, langCode);

    return Verdict(
      verdict: level,
      riskScore: score,
      patternMatched: pattern,
      confidence: 1.0,
      redFlags: flags,
      explanationNative: _explanationFor(level, langCode),
      recommendedActions: actions,
      provider: AiProviderInfo.tier1(),
    );
  }

  static Verdict mergeTier1AndAi(Verdict tier1, Verdict ai) {
    if (tier1.verdict == VerdictLevel.red) {
      return ai.copyWith(
        verdict: VerdictLevel.red,
        riskScore: ai.riskScore > tier1.riskScore ? ai.riskScore : tier1.riskScore,
      );
    }
    return ai;
  }

  static List<String> _actionsFor(VerdictLevel level, [String langCode = 'en']) {
    const Map<String, Map<String, List<String>>> table = {
      'red': {
        'en': ['Do not reply to this message', 'Call 1930 (cyber-crime helpline)', 'Never share OTP, PIN or card details'],
        'hi': ['इस संदेश का जवाब मत दें', '1930 पर कॉल करें (साइबर हेल्पलाइन)', 'OTP, PIN या कार्ड विवरण कभी साझा न करें'],
        'mr': ['या संदेशाला उत्तर देऊ नका', '1930 वर कॉल करा (सायबर हेल्पलाइन)', 'OTP, PIN किंवा कार्ड तपशील कधीही शेअर करू नका'],
        'ta': ['இந்தச் செய்திக்கு பதிலளிக்க வேண்டாம்', '1930-க்கு அழைக்கவும் (சைபர் உதவி எண்)', 'OTP, PIN விவரங்களை ஒருபோதும் பகிர வேண்டாம்'],
        'te': ['ఈ సందేశానికి ప్రత్యుత్తరం ఇవ్వవద్దు', '1930కి కాల్ చేయండి (సైబర్ హెల్ప్‌లైన్)', 'OTP, PIN లేదా కార్డ్ వివరాలను ఎప్పుడూ షేర్ చేయవద్దు'],
        'bn': ['এই বার্তার উত্তর দেবেন না', '১৯৩০ নম্বরে কল করুন (সাইবার হেল্পলাইন)', 'কখনও OTP, PIN বা কার্ডের তথ্য শেয়ার করবেন না'],
        'gu': ['આ સંદેશનો જવાબ ન આપો', '1930 પર કૉલ કરો (સાયબર હેલ્પલાઇન)', 'ક્યારેય OTP, PIN અથવા કાર્ડની વિગતો શેર કરશો નહીં'],
        'kn': ['ಈ ಸಂದೇಶಕ್ಕೆ ಪ್ರತ್ಯುತ್ತರಿಸಬೇಡಿ', '1930 ಗೆ ಕರೆ ಮಾಡಿ (ಸೈಬರ್ ಸಹಾಯವಾಣಿ)', 'OTP, PIN ಅಥವಾ ಕಾರ್ಡ್ ವಿವರಗಳನ್ನು ಎಂದಿಗೂ ಹಂಚಿಕೊಳ್ಳಬೇಡಿ'],
        'ml': ['ഈ സന്ദേശത്തിന് മറുപടി നൽകരുത്', '1930-ൽ വിളിക്കുക (സൈബർ ഹെൽപ്പ്‌ലൈൻ)', 'OTP, PIN വിവരങ്ങൾ ഒരിക്കലും പങ്കിടരുത്'],
        'pa': ['ਇਸ ਸੁਨੇਹੇ ਦਾ ਜਵਾਬ ਨਾ ਦਿਓ', '1930 ਤੇ ਕਾਲ ਕਰੋ (ਸਾਈਬਰ ਹੈਲਪਲਾਈਨ)', 'ਕਦੇ ਵੀ OTP, PIN ਜਾਂ ਕਾਰਡ ਵੇਰਵੇ ਸਾਂਝੇ ਨਾ ਕਰੋ'],
      },
      'amber': {
        'en': ['Verify sender identity independently', 'Do not click links or install apps'],
        'hi': ['प्रेषक की पहचान की स्वतंत्र रूप से पुष्टि करें', 'संदिग्ध लिंक पर क्लिक न करें या ऐप इंस्टॉल न करें'],
        'mr': ['पाठवणाऱ्याची ओळख स्वतंत्रपणे तपासा', 'दुव्यांवर क्लिक करू नका किंवा अ‍ॅप इन्स्टॉल करू नका'],
        'ta': ['அனுப்புநரின் அடையாளத்தை தனித்தனியாக சரிபார்க்கவும்', 'இணைப்புகளைக் கிளிக் செய்யவோ பயன்பாடுகளை நிறுவவோ வேண்டாம்'],
        'te': ['పంపినవారి గుర్తింపును స్వతంత్రంగా ధృవీకరించండి', 'లింక్‌లపై క్లిక్ చేయవద్దు లేదా యాప్‌లను ఇన్‌స్టాల్ చేయవద్దు'],
        'bn': ['প্রেরকের পরিচয় স্বাধীনভাবে যাচাই করুন', 'লিঙ্কে ক্লিক করবেন না বা অ্যাপ ইনস্টল করবেন না'],
        'gu': ['મોકલનારની ઓળખની સ્વતંત્ર રીતે ચકાસણી કરો', 'લિંક્સ પર ક્લિક કરશો નહીં અથવા એપ્સ ઇન્સ્ટોલ કરશો નહીં'],
        'kn': ['ಕಳುಹಿಸಿದವರ ಗುರುತನ್ನು ಸ್ವತಂತ್ರವಾಗಿ ಪರಿಶೀಲಿಸಿ', 'ಲಿಂಕ್‌ಗಳನ್ನು ಕ್ಲಿಕ್ ಮಾಡಬೇಡಿ ಅಥವಾ ಅಪ್ಲಿಕೇಶನ್‌ಗಳನ್ನು ಇನ್‌ಸ್ಟಾಲ್ ಮಾಡಬೇಡಿ'],
        'ml': ['അയച്ചയാളുടെ ഐഡന്റിറ്റി സ്വതന്ത്രമായി പരിശോധിക്കുക', 'ലിങ്കുകളിൽ ക്ലിക്കുചെയ്യുകയോ ആപ്പുകൾ ഇൻസ്റ്റാൾ ചെയ്യുകയോ ചെയ്യരുത്'],
        'pa': ['ਭੇਜਣ ਵਾਲੇ ਦੀ ਪਛਾਣ ਦੀ ਸੁਤੰਤਰ ਤੌਰ ਤੇ ਪੁਸ਼ਟੀ ਕਰੋ', 'ਲਿੰਕਾਂ ਤੇ ਕਲਿੱਕ ਨਾ ਕਰੋ ਜਾਂ ਐਪਸ ਇੰਸਟੌਲ ਨਾ ਕਰੋ'],
      },
      'green': {
        'en': ['Safe to proceed — stay alert'],
        'hi': ['आगे बढ़ना सुरक्षित है — फिर भी सावधान रहें'],
        'mr': ['पुढे जाणे सुरक्षित आहे — तरीही सावध राहा'],
        'ta': ['தொடர பாதுகாப்பானது — விழிப்புடன் இருங்கள்'],
        'te': ['కొనసాగడానికి సురక్షితం — అప్రమత్తంగా ఉండండి'],
        'bn': ['এগিয়ে যাওয়া নিরাপদ — সতর্ক থাকুন'],
        'gu': ['આગળ વધવું સલામત છે — સાવધ રહો'],
        'kn': ['ಮುಂದುವರಿಯಲು ಸುರಕ್ಷಿತ — ಎಚ್ಚರದಿಂದಿರಿ'],
        'ml': ['തുടരുന്നത് സുരക്ഷിതമാണ് — ജാഗ്രത പാലിക്കുക'],
        'pa': ['ਅੱਗੇ ਵਧਣਾ ਸੁਰੱਖਿਅਤ ਹੈ — ਸੁਚੇਤ ਰਹੋ'],
      },
    };

    final String key = level == VerdictLevel.red ? 'red' : (level == VerdictLevel.amber ? 'amber' : 'green');
    return table[key]?[langCode] ?? table[key]?['en'] ?? const <String>['Stay alert'];
  }

  static String _explanationFor(VerdictLevel level, String langCode) {
    const Map<String, Map<String, String>> table = {
      'red': {
        'en': 'High risk scam indicators detected in this message.',
        'hi': 'इस संदेश में उच्च जोखिम वाले घोटाले के संकेत मिले हैं।',
        'mr': 'या संदेशात उच्च जोखमीचे फसवणूक संकेत आढळले आहेत.',
        'ta': 'இந்தச் செய்தியில் அதிக ஆபத்துள்ள மோசடி குறிகாட்டிகள் கண்டறியப்பட்டுள்ளன.',
        'te': 'ఈ సందేశంలో అధిక ప్రమాదకర మోసపూరిత సంకేతాలు గుర్తించబడ్డాయి.',
        'bn': 'এই বার্তায় উচ্চ ঝুঁকিপূর্ণ প্রতারণার ইঙ্গিত পাওয়া গেছে।',
        'gu': 'આ સંદેશમાં ઉચ્ચ જોખમી છેતરપિંડીના સંકેતો મળ્યા છે.',
        'kn': 'ಈ ಸಂದೇಶದಲ್ಲಿ ಹೆಚ್ಚಿನ ಅಪಾಯದ ವಂಚನೆ ಸೂಚಕಗಳು ಕಂಡುಬಂದಿವೆ.',
        'ml': 'ഈ സന്ദേശത്തിൽ ഉയർന്ന അപകടസാധ്യതയുള്ള തട്ടിപ്പ് സൂചകങ്ങൾ കണ്ടെത്തി.',
        'pa': 'ਇਸ ਸੁਨੇਹੇ ਵਿੱਚ ਉੱਚ ਜੋਖਮ ਵਾਲੇ ਘੁਟਾਲੇ ਦੇ ਸੰਕੇਤ ਮਿਲੇ ਹਨ।',
      },
      'amber': {
        'en': 'Suspicious patterns detected. Please proceed with caution.',
        'hi': 'संदिग्ध पैटर्न मिले हैं। कृपया सावधानी बरतें।',
        'mr': 'संशयास्पद पॅटर्न आढळले आहेत. कृपया सावधगिरी बाळगा.',
        'ta': 'சந்தேகத்திற்கிடமான முறைகள் கண்டறியப்பட்டுள்ளன. எச்சரிக்கையுடன் தொடரவும்.',
        'te': 'అనుమానాస్పద నమూనాలు గుర్తించబడ్డాయి. దయచేసి జాగ్రత్తగా వ్యవహరించండి.',
        'bn': 'সন্দেহজনক নিদর্শন সনাক্ত করা হয়েছে। দয়া করে সতর্ক থাকুন।',
        'gu': 'શંકાસ્પદ પેટર્ન મળી છે. કૃપા કરીને સાવધાની રાખો.',
        'kn': 'ಅನುಮಾನಾಸ್ಪದ ಮಾದರಿಗಳು ಕಂಡುಬಂದಿವೆ. ದಯವಿಟ್ಟು ಎಚ್ಚರಿಕೆಯಿಂದ ಮುಂದುವರಿಯಿರಿ.',
        'ml': 'സംശയാസ്പദമായ രീതികൾ കണ്ടെത്തി. ദയവായി ജാഗ്രത പാലിക്കുക.',
        'pa': 'ਸ਼ੱਕੀ ਪੈਟਰਨ ਮਿਲੇ ਹਨ। ਕਿਰਪਾ ਕਰਕੇ ਸਾਵਧਾਨੀ ਵਰਤੋ।',
      },
      'green': {
        'en': 'No known scam patterns detected.',
        'hi': 'कोई ज्ञात घोटाला पैटर्न नहीं मिला।',
        'mr': 'कोणताही ज्ञात फसवणूक पॅटर्न आढळला नाही.',
        'ta': 'அறியப்பட்ட மோசடி வடிவங்கள் எதுவும் கண்டறியப்படவில்லை.',
        'te': 'తెలిసిన మోసపూరిత నమూనాలు ఏవీ కనుగొనబడలేదు.',
        'bn': 'কোনো পরিচিত প্রতারণার ধরন পাওয়া যায়নি।',
        'gu': 'કોઈ જાણીતી છેતરપિંડી પેટર્ન મળી નથી.',
        'kn': 'ಯಾವುದೇ ತಿಳಿದಿರುವ ವಂಚನೆ ಮಾದರಿಗಳು ಕಂಡುಬಂದಿಲ್ಲ.',
        'ml': 'അറിയപ്പെടുന്ന തട്ടിപ്പ് രീതികളൊന്നും കണ്ടെത്തിയില്ല.',
        'pa': 'ਕੋਈ ਜਾਣਿਆ-ਪਛਾਣਿਆ ਘੁਟਾਲਾ ਪੈਟਰਨ ਨਹੀਂ ਮਿਲਿਆ।',
      },
    };

    final String key = level == VerdictLevel.red ? 'red' : (level == VerdictLevel.amber ? 'amber' : 'green');
    return table[key]?[langCode] ?? table[key]?['en'] ?? 'Analysis complete.';
  }
}
