import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'kavach_button.dart';

/// Friendly empty state. Every list/screen without data uses this.
class EmptyStateView extends ConsumerWidget {
  const EmptyStateView({
    this.icon = Icons.inbox_outlined,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: t.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.rXl,
                ),
                child: Icon(icon, size: 40, color: t.colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.l16),
              Text(
                title ?? l10n.strings.emptyDefaultTitle,
                style: t.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                message ?? l10n.strings.emptyDefaultMessage,
                style: t.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xl20),
                KavachButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: KavachButtonVariant.tonal,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}