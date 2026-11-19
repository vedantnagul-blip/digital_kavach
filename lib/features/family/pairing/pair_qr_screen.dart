import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../family_strings.dart';

class PairQrScreen extends ConsumerWidget {
  const PairQrScreen({
    super.key,
    required this.pairCode,
    required this.familyId,
    required this.expiresAt,
    this.onRegenerate,
    this.onDone,
  });

  final String pairCode;
  final String familyId;
  final DateTime expiresAt;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDone;

  String get _deepLink => Uri(
    scheme: 'kavach',
    host: 'pair',
    queryParameters: {
      'fam': familyId,
      'c': pairCode,
    },
  ).toString();

  Future<void> _copy(
      BuildContext context,
      String value,
      String message,
      ) async {
    await Clipboard.setData(ClipboardData(text: value));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final FamilyStrings s = ref.watch(familyStringsProvider);

    final remaining = expiresAt.difference(DateTime.now());
    final minutesLeft = remaining.inMinutes.clamp(0, 15);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.pairCodeTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl24),

              Text(
                s.familySubtitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl32),

              // Pairing code.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl24,
                  vertical: AppSpacing.xl20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Pairing Code',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    SelectableText(
                      pairCode,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      '$minutesLeft min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: minutesLeft < 3
                            ? AppColors.danger
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l16),

              KavachButton(
                label: 'Copy Pairing Code',
                variant: KavachButtonVariant.tonal,
                icon: Icons.copy,
                onPressed: () => _copy(
                  context,
                  pairCode,
                  'Pairing code copied',
                ),
              ),

              const SizedBox(height: AppSpacing.xxl24),

              // Family ID.
              Text(
                'Family ID',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.s8),

              Container(
                padding: const EdgeInsets.all(AppSpacing.l16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                  ),
                ),
                child: SelectableText(
                  familyId,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: AppSpacing.s8),

              KavachButton(
                label: 'Copy Family ID',
                variant: KavachButtonVariant.tonal,
                icon: Icons.copy,
                onPressed: () => _copy(
                  context,
                  familyId,
                  'Family ID copied',
                ),
              ),

              const SizedBox(height: AppSpacing.s8),

              // This copies both the ID and code in one link.
              KavachButton(
                label: 'Copy Pairing Link',
                variant: KavachButtonVariant.outlined,
                icon: Icons.link,
                onPressed: () => _copy(
                  context,
                  _deepLink,
                  'Pairing link copied',
                ),
              ),

              const SizedBox(height: AppSpacing.l16),

              Text(
                'Share the code and Family ID only with the person '
                    'you want to connect.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl32),

              KavachButton(
                label: 'Done',
                variant: KavachButtonVariant.filled,
                onPressed: onDone ?? () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}