import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';

/// Riverpod provider for Gemma Plugin Service
final gemmaPluginServiceProvider = Provider<GemmaPluginService>((ref) {
  return GemmaPluginService();
});

/// Service to interact with the on-device Gemma 2B INT4 model
class GemmaPluginService {
  final _gemma = FlutterGemmaPlugin.instance;
  bool _isInitialized = false;

  /// Check if the Gemma model is ready for inference
  bool get isReady => _isInitialized;

  /// Initialize the on-device Gemma engine
  ///
  /// [filePath]: Path to the Gemma model file (default: '/data/local/tmp/gemma-2b-it-cpu-int4.bin')
  /// Returns: true if initialization successful, false otherwise
  Future<bool> initModel([String filePath = '/data/local/tmp/gemma-2b-it-cpu-int4.bin']) async {
    if (_isInitialized) {
      AppLogger.i('Gemma already initialized', tag: 'gemma');
      return true;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.w('Gemma weight file not found at: $filePath', tag: 'gemma');
        return false;
      }

      AppLogger.i('Initializing Gemma Edge AI...', tag: 'gemma');

      await _gemma.init(
        maxTokens: 256,
        temperature: 0.2,
        randomSeed: 1,
        topK: 1,
      );

      _isInitialized = true;
      AppLogger.i('✅ Gemma Edge AI Initialized successfully!', tag: 'gemma');
      return true;
    } catch (e) {
      AppLogger.e('❌ Gemma initialization error: $e', tag: 'gemma');
      return false;
    }
  }

  /// Analyze a message for Indian cyber fraud or social engineering
  ///
  /// Uses optimized prompt for Gemma 2B INT4:
  /// - Structured output format
  /// - Few-shot example
  /// - Token budget: <200
  /// - Latency target: <1.5s
  ///
  /// [message]: The text message to analyze
  /// Returns: Analysis result as String, or null if error
  Future<String?> analyzeScam(String message) async {
    final prompt = '''<start_of_turn>user
You are Digital Kavach, an expert Indian cyber defense AI.
Analyze this message for cyber fraud, social engineering, digital arrest, or fake bill/KYC coercion:
"$message"

Respond in this exact concise format:
Risk: [Critical / Suspicious / Safe]
Type: [Scam Type, e.g. Digital Arrest / Mahavitaran Bill / Fake APK / Lottery / None]
Reason: [One clear sentence explaining the danger in plain words]
Action: [One immediate advice, e.g. Do not pay, Dial 1930]<end_of_turn>
<start_of_turn>model
''';
    return generateInference(prompt);
  }

  /// Generate a decoy reply as "Ramesh Kaka" to delay scammers
  ///
  /// Uses optimized prompt for Gemma 2B INT4:
  /// - Character persona: Ramesh Kaka (62-year-old innocent grandfather)
  /// - Token budget: <200
  /// - Output: 2 sentences max, simple Hinglish
  ///
  /// [originalScamMessage]: The scam message received
  /// Returns: Decoy reply as String, or null if error
  Future<String?> generateBaitReply(String originalScamMessage) async {
    final prompt = '''<start_of_turn>user
You are Ramesh Kaka, an innocent 62-year-old Indian grandfather who gets confused by modern apps.
A fraudster sent this message:
"$originalScamMessage"

Write a realistic, polite, confused reply pretending you want to pay or cooperate, but asking for their official branch address, supervisor name, or bank account number.
Rules:
- Keep it under 2 sentences.
- Speak in simple Indian English or Hinglish.
- Sound innocent and gullible to delay them.<end_of_turn>
<start_of_turn>model
''';
    return generateInference(prompt);
  }

  /// Generic inference method for any prompt
  ///
  /// [prompt]: The prompt to send to Gemma
  /// Returns: Response as String, or null if error
  Future<String?> generateInference(String prompt) async {
    try {
      // Auto-initialize if not ready
      if (!_isInitialized) {
        final ok = await initModel();
        if (!ok) {
          AppLogger.w('Gemma not initialized, cannot generate inference', tag: 'gemma');
          return null;
        }
      }

      AppLogger.i('Generating inference with Gemma 2B...', tag: 'gemma');
      final response = await _gemma.getResponse(prompt: prompt);

      if (response == null || response.isEmpty) {
        AppLogger.w('Empty response from Gemma', tag: 'gemma');
        return null;
      }

      AppLogger.i('Gemma inference completed', tag: 'gemma');
      return response.trim();
    } catch (e) {
      AppLogger.e('❌ Gemma inference failed: $e', tag: 'gemma');
      return null;
    }
  }
}