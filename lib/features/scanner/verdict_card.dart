import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/tts/tts_service.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/severity_badge.dart';
import '../../data/rules/score_aggregator.dart';
import 'models/verdict.dart';
import 'verdict_ui_state.dart';
import 'widgets/action_list.dart';
import 'widgets/disclaimer_footer.dart';
import 'widgets/provider_chip.dart';
import 'widgets/reason_list.dart';
import 'widgets/score_gauge.dart';

class VerdictCard extends ConsumerStatefulWidget {
  const VerdictCard({
    required this.state,
    this.onRetry,
    this.onSpeak,
    super.key,
  });

  final VerdictUiState state;
  final VoidCallback? onRetry;
  final VoidCallback? onSpeak;

  @override
  ConsumerState<VerdictCard> createState() => _VerdictCardState();
}

class _VerdictCardState extends ConsumerState<VerdictCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();

    _handleAutoPlay();
  }

  @override
  void didUpdateWidget(covariant VerdictCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _handleAutoPlay();
    }
  }

  void _handleAutoPlay() {
    final tts = ref.read(ttsServiceProvider);
    if (tts.shouldAutoPlay) {
      final v = _primaryVerdictFor(widget.state);
      final textToSpeak = v.explanationNative.isNotEmpty
          ? v.explanationNative
          : v.redFlags.join('. ');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tts.speak(textToSpeak);
      });
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    ref.read(ttsServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Verdict primary = _primaryVerdictFor(widget.state);
    final Severity sev = _sevFrom(primary.verdict);
    final Color tint = _tintFor(primary.verdict);
    final AppLocale locale = ref.watch(localeProvider);
    final tts = ref.watch(ttsServiceProvider);

    final CurvedAnimation curve =
    CurvedAnimation(parent: _entry, curve: Curves.easeOut);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curve),
        child: Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            borderRadius: AppRadius.rXl,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: t.shadowColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.rXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: tint,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l16,
                    AppSpacing.l16,
                    AppSpacing.l16,
                    AppSpacing.m12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SeverityBadge(severity: sev, size: SeveritySize.lg),
                      const Spacer(),
                      IconButton(
                        tooltip: tts.isSpeaking ? 'Stop reading' : 'Read aloud',
                        onPressed: () {
                          if (tts.isSpeaking) {
                            tts.stop();
                          } else {
                            final text = primary.explanationNative.isNotEmpty
                                ? primary.explanationNative
                                : primary.redFlags.join('. ');
                            tts.speak(text);
                          }
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            tts.isSpeaking
                                ? Icons.stop_circle_rounded
                                : Icons.volume_up_rounded,
                            key: ValueKey<bool>(tts.isSpeaking),
                            color: t.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ScoreGauge(
                        score: primary.riskScore,
                        level: primary.verdict,
                      ),
                      const SizedBox(height: AppSpacing.m12),
                      Text(
                        _patternHeadline(locale, primary.patternMatched),
                        style: t.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.m12),
                      ReasonList(reasons: primary.redFlags),
                      const SizedBox(height: AppSpacing.s8),
                      ActionList(actions: primary.recommendedActions),
                      const SizedBox(height: AppSpacing.m12),
                      _footerRow(context, primary),
                      _stateSpecific(context, t),
                      const SizedBox(height: AppSpacing.s8),
                      const DisclaimerFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerRow(BuildContext ctx, Verdict v) {
    final ThemeData t = Theme.of(ctx);
    final VerdictUiState s = widget.state;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        ProviderChip(info: v.provider),
        if (s is VerdictComplete && s.secondOpinion)
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.safeContainer,
              borderRadius: AppRadius.rPill,
              border: Border.all(color: AppColors.safe.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.check_circle_rounded,
                    size: 14, color: AppColors.safe),
                const SizedBox(width: 4),
                Text('2 AI engines confirm',
                    style: t.textTheme.labelMedium
                        ?.copyWith(color: AppColors.onSafeContainer)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _stateSpecific(BuildContext ctx, ThemeData t) {
    final VerdictUiState s = widget.state;
    if (s is VerdictAiUpgrading) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _PulsingStrip(),
      );
    }
    if (s is VerdictAiFailed) {
      final String shieldTitle = <String, String>{
        'en': 'Verified by On-Device Kavach Shield',
        'hi': 'ऑन-डिवाइस कवच शील्ड द्वारा सत्यापित',
        'mr': 'ऑन-डिव्हाइस कवच शील्डद्वारे पडताळणी',
        'ta': 'சாதனக் கவசத்தால் சரிபார்க்கப்பட்டது',
        'te': 'ఆన్-డివైస్ కవచ్ షీల్డ్ ద్వారా ధృవీకరించబడింది',
        'bn': 'অন-ডিভাইস কবচ শিল্ড দ্বারা যাচাইকৃত',
        'gu': 'ઓન-ડિવાઇસ કવચ શિલ્ડ દ્વારા ચકાસાયેલ',
        'kn': 'ಆನ್-ಡಿವೈಸ್ ಕವಚ ಶೀಲ್ಡ್ ಮೂಲಕ ಪರಿಶೀಲಿಸಲಾಗಿದೆ',
        'ml': 'ഓൺ-ഡിവൈസ് കവച് ഷീൽഡ് വഴി പരിശോധിച്ചു',
        'pa': 'ਆਨ-ਡਿਵਾਈਸ ਕਵਚ ਸ਼ੀਲਡ ਦੁਆਰਾ ਤਸਦੀਕ ਕੀਤਾ',
      }[locale.code] ?? 'Verified by On-Device Kavach Shield';

      final String shieldSub = <String, String>{
        'en': 'Cloud AI is offline. Your verdict is 100% secured by the local offline rule engine.',
        'hi': 'क्लाउड AI ऑफलाइन है। आपका नतीजा 100% स्थानीय ऑफलाइन नियम इंजन द्वारा सुरक्षित है।',
        'mr': 'क्लाउड AI ऑफलाइन आहे. तुमचा निकाल 100% स्थानिक ऑफलाइन नियम इंजिनद्वारे सुरक्षित आहे.',
        'ta': 'கிளவுட் AI ஆஃப்லைனில் உள்ளது. உங்கள் முடிவு 100% ஆஃப்லைன் என்ஜினால் பாதுகாக்கப்படுகிறது.',
        'te': 'క్లౌడ్ AI ఆఫ్‌లైన్‌లో ఉంది. మీ ఫలితం 100% స్థానిక ఆఫ్‌లైన్ ఇంజిన్ ద్వారా సురక్షితం.',
        'bn': 'ক্লাউড AI অফলাইনে রয়েছে। স্থানীয় নিয়ম ইঞ্জিন দ্বারা আপনার ফলাফল ১০০% সুরক্ষিত।',
        'gu': 'ક્લાઉડ AI ઑફલાઇન છે. તમારો નિર્ણય 100% સ્થાનિક નિયમ એન્જિન દ્વારા સુરક્ષિત છે.',
        'kn': 'ಕ್ಲೌಡ್ AI ಆಫ್‌ಲೈನ್ ಆಗಿದೆ. ನಿಮ್ಮ ಫಲಿತಾಂಶವು 100% ಸ್ಥಳೀಯ ನಿಯಮ ಎಂಜಿನ್‌ನಿಂದ ಸುರಕ್ಷಿತವಾಗಿದೆ.',
        'ml': 'ക്ലൗഡ് AI ഓഫ്‌ലൈനിലാണ്. നിങ്ങളുടെ ഫലം 100% പ്രാദേശിക നിയമ എഞ്ചിൻ വഴി സുരക്ഷിതമാണ്.',
        'pa': 'ਕਲਾਊਡ AI ਔਫਲਾਈਨ ਹੈ। ਤੁਹਾਡਾ ਨਤੀਜਾ 100% ਸਥਾਨਕ ਨਿਯਮ ਇੰਜਣ ਦੁਆਰਾ ਸੁਰੱਖਿਅਤ ਹੈ।',
      }[locale.code] ?? 'Cloud AI is offline. Your verdict is 100% secured by the local offline rule engine.';

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.safeContainer,
            borderRadius: AppRadius.rM,
            border: Border.all(color: AppColors.safe.withOpacity(0.3)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.shield_rounded, color: AppColors.safe),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      shieldTitle,
                      style: t.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shieldSub,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSafeContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onRetry != null)
                KavachButton(
                  label: 'Retry AI',
                  variant: KavachButtonVariant.text,
                  onPressed: widget.onRetry,
                ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Verdict _primaryVerdictFor(VerdictUiState s) {
    if (s is VerdictTier1Only) return s.verdict;
    if (s is VerdictAiUpgrading) return s.tier1;
    if (s is VerdictComplete) return s.verdict;
    if (s is VerdictAiFailed) return s.tier1;
    throw StateError('unreachable');
  }

  static Severity _sevFrom(VerdictLevel l) {
    switch (l) {
      case VerdictLevel.green:
        return Severity.safe;
      case VerdictLevel.amber:
        return Severity.suspicious;
      case VerdictLevel.red:
        return Severity.scam;
    }
  }

  static Color _tintFor(VerdictLevel l) {
    switch (l) {
      case VerdictLevel.green:
        return AppColors.safeContainer;
      case VerdictLevel.amber:
        return AppColors.warningContainer;
      case VerdictLevel.red:
        return AppColors.dangerContainer;
    }
  }

  String _patternHeadline(AppLocale l, String family) {
    const Map<String, Map<String, String>> table = <String, Map<String, String>>{
      'digital_arrest': <String, String>{
        'en': 'Pattern: Digital Arrest',
        'hi': 'पैटर्न: डिजिटल अरेस्ट',
        'mr': 'पॅटर्न: डिजिटल अरेस्ट',
        'ta': 'வகை: டிஜிட்டல் கைது',
        'te': 'నమూనా: డిజిటల్ అరెస్ట్',
        'bn': 'প্যাটার্ন: ডিজিটাল অ্যারেস্ট',
        'gu': 'પેટર્ન: ડિજિટલ ધરપકડ',
        'kn': 'ಮಾದರಿ: ಡಿಜಿಟಲ್ ಅರೆಸ್ಟ್',
        'ml': 'രീതി: ഡിജിറ്റൽ അറസ്റ്റ്',
        'pa': 'ਪੈਟਰਨ: ਡਿਜੀਟਲ ਗ੍ਰਿਫਤਾਰੀ',
      },
      'fake_kyc': <String, String>{
        'en': 'Pattern: Fake KYC',
        'hi': 'पैटर्न: नकली KYC',
        'mr': 'पॅटर्न: बनावट KYC',
        'ta': 'வகை: போலி KYC',
        'te': 'నమూనా: నకిలీ KYC',
        'bn': 'প্যাটার্ন: ফেক কেওয়াইসি',
        'gu': 'પેટર્ન: ખોટી કેવાયસી',
        'kn': 'ಮಾದರಿ: ನಕಲಿ ಕೆವೈಸಿ',
        'ml': 'രീതി: വ്യാജ കെവൈസി',
        'pa': 'ਪੈਟਰਨ: ਜਾਅਲੀ ਕੇਵਾਈਸੀ',
      },
      'upi_collect_trap': <String, String>{
        'en': 'Pattern: UPI Collect Trap',
        'hi': 'पैटर्न: UPI कलेक्ट जाल',
        'mr': 'पॅटर्न: UPI कलेक्ट सापळा',
        'ta': 'வகை: UPI பணப் பொறி',
        'te': 'నమూనా: UPI కలెక్ట్ ట్రాప్',
        'bn': 'প্যাটার্ন: ইউপিআই ফাঁদ',
        'gu': 'પેટર્ન: યુપીઆઈ કલેક્ટ છટકું',
        'kn': 'ಮಾದರಿ: ಯುಪಿಐ ಕಲೆಕ್ಟ್ ಟ್ರ್ಯಾಪ್',
        'ml': 'രീതി: യുപിഐ കളക്ട് ട്രാപ്പ്',
        'pa': 'ਪੈਟਰਨ: ਯੂਪੀਆਈ ਕਲੈਕਟ ਜਾਲ',
      },
      'fake_challan': <String, String>{
        'en': 'Pattern: Fake Challan',
        'hi': 'पैटर्न: नकली चालान',
        'mr': 'पॅटर्न: बनावट चलान',
        'ta': 'வகை: போலி சலான்',
        'te': 'నమూనా: నకిలీ చలాన్',
        'bn': 'প্যাটার্ন: ফেক চালান',
        'gu': 'પેટર્ન: ખોટું ચલણ',
        'kn': 'ಮಾದರಿ: ನಕಲಿ ಚಲನ್',
        'ml': 'രീതി: വ്യാജ ചെല്ലാൻ',
        'pa': 'ਪੈਟਰਨ: ਜਾਅਲੀ ਚਲਾਨ',
      },
      'lottery': <String, String>{
        'en': 'Pattern: Lottery',
        'hi': 'पैटर्न: लॉटरी',
        'mr': 'पॅटर्न: लॉटरी',
        'ta': 'வகை: லாட்டரி',
        'te': 'నమూనా: లాటరీ',
        'bn': 'প্যাটার্ন: লটারি',
        'gu': 'પેટર્ન: લોટરી',
        'kn': 'ಮಾದರಿ: ಲಾಟರಿ',
        'ml': 'രീതി: ലോട്ടറി',
        'pa': 'ਪੈਟਰਨ: ਲਾਟਰੀ',
      },
      'fake_payment_screenshot': <String, String>{
        'en': 'Pattern: Fake Payment Screenshot',
        'hi': 'पैटर्न: नकली पेमेंट स्क्रीनशॉट',
        'mr': 'पॅटर्न: बनावट पेमेंट स्क्रीनशॉट',
        'ta': 'வகை: போலி கட்டண ஸ்கிரீன்ஷாட்',
        'te': 'నమూనా: నకిలీ పేమెంట్ స్క్రీన్‌షాట్',
        'bn': 'প্যাটার্ন: ফেক পেমেন্ট স্ক্রিনশট',
        'gu': 'પેટર્ન: નકલી પેમેન્ટ સ્ક્રીનશોટ',
        'kn': 'ಮಾದರಿ: ನಕಲಿ ಪಾವತಿ ಸ್ಕ್ರೀನ್‌ಶಾಟ್',
        'ml': 'രീതി: വ്യാജ പേയ്മെന്റ് സ്ക്രീൻഷോട്ട്',
        'pa': 'ਪੈਟਰਨ: ਜਾਅਲੀ ਪੇਮੈਂਟ ਸਕ੍ਰੀਨਸ਼ੌਟ',
      },
      'phishing_link': <String, String>{
        'en': 'Pattern: Phishing Link',
        'hi': 'पैटर्न: फ़िशिंग लिंक',
        'mr': 'पॅटर्न: फिशिंग लिंक',
        'ta': 'வகை: ஃபிஷிங் இணைப்பு',
        'te': 'నమూనా: ఫిషింగ్ లింక్',
        'bn': 'প্যাটার্ন: ফিশিং লিঙ্ক',
        'gu': 'પેટર્ન: ફિશિંગ લિંક',
        'kn': 'ಮಾದರಿ: ಫಿಶಿಂಗ್ ಲಿಂಕ್',
        'ml': 'രീതി: ഫിഷിംഗ് ലിങ്ക്',
        'pa': 'ਪੈਟਰਨ: ਫਿਸ਼ਿੰਗ ਲਿੰਕ',
      },
      'qr_impersonation': <String, String>{
        'en': 'Pattern: QR Impersonation',
        'hi': 'पैटर्न: QR धोखा',
        'mr': 'पॅटर्न: QR फसवणूक',
        'ta': 'வகை: QR ஆள்மாறாட்டம்',
        'te': 'నమూనా: QR మోసం',
        'bn': 'প্যাটার্ন: কিউআর ছদ্মবেশ',
        'gu': 'પેટર્ન: ક્યૂઆર છેતરપિંડી',
        'kn': 'ಮಾದರಿ: ಕ್ಯೂಆರ್ ವಂಚನೆ',
        'ml': 'രീതി: ക്യുആർ തട്ടിപ്പ്',
        'pa': 'ਪੈਟਰਨ: ਕਿਊਆਰ ਧੋਖਾਧੜੀ',
      },
      'investment_group': <String, String>{
        'en': 'Pattern: Investment Group',
        'hi': 'पैटर्न: निवेश ग्रुप',
        'mr': 'पॅटर्न: गुंतवणूक गट',
        'ta': 'வகை: முதலீட்டுக் குழு',
        'te': 'నమూనా: ఇన్వెస్ట్‌మెంట్ గ్రూప్',
        'bn': 'প্যাটার্ন: বিনিয়োগ গ্রুপ',
        'gu': 'પેટર્ન: રોકાણ જૂથ',
        'kn': 'ಮಾದರಿ: ಹೂಡಿಕೆ ಗುಂಪು',
        'ml': 'രീതി: നിക്ഷേപ ഗ്രൂപ്പ്',
        'pa': 'ਪੈਟਰਨ: ਨਿਵੇਸ਼ ਸਮੂਹ',
      },
      'sim_swap': <String, String>{
        'en': 'Pattern: SIM Swap',
        'hi': 'पैटर्न: SIM स्वैप',
        'mr': 'पॅटर्न: SIM स्वॅप',
        'ta': 'வகை: சிம் ஸ்வாப்',
        'te': 'నమూనా: సిమ్ మార్పిడి',
        'bn': 'প্যাটার্ন: সিম সোয়াপ',
        'gu': 'પેટર્ન: સિમ કાર્ડ બદલવું',
        'kn': 'ಮಾದರಿ: ಸಿಮ್ ಸ್ವಾಪ್',
        'ml': 'രീതി: സിം സ്വാപ്പ്',
        'pa': 'ਪੈਟਰਨ: ਸਿਮ ਸਵੈਪ',
      },
      'other': <String, String>{
        'en': 'No matched pattern',
        'hi': 'कोई पैटर्न नहीं',
        'mr': 'कोणताही पॅटर्न नाही',
        'ta': 'வகை கண்டறியப்படவில்லை',
        'te': 'నమూనా సరిపోలలేదు',
        'bn': 'কোনো প্যাটার্ন মেলেনি',
        'gu': 'કોઈ પેટર્ન મળી નથી',
        'kn': 'ಯಾವುದೇ ಮಾದರಿ ಹೊಂದಿಕೆಯಾಗಿಲ್ಲ',
        'ml': 'രീതികൾ കണ്ടെത്താനായില്ല',
        'pa': 'ਕੋਈ ਪੈਟਰਨ ਨਹੀਂ ਮਿਲਿਆ',
      },
    };
    final Map<String, String>? row = table[family];
    if (row == null) return table['other']![l.code]!;
    return row[l.code] ?? row['en']!;
  }
}

class _PulsingStrip extends StatefulWidget {
  @override
  State<_PulsingStrip> createState() => _PulsingStripState();
}

class _PulsingStripState extends State<_PulsingStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext ctx, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: t.colorScheme.primaryContainer
                .withOpacity(0.6 + _c.value * 0.4),
            borderRadius: AppRadius.rM,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(t.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 10),
              Text('AI deep-scan in progress…', style: t.textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}