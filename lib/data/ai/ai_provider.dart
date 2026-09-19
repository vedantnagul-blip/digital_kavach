import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';

/// Network/LLM client contract.
/// Named [AiProviderClient] so it does NOT clash with enum [AiProvider]
/// in verdict.dart (gemini | grok | tier1 | cached).
abstract class AiProviderClient {
  String get name;
  bool get supportsVision;
  Future<Verdict> analyze(ScanRequest req);
}