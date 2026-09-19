import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../family_repo.dart';

/// Guardian preference: RED only or RED + AMBER alerts.
class AlertLevelSelector extends StatelessWidget {
  const AlertLevelSelector({
    super.key,
    required this.currentLevel,
    required this.onChanged,
  });

  final AlertLevel currentLevel;
  final ValueChanged<AlertLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Level',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.s8),
        SegmentedButton<AlertLevel>(
          segments: const [
            ButtonSegment(
              value: AlertLevel.redOnly,
              label: Text('Sirf Red'),
              icon: Icon(Icons.error_outline),
            ),
            ButtonSegment(
              value: AlertLevel.redAndAmber,
              label: Text('Red + Amber'),
              icon: Icon(Icons.warning_amber),
            ),
          ],
          selected: {currentLevel},
          onSelectionChanged: (v) => onChanged(v.first),
        ),
      ],
    );
  }
}