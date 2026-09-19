import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../complaint_service.dart';

class ComplaintPreview extends StatelessWidget {
  const ComplaintPreview({
    super.key,
    required this.draft,
    this.onEdit,
    this.onCopy,
    this.onSharePdf,
    this.onRegenerate,
    this.isRegenerating = false,
  });

  final RecoveryDraft draft;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onSharePdf;
  final VoidCallback? onRegenerate;
  final bool isRegenerating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAi = draft.source == DraftSource.ai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isAi ? Icons.auto_awesome : Icons.description_outlined,
              size: 16,
              color: isAi ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs4),
            Text(
              isAi ? 'AI dwara taiyaar' : 'Template dwara taiyaar',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.l16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: SelectableText(
            draft.complaintEn,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: 'monospace',
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l16),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            KavachButton(
              label: 'Copy',
              variant: KavachButtonVariant.tonal,
              icon: Icons.copy,
              onPressed: onCopy ??
                      () {
                    Clipboard.setData(ClipboardData(text: draft.complaintEn));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
            ),
            if (onSharePdf != null)
              KavachButton(
                label: 'PDF Share',
                variant: KavachButtonVariant.outlined,
                icon: Icons.picture_as_pdf,
                onPressed: onSharePdf,
              ),
            if (onRegenerate != null)
              KavachButton(
                label: isRegenerating ? 'Please wait…' : 'Regenerate',
                variant: KavachButtonVariant.text,
                icon: Icons.refresh,
                onPressed: isRegenerating ? null : onRegenerate,
              ),
          ],
        ),
      ],
    );
  }
}