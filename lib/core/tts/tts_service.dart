import 'dart:io';

import 'package:digital_kavach/core/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/app_logger.dart';
import '../theme/elder_mode.dart';

/// TTS playback state.
enum TtsState { idle, speaking, stopped }

/// Maps app locale codes to BCP-47 TTS language tags.
const Map<String, String> _localeToTts = {
  'en': 'en-IN',
  'hi': 'hi-IN',
  'mr': 'mr-IN',
  'ta': 'ta-IN',
  'te': 'te-IN',
  'bn': 'bn-IN',
  'gu': 'gu-IN',
  'kn': 'kn-IN',
  'ml': 'ml-IN',
  'pa': 'pa-IN',
};

final ttsServiceProvider = Provider<TtsService>((ref) {
  final elder = ref.watch(elderModeProvider);
  return TtsService(elderEnabled: elder.enabled);
});

/// Text-to-Speech service for reading verdicts and recovery copy aloud.
///
/// - Auto-selects voice based on app locale.
/// - Falls back to `en-IN` if the engine lacks the target language.
/// - Elder Mode defaults to ON with slower rate (0.9).
/// - Gracefully handles devices with no TTS engine installed.
class TtsService {
  TtsService({required bool elderEnabled})
      : _elderEnabled = elderEnabled,
        _tts = FlutterTts() {
    _init();
  }

  final FlutterTts _tts;
  final bool _elderEnabled;
  bool _isInitialized = false;
  bool _muted = false;
  TtsState _state = TtsState.idle;

  TtsState get state => _state;
  bool get isSpeaking => _state == TtsState.speaking;

  Future<void> _init() async {
    try {
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(_elderEnabled ? 0.9 : 1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() => _state = TtsState.speaking);
      _tts.setCompletionHandler(() => _state = TtsState.idle);
      _tts.setErrorHandler((msg) {
        _state = TtsState.idle;
        AppLogger.e('TTS error: $msg', tag: 'tts');
      });

      _isInitialized = true;
    } catch (e) {
      AppLogger.e('TTS init failed: $e', tag: 'tts');
      _isInitialized = false;
    }
  }

  /// Set the TTS language from app locale code.
  Future<void> setLanguage(String localeCode) async {
    if (!_isInitialized) return;
    final ttsLang = _localeToTts[localeCode] ?? 'en-IN';
    try {
      final available = await _tts.isLanguageAvailable(ttsLang);
      if (available) {
        await _tts.setLanguage(ttsLang);
      } else {
        AppLogger.i(
          'TTS lang $ttsLang unavailable, falling back to en-IN',
          tag: 'tts',
        );
        await _tts.setLanguage('en-IN');
      }
    } catch (e) {
      AppLogger.e('setLanguage failed: $e', tag: 'tts');
    }
  }

  /// Speak the given text aloud.
  Future<void> speak(String text) async {
    if (!_isInitialized || _muted || text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      AppLogger.e('speak failed: $e', tag: 'tts');
    }
  }

  /// Stop any active speech.
  Future<void> stop() async {
    try {
      await _tts.stop();
      _state = TtsState.idle;
    } catch (e) {
      AppLogger.e('stop failed: $e', tag: 'tts');
    }
  }

  /// Toggle mute (e.g. from Settings).
  void setMuted(bool muted) {
    _muted = muted;
    if (muted) stop();
  }

  /// Whether TTS should auto-play (Elder Mode default ON).
  bool get shouldAutoPlay => _elderEnabled && !_muted;

  /// Release resources.
  Future<void> dispose() async {
    await stop();
  }
}