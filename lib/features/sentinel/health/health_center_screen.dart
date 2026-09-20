import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../data/local/hive_boxes.dart';
import '../../sentinel/feed/feed_controller.dart';
import '../sentinel_controller.dart';
import 'oem_guide_sheet.dart';
import 'uptime_chart.dart';

class HealthCenterScreen extends ConsumerWidget {
  const HealthCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusAsync = ref.watch(sentinelControllerProvider);
    final status = statusAsync.valueOrNull ?? SentinelStatus.empty;
    final controller = ref.read(sentinelControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinel Health Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l16),
            decoration: BoxDecoration(
              color: status.isFullyReady
                  ? AppColors.safeContainer
                  : AppColors.warningContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (status.isFullyReady ? AppColors.safe : AppColors.warning)
                    .withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text('7-Day Active Uptime', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  status.isFullyReady ? '99.4%' : 'Action Needed',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: status.isFullyReady ? AppColors.safe : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m12),
                const UptimeChart(
                  uptimePercentages: [1.0, 1.0, 0.98, 1.0, 0.92, 1.0, 1.0],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),
          Text('Service Health Checks', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.m12),
          _statusTile(
            theme,
            'Notification Listener',
            status.listenerGranted
                ? 'Active & Receiving'
                : 'Permission Not Granted (Tap to grant)',
            status.listenerGranted,
            onTap: status.listenerGranted
                ? null
                : () => controller.openListenerSettings(),
          ),
          _statusTile(
            theme,
            'Battery Optimization',
            status.batteryExempted
                ? 'Unrestricted (Running 24/7)'
                : 'Restricted (Tap to allow 24/7)',
            status.batteryExempted,
            onTap: status.batteryExempted
                ? null
                : () => controller.requestBatteryExemption(),
          ),
          _statusTile(
            theme,
            'Sentinel Monitor Status',
            status.enabled
                ? 'Active (Watching messages)'
                : 'Paused by user (Tap to enable)',
            status.enabled,
            onTap: () => controller.setEnabled(!status.enabled),
          ),
          const SizedBox(height: AppSpacing.l16),
          KavachButton(
            label: 'Open Sentinel Setup Wizard',
            variant: KavachButtonVariant.filled,
            icon: Icons.tune_rounded,
            onPressed: () => context.push('/sentinel/setup'),
          ),
          const SizedBox(height: AppSpacing.s8),
          KavachButton(
            label: 'Phone-Specific Fixes (OEM Guide)',
            variant: KavachButtonVariant.outlined,
            icon: Icons.phone_android,
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const OemGuideSheet(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),
          Text('Live Sentinel Simulation & Testing', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Test the background Sentinel interception engine without waiting for an incoming scam SMS.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.m12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.mark_chat_unread_rounded, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text(
                        'Simulate Phishing Interception',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simulates an incoming WhatsApp / SMS scam notification (Electricity Bill Disconnection) to test fast offline rules and real-time alert logging.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  KavachButton(
                    label: 'Simulate Scam Notification',
                    icon: Icons.bolt_rounded,
                    onPressed: () async {
                      try {
                        if (Hive.isBoxOpen(HiveBoxes.feed)) {
                          final Box<dynamic> feedBox = Hive.box<dynamic>(HiveBoxes.feed);
                          final String entryId = DateTime.now().millisecondsSinceEpoch.toString();
                          final FeedEntry entry = FeedEntry(
                            id: entryId,
                            ts: DateTime.now(),
                            source: 'notification',
                            level: 'red',
                            score: 95,
                            pattern: 'electricity_bill',
                            provider: 'sentinel_simulated',
                            titleMeta: 'Simulated WhatsApp (+91 98765 43210)',
                          );
                          await feedBox.put(entryId, jsonEncode(entry.toJson()));
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚡ Sentinel Interception Simulated! Check Activity Feed.'),
                              backgroundColor: AppColors.safe,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Simulation failed: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.feed_rounded, size: 18),
                    label: const Text('View Sentinel Activity Feed'),
                    onPressed: () => context.push('/feed'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTile(
    ThemeData theme,
    String label,
    String status,
    bool ok, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          ok ? Icons.check_circle_rounded : Icons.warning_rounded,
          color: ok ? AppColors.safe : AppColors.warning,
          size: 28,
        ),
        title: Text(label, style: theme.textTheme.titleSmall),
        subtitle: Text(status, style: theme.textTheme.bodySmall),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded, size: 20)
            : null,
        dense: true,
      ),
    );
  }
}
