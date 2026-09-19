import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import 'oem_guide_sheet.dart';
import 'uptime_chart.dart';

class HealthCenterScreen extends ConsumerWidget {
  const HealthCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sentinel Health Center')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l16),
            decoration: BoxDecoration(
              color: AppColors.safeContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.safe.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text('7-Day Active Uptime', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  '99.4%',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: AppColors.safe,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m12),
                const UptimeChart(uptimePercentages: [1.0, 1.0, 0.98, 1.0, 0.92, 1.0, 1.0]),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),
          Text('Service Health Checks', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.m12),
          _statusTile(theme, 'Notification Listener', 'Active & Receiving', true),
          _statusTile(theme, 'Battery Optimization', 'Unrestricted', true),
          _statusTile(theme, 'Foreground Service', 'Running', true),
          const SizedBox(height: AppSpacing.xxl24),
          KavachButton(
            label: 'Phone-Specific Fixes (OEM Guide)',
            variant: KavachButtonVariant.outlined,
            icon: Icons.phone_android,
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const OemGuideSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTile(ThemeData theme, String label, String status, bool ok) {
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.error,
        color: ok ? AppColors.safe : AppColors.danger,
      ),
      title: Text(label, style: theme.textTheme.titleSmall),
      subtitle: Text(status, style: theme.textTheme.bodySmall),
      dense: true,
    );
  }
}