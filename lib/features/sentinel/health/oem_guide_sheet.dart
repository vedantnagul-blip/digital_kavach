import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class OemGuideSheet extends StatelessWidget {
  const OemGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('OEM Background Kill Prevention', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.m12),
            _guideItem(
              theme,
              'Xiaomi / MIUI / HyperOS',
              '1. Settings > Apps > Manage Apps > Digital Kavach\n2. "Autostart" enable karein\n3. Battery Saver > "No restrictions" chunein',
            ),
            _guideItem(
              theme,
              'Samsung One UI',
              '1. Settings > Battery > Background usage limits\n2. Digital Kavach ko "Never sleeping apps" me add karein',
            ),
            _guideItem(
              theme,
              'Vivo / OPPO / Realme',
              '1. App Info > Battery usage > "Allow background activity" enable karein\n2. Autostart permission allow karein',
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideItem(ThemeData theme, String oem, String steps) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(oem, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(steps, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}