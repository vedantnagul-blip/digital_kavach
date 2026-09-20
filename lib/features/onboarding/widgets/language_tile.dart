import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../onboarding_strings.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SupportedLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color bg = selected
        ? t.colorScheme.primaryContainer
        : t.colorScheme.surface;
    final Color border = selected
        ? t.colorScheme.primary
        : t.colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: '${language.nativeName}, ${language.englishName}',
      child: Material(
        color: bg,
        borderRadius: AppRadius.rL,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rL,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rL,
              border: Border.all(color: border, width: selected ? 2 : 1),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        language.nativeName,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language.englishName,
                        style: t.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: selected ? 1.0 : 0.0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: t.colorScheme.primary,
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
