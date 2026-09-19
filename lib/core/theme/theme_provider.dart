import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'elder_mode.dart';

/// Elder Mode Riverpod notifier — StateNotifier for compatibility with
/// Riverpod 2.5.x. Phase 09 (Settings) persists this to Hive.
class ElderModeNotifier extends StateNotifier<ElderModeConfig> {
  ElderModeNotifier() : super(const ElderModeConfig());

  void toggle() => state = state.copyWith(enabled: !state.enabled);

  void setEnabled(bool value) => state = state.copyWith(enabled: value);
}

/// Global Elder Mode provider.
final StateNotifierProvider<ElderModeNotifier, ElderModeConfig>
elderModeProvider = StateNotifierProvider<ElderModeNotifier, ElderModeConfig>(
      (StateNotifierProviderRef<ElderModeNotifier, ElderModeConfig> ref) =>
      ElderModeNotifier(),
);

/// Global theme mode provider (system / light / dark).
/// Phase 09 (Settings) wires a persisted override.
final StateProvider<ThemeMode> themeModeProvider =
StateProvider<ThemeMode>((Ref<ThemeMode> ref) => ThemeMode.system);

/// Onboarding flag — Phase 02 replaces with a Hive-backed real provider.
/// Default: onboarded=true so the router lands on Home during Phase 01
/// so we can verify all placeholder screens.
final StateProvider<bool> onboardedProvider =
StateProvider<bool>((Ref<bool> ref) => true);