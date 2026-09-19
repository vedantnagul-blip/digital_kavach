import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../onboarding_controller.dart';
import '../onboarding_strings.dart';
import '../widgets/step_progress_bar.dart';

class SentinelSetupScreen extends ConsumerWidget {
  const SentinelSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingStrings s = ref.watch(onboardingStringsProvider);
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
    ref.read(onboardingControllerProvider.notifier);
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);

    Future<void> finish() async {
      await ctrl.completeSentinelSetup(
        const SentinelSetupStatus(skipped: true),
      );
      await ctrl.completeAll();
    }

    return KavachScaffold(
      title: Text(l10n.strings.appName),
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StepProgressBar(step: state.step),
          const SizedBox(height: 20),
          Icon(Icons.shield_rounded, size: 56, color: t.colorScheme.primary),
          const SizedBox(height: 12),
          Text(s.sentinelTitle, style: t.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(s.sentinelSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: 20),
          _LockedStepTile(label: s.sentinelStepNotifAccess),
          _LockedStepTile(label: s.sentinelStepBattery),
          _LockedStepTile(label: s.sentinelStepPostNotif),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.rM,
              border: Border.all(color: t.colorScheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline_rounded,
                    size: 20, color: t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.sentinelLockedNote,
                      style: t.textTheme.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          KavachButton(
            label: s.finish,
            icon: Icons.check_rounded,
            expand: true,
            onPressed: finish,
          ),
        ],
      ),
    );
  }
}

class _LockedStepTile extends StatelessWidget {
  const _LockedStepTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock_outline_rounded,
              size: 20, color: t.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: t.textTheme.titleSmall),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.rPill,
            ),
            child: Text(
              'Phase 06',
              style: t.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}