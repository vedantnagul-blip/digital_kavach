import 'package:flutter/widgets.dart';

/// Elder Mode configuration — accessibility-first UI amplifiers for
/// non-technical/older users. See blueprint §8 (Elder Mode).
@immutable
class ElderModeConfig {
  /// Whether elder mode is active.
  final bool enabled;

  const ElderModeConfig({this.enabled = false});

  /// Global text scale factor applied via [MediaQuery] wrapper.
  double get textScale => enabled ? 1.4 : 1.0;

  /// Minimum interactive touch target height (dp).
  double get minTouchTarget => enabled ? 64.0 : 48.0;

  /// Whether TTS should auto-play verdict explanations (Phase 05+).
  bool get autoPlayTts => enabled;

  ElderModeConfig copyWith({bool? enabled}) =>
      ElderModeConfig(enabled: enabled ?? this.enabled);

  @override
  bool operator ==(Object other) =>
      other is ElderModeConfig && other.enabled == enabled;

  @override
  int get hashCode => enabled.hashCode;
}

/// Widget that wraps its subtree with the Elder Mode text scaler.
class ElderModeScope extends StatelessWidget {
  const ElderModeScope({
    required this.config,
    required this.child,
    super.key,
  });

  final ElderModeConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    // Cap scale between 1.0 and 1.4 — never smaller than requested by system,
    // never larger than Elder Mode's ceiling (prevents runaway a11y scale).
    final double effective = config.enabled
        ? (mq.textScaler.scale(1.0) < 1.4
        ? 1.4
        : mq.textScaler.scale(1.0).clamp(1.0, 1.4))
        : mq.textScaler.scale(1.0).clamp(1.0, 1.4);

    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(effective)),
      child: child,
    );
  }
}