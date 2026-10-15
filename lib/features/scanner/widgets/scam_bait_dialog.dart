import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../models/scam_bait_generator.dart';

class ScamBaitDialog extends StatefulWidget {
  const ScamBaitDialog({
    super.key,
    required this.scamType,
    required this.originalText,
  });

  final String scamType;
  final String originalText;

  static void show(BuildContext context, {required String scamType, required String originalText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScamBaitDialog(
        scamType: scamType,
        originalText: originalText,
      ),
    );
  }

  @override
  State<ScamBaitDialog> createState() => _ScamBaitDialogState();
}

class _ScamBaitDialogState extends State<ScamBaitDialog> {
  late List<String> _baitReplies;
  int _copiedIndex = -1;

  @override
  void initState() {
    super.initState();
    _baitReplies = ScamBaitGenerator.generateResponses(
      scamType: widget.scamType,
      originalMessage: widget.originalText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl20,
        right: AppSpacing.xl20,
        top: AppSpacing.xl20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.m12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI ScamBaiter Honeypot 🎣',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Persona: ${ScamBaitGenerator.defaultPersona.name} (${ScamBaitGenerator.defaultPersona.role})',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m12),
          Text(
            'Instead of falling victim, waste the scammer\'s call-center time and bait them into revealing verifiable account numbers & bank details.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.l16),
          ...List.generate(_baitReplies.length, (index) {
            final reply = _baitReplies[index];
            final isCopied = _copiedIndex == index;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.m12),
              padding: const EdgeInsets.all(AppSpacing.m12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCopied ? AppColors.safe : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Option ${index + 1}:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs4),
                  Text(reply, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.s8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: Icon(isCopied ? Icons.check : Icons.copy, size: 16),
                      label: Text(isCopied ? 'Copied to Clipboard!' : 'Copy & Bait Scammer'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: reply));
                        setState(() => _copiedIndex = index);
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bait response copied! Send this to the fraudster.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.s8),
          KavachButton(
            label: 'Close Bait Bot',
            variant: KavachButtonVariant.tonal,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
