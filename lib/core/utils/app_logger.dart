import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Central logger. Never call `print()` — this is enforced by lints.
///
/// Debug builds → dev console.
/// Release builds → Crashlytics for errors; info/warnings are silent.
class AppLogger {
  const AppLogger._();

  static void i(String message, {String tag = 'DigitalKavach'}) {
    if (kDebugMode) developer.log(message, name: tag);
  }

  static void w(String message, {String tag = 'DigitalKavach'}) {
    if (kDebugMode) developer.log('⚠️ $message', name: tag);
  }

  static void e(
      String message, {
        Object? error,
        StackTrace? stackTrace,
        bool fatal = false,
        String tag = 'DigitalKavach',
      }) {
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      // Fire-and-forget to Crashlytics in release.
      try {
        FirebaseCrashlytics.instance.recordError(
          error ?? message,
          stackTrace,
          reason: message,
          fatal: fatal,
        );
      } catch (_) {
        // Never let logger itself throw.
      }
    }
  }

  // Backwards-compat aliases from Phase 00.
  static void info(String message, {String tag = 'DigitalKavach'}) =>
      i(message, tag: tag);
  static void warning(String message, {String tag = 'DigitalKavach'}) =>
      w(message, tag: tag);
  static void error(
      String message, {
        Object? e,
        StackTrace? st,
        String tag = 'DigitalKavach',
      }) =>
      AppLogger.e(message, error: e, stackTrace: st, tag: tag);
}