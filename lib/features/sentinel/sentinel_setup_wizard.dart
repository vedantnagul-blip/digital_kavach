import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import '../../core/widgets/section_header.dart';
import 'sentinel_controller.dart';

class SentinelSetupWizard extends ConsumerWidget {
  const SentinelSetupWizard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SentinelStatus> asyncStatus =
    ref.watch(sentinelControllerProvider);
    final SentinelController ctrl =
    ref.read(sentinelControllerProvider.notifier);

    return KavachScaffold(
      title: const Text('Sentinel Setup'),
      scrollable: true,
      body: asyncStatus.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) =>
            Text('Error loading status: $err'),
        data: (SentinelStatus status) => _buildSteps(context, ctrl, status),
      ),
    );
  }

  Widget _buildSteps(
      BuildContext context,
      SentinelController ctrl,
      SentinelStatus status,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHeader(
          title: '🛡️ Turn on Sentinel Mode',
          subtitle: 'Grant 3 permissions to enable auto-warnings',
        ),
        const SizedBox(height: AppSpacing.l16),
        _StepCard(
          stepNo: 1,
          title: 'Notification Access',
          description:
          'Allows Kavach to read WhatsApp/SMS notifications on your device (never on our servers).',
          done: status.listenerGranted,
          actionLabel: status.listenerGranted ? 'Granted ✓' : 'Grant Now',
          onAction:
          status.listenerGranted ? null : ctrl.openListenerSettings,
          extraNote:
          'If toggle is greyed out: Open App Info → Tap ⋮ → Enable "Allow restricted settings".',
        ),
        const SizedBox(height: AppSpacing.m12),
        _StepCard(
          stepNo: 2,
          title: 'Battery Optimization Exemption',
          description:
          'Prevents Android from killing our service when your phone is idle.',
          done: status.batteryExempted,
          actionLabel: status.batteryExempted ? 'Granted ✓' : 'Grant Now',
          onAction:
          status.batteryExempted ? null : ctrl.requestBatteryExemption,
          extraNote:
          'MIUI / OPPO / Vivo users: Also enable "Autostart" in device settings.',
        ),
        const SizedBox(height: AppSpacing.m12),
        _StepCard(
          stepNo: 3,
          title: 'Enable Sentinel',
          description:
          'Turn on background scam detection for WhatsApp, SMS, and Telegram.',
          done: status.enabled,
          actionLabel: status.enabled ? 'Active ✓' : 'Enable',
          onAction: () async {
            await ctrl.setEnabled(!status.enabled);
          },
        ),
        const SizedBox(height: AppSpacing.xxl24),
        if (status.isFullyReady)
          Container(
            padding: const EdgeInsets.all(AppSpacing.l16),
            decoration: BoxDecoration(
              color: AppColors.safeContainer,
              borderRadius: AppRadius.rXl,
              border: Border.all(color: AppColors.safe, width: 2),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.verified_rounded,
                    color: AppColors.safe, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sentinel is fully active! You are protected.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSafeContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.l16),
        KavachButton(
          label: 'Refresh Status',
          icon: Icons.refresh_rounded,
          variant: KavachButtonVariant.outlined,
          onPressed: ctrl.refresh,
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNo,
    required this.title,
    required this.description,
    required this.done,
    required this.actionLabel,
    this.onAction,
    this.extraNote,
  });

  final int stepNo;
  final String title;
  final String description;
  final bool done;
  final String actionLabel;
  final VoidCallback? onAction;
  final String? extraNote;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(
          color: done ? AppColors.safe : t.colorScheme.outlineVariant,
          width: done ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor:
                done ? AppColors.safe : t.colorScheme.primaryContainer,
                child: done
                    ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 20)
                    : Text('$stepNo',
                    style: t.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: t.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: t.textTheme.bodyMedium),
          if (extraNote != null) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: AppRadius.rM,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(extraNote!,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: AppColors.onWarningContainer,
                        )),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          KavachButton(
            label: actionLabel,
            variant: done
                ? KavachButtonVariant.outlined
                : KavachButtonVariant.filled,
            onPressed: onAction,
            expand: true,
          ),
        ],
      ),
    );
  }
}