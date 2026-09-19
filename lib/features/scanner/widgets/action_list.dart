import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';

class ActionList extends StatelessWidget {
  const ActionList({required this.actions, super.key});
  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    final ThemeData t = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String a in actions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.rPill,
              border: Border.all(color: t.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(_iconFor(a),
                    size: 16, color: t.colorScheme.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    a,
                    style: t.textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _iconFor(String a) {
    final String l = a.toLowerCase();
    if (l.contains('1930')) return Icons.call_rounded;
    if (l.contains('otp')) return Icons.password_rounded;
    if (l.contains('reply')) return Icons.block_rounded;
    if (l.contains('verify')) return Icons.verified_user_rounded;
    return Icons.info_outline_rounded;
  }
}