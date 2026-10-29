import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_logger.dart';

final edgeAiServiceProvider = Provider<LocalEdgeAiService>((ref) {
  return LocalEdgeAiService();
});

class LocalEdgeAiService {
  static const MethodChannel _channel =
      MethodChannel('com.digitalkavach.app/edge_llm');

  bool _isInitialized = false;

  /// Check if the on-device Gemma weights are present on the storage
  Future<bool> isModelAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isEdgeAiSupported');
      return available;
    } catch (_) {
      return false;
    }
  }

  /// Initialize MediaPipe LLM Inference engine
  Future<bool> initialize({String? customPath}) async {
    if (_isInitialized) return true;
    try {
      final bool success = await _channel.invokeMethod('initGemma', {
        if (customPath != null) 'modelPath': customPath,
      });
      _isInitialized = success;
      return success;
    } catch (e) {
      AppLogger.w('Edge AI (Gemma) init failed or file absent: $e', tag: 'edge_ai');
      return false;
    }
  }

  /// Run local edge inference with prompt
  Future<String?> generateResponse(String prompt) async {
    try {
      if (!_isInitialized) {
        final ok = await initialize();
        if (!ok) return null;
      }
      final String? response =
          await _channel.invokeMethod('infer', {'prompt': prompt});
      return response;
    } catch (e) {
      AppLogger.w('Edge AI inference error: $e', tag: 'edge_ai');
      return null;
    }
  }
}
