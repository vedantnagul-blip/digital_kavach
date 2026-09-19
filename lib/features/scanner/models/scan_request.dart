import '../../../data/rules/rule.dart';
import '../../../data/rules/rule_engine.dart';

/// A scan request queued from any intake path.
class ScanRequest {
  const ScanRequest({
    required this.text,
    required this.source,
    this.senderTitle,
    this.imageBytes,
    this.imageMime,
    this.upiParams,
    this.langCode = 'en',
    this.tier1Hints = const <RuleHit>[],
    this.knowledgeBase = '',
  });

  final String text;
  final String? senderTitle;
  final Map<String, String>? upiParams;
  final ScanSource source;
  final String langCode;

  // Phase 04 Additions (additive only)
  final List<int>? imageBytes;
  final String? imageMime;
  final List<RuleHit> tier1Hints;
  final String knowledgeBase;
}