import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';

class ConsentChecklistItem extends StatelessWidget {
  const ConsentChecklistItem({
    required this.icon,
    required this.title,
    required this.body,
    this.emphasize = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color bg = emphasize
        ? t.colorScheme.errorContainer
        : t.colorScheme.surfaceContainerHighest;
    final Color fg = emphasize ? t.colorScheme.error : t.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.rL,
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: fg.withOpacity(0.15),
            child: Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: t.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(body, style: t.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}