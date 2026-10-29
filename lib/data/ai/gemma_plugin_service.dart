import 'dart:io';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_logger.dart';

final gemmaPluginServiceProvider = Provider<GemmaPluginService>((ref) {
  return GemmaPluginService();
});

class GemmaPluginService {
  final _gemma = FlutterGemmaPlugin.instance;
  bool _isInitialized = false;

  bool get isReady => _isInitialized;

  /// 1. Initialize the on-device Gemma engine
  Future<bool> initModel([String filePath = '/data/local/tmp/gemma-2b-it-cpu-int4.bin']) async {
    if (_isInitialized) return true;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.w('Gemma weight file not found at: $filePath', tag: 'gemma');
        return false;
      }

      await _gemma.init(
        maxTokens: 256,
        temperature: 0.2,
        randomSeed: 1,
        topK: 1,
      );

      _isInitialized = true;
      AppLogger.i('Gemma Edge AI Initialized successfully!', tag: 'gemma');
      return true;
    } catch (e) {
      AppLogger.e('Gemma initialization error: $e', tag: 'gemma');
      return false;
    }
  }

  /// 2. Deep Scam Reasoning: Analyze deceptive vernacular text
  Future<String?> analyzeScam(String message) async {
    final prompt = '''Analyze this message for Indian cyber fraud or social engineering:
"$message"
Explain the scam type, risk level (Critical/Warning/Safe), and immediate action.''';
    return generateInference(prompt);
  }

  /// 3. AI ScamBaiter: Generate decoy response as "Ramesh Kaka"
  Future<String?> generateBaitReply(String originalScamMessage) async {
    final prompt = '''You are Ramesh Kaka, an innocent elderly Indian citizen who does not understand modern tech well.
A fraudster sent this message: "$originalScamMessage".
Write a short, realistic, confused reply asking innocent questions to delay the scammer and make them reveal their official bank account or supervisor number. Reply in simple Indian English/Hinglish in 2 sentences.''';
    return generateInference(prompt);
  }

  /// Generic inference helper
  Future<String?> generateInference(String prompt) async {
    try {
      if (!_isInitialized) {
        final ok = await initModel();
        if (!ok) return null;
      }

      final response = await _gemma.getResponse(prompt: prompt);
      return response;
    } catch (e) {
      AppLogger.e('Gemma inference failed: $e', tag: 'gemma');
      return null;
    }
  }
}
