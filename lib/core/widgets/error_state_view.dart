import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/exception_mapper.dart';
import '../errors/kavach_exception.dart';
import '../l10n/l10n.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'kavach_button.dart';

/// Error surface used everywhere failures reach the UI.
///
/// Never displays stack traces. Uses [ExceptionMapper] to translate a
/// [KavachException] into a friendly bilingual title + hint.
class ErrorStateView extends ConsumerWidget {
  const ErrorStateView({
    required this.error,
    this.title,
    this.onRetry,
    super.key,
  });

  final KavachException error;
  final String? title;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);
    final UserFacingError ui = ExceptionMapper.toUserMessage(error, l10n);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: t.colorScheme.errorContainer,
                  borderRadius: AppRadius.rXl,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: t.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.l16),
              Text(
                title ?? ui.title,
                style: t.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                ui.hint,
                style: t.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (ui.canRetry && onRetry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xl20),
                KavachButton(
                  label: l10n.strings.retry,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}