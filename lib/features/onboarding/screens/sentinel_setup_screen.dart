import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../../sentinel/sentinel_controller.dart';
import '../onboarding_controller.dart';
import '../onboarding_strings.dart';
import '../widgets/step_progress_bar.dart';

class SentinelSetupScreen extends ConsumerStatefulWidget {
  const SentinelSetupScreen({super.key});

  @override
  ConsumerState<SentinelSetupScreen> createState() =>
      _SentinelSetupScreenState();
}

class _SentinelSetupScreenState extends ConsumerState<SentinelSetupScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(sentinelControllerProvider.notifier).refresh();
    }
  }

  Future<void> _finish({required bool skipped}) async {
    final status =
        ref.read(sentinelControllerProvider).valueOrNull ?? SentinelStatus.empty;
    final OnboardingController ctrl =
        ref.read(onboardingControllerProvider.notifier);

    await ctrl.completeSentinelSetup(
      SentinelSetupStatus(
        notifAccessGranted: status.listenerGranted,
        batteryExempt: status.batteryExempted,
        postNotifGranted: status.enabled,
        skipped: skipped,
      ),
    );
    await ctrl.completeAll();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingStrings s = ref.watch(onboardingStringsProvider);
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
        ref.read(onboardingControllerProvider.notifier);
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);

    final SentinelStatus status =
        ref.watch(sentinelControllerProvider).valueOrNull ??
            SentinelStatus.empty;
    final SentinelController sentinelCtrl =
        ref.read(sentinelControllerProvider.notifier);

    return KavachScaffold(
      title: Text(l10n.strings.appName),
      leading: ctrl.canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: ctrl.back,
            )
          : null,
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StepProgressBar(step: state.step),
          const SizedBox(height: 20),
          Icon(Icons.shield_rounded, size: 48, color: t.colorScheme.primary),
          const SizedBox(height: 12),
          Text(s.sentinelTitle, style: t.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(s.sentinelSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: 20),

          // Interactive Step 1: Notification Access
          _SetupStepCard(
            stepNumber: 1,
            title: s.sentinelStepNotifAccess,
            description:
                'Allows Kavach to inspect incoming scam SMS & WhatsApp notifications entirely on-device.',
            isGranted: status.listenerGranted,
            actionLabel: status.listenerGranted
                ? s.sentinelActionGranted
                : s.sentinelActionGrant,
            onAction: status.listenerGranted
                ? null
                : sentinelCtrl.openListenerSettings,
          ),

          // Interactive Step 2: Battery Saver Exemption
          _SetupStepCard(
            stepNumber: 2,
            title: s.sentinelStepBattery,
            description:
                'Keeps Kavach Sentinel active in the background when your screen is locked.',
            isGranted: status.batteryExempted,
            actionLabel: status.batteryExempted
                ? s.sentinelActionGranted
                : s.sentinelActionGrant,
            onAction: status.batteryExempted
                ? null
                : sentinelCtrl.requestBatteryExemption,
          ),

          // Interactive Step 3: Enable Background Shield
          _SetupStepCard(
            stepNumber: 3,
            title: s.sentinelStepPostNotif,
            description:
                'Enables immediate head-up warning popups when suspicious links or APKs are detected.',
            isGranted: status.enabled,
            actionLabel:
                status.enabled ? s.sentinelActive : s.sentinelEnable,
            onAction: () async {
              await sentinelCtrl.setEnabled(!status.enabled);
            },
          ),

          const SizedBox(height: 12),

          // Active confirmation banner
          if (status.isFullyReady)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.safeContainer,
                borderRadius: AppRadius.rL,
                border: Border.all(color: AppColors.safe, width: 1.5),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.verified_rounded,
                      color: AppColors.safe, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sentinel is active! 24x7 Real-Time Protection is running.',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSafeContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
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

          KavachButton(
            label: s.finish,
            icon: Icons.check_circle_rounded,
            expand: true,
            onPressed: () => _finish(skipped: false),
          ),
          const SizedBox(height: 10),
          KavachButton(
            label: s.sentinelLater,
            variant: KavachButtonVariant.text,
            expand: true,
            onPressed: () => _finish(skipped: true),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SetupStepCard extends StatelessWidget {
  const _SetupStepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.actionLabel,
    this.onAction,
  });

  final int stepNumber;
  final String title;
  final String description;
  final bool isGranted;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(
          color: isGranted ? AppColors.safe : t.colorScheme.outlineVariant,
          width: isGranted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: isGranted
                    ? AppColors.safe
                    : t.colorScheme.primaryContainer,
                child: isGranted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : Text(
                        '$stepNumber',
                        style: t.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: t.colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isGranted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.safe,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!isGranted && onAction != null) ...<Widget>[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 36,
                child: FilledButton.tonal(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.rPill,
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
