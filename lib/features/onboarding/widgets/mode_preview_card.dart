import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';

/// Live-render preview card demonstrating actual scale of Standard vs Elder.
class ModePreviewCard extends StatelessWidget {
  const ModePreviewCard({
    required this.title,
    required this.bullets,
    required this.previewText,
    required this.textScale,
    required this.buttonHeight,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final List<String> bullets;
  final String previewText;
  final double textScale;
  final double buttonHeight;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color border =
    selected ? t.colorScheme.primary : t.colorScheme.outlineVariant;
    final Color bg =
    selected ? t.colorScheme.primaryContainer : t.colorScheme.surface;

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: bg,
        borderRadius: AppRadius.rXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rXl,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rXl,
              border: Border.all(color: border, width: selected ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded,
                          color: t.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 12),
                // Live preview: forces this subtree to render at [textScale]
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.rM,
                      color: t.colorScheme.surfaceContainerHighest,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          previewText,
                          style: t.textTheme.bodyLarge?.copyWith(
                            color: t.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: buttonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.colorScheme.primary,
                            borderRadius: AppRadius.rPill,
                          ),
                          child: Text(
                            'OK',
                            style: t.textTheme.labelLarge?.copyWith(
                              color: t.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...bullets.map(
                      (String b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.check_rounded,
                            size: 16, color: t.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(b, style: t.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}