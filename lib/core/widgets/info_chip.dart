import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// Compact metadata chip — used for provider names, quick stats, etc.
class InfoChip extends StatelessWidget {
  const InfoChip({
    required this.label,
    this.icon,
    this.foreground,
    this.background,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color fg = foreground ?? t.colorScheme.onSurfaceVariant;
    final Color bg = background ?? t.colorScheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.rPill,
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: t.textTheme.labelMedium?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}