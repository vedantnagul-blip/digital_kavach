import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/kavach_button.dart';
import '../complaint_service.dart';

/// Step 5: Send bank dispute email.
class BankScreen extends StatelessWidget {
  const BankScreen({
    super.key,
    required this.draft,
    required this.onSent,
    required this.onNext,
    required this.onBack,
  });

  final RecoveryDraft? draft;
  final VoidCallback onSent;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Future<void> _openMail(BuildContext context) async {
    if (draft == null) return;
    final subject = Uri.encodeComponent(draft!.emailSubject);
    final body = Uri.encodeComponent(draft!.emailBody);
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        onSent();
      } else {
        _showCopyFallback(context);
      }
    } catch (_) {
      _showCopyFallback(context);
    }
  }

  void _showCopyFallback(BuildContext context) {
    if (draft == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Email app nahi khul raha'),
        content: const Text(
          'Email content copy kar lein aur apne bank ki official email ID par bhejein.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: '${draft!.emailSubject}\n\n${draft!.emailBody}'),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email copied to clipboard')),
              );
              onSent();
            },
            child: const Text('Copy karein'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank ko email bhejein',
            style: theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Yeh email aapke bank ko chargeback ke liye bhejni hai.',
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),

          // Bank checklist
          _ChecklistCard(
            theme: theme,
            title: 'Bank ko yeh karna zaruri hai:',
            items: const [
              _ChecklistItem(
                icon: Icons.timer_outlined,
                text: '24 ghante me acknowledgment dena',
                sub: 'RBI ke niyam ke anusaar',
              ),
              _ChecklistItem(
                icon: Icons.lock_outline,
                text: 'Beneficiary account freeze karna',
                sub: 'Fraudster ke paise nikalne se rokna',
              ),
              _ChecklistItem(
                icon: Icons.calendar_month,
                text: '30 din me chargeback complete karna',
                sub: 'Ya reject karne ka reason likhit dena',
              ),
              _ChecklistItem(
                icon: Icons.receipt_long,
                text: 'Complaint reference number dena',
                sub: 'Track karne ke liye',
              ),
            ],
          ),

          const Spacer(),

          KavachButton(
            label: '📧  Email app kholein',
            variant: KavachButtonVariant.filled,
            onPressed: () => _openMail(context),
          ),
          const SizedBox(height: AppSpacing.s8),
          KavachButton(
            label: 'Email bhej diya',
            variant: KavachButtonVariant.tonal,
            onPressed: onNext,
          ),
          const SizedBox(height: AppSpacing.s8),
          KavachButton(
            label: 'Peechhe',
            variant: KavachButtonVariant.text,
            onPressed: onBack,
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }
}

class _ChecklistItem {
  const _ChecklistItem({
    required this.icon,
    required this.text,
    required this.sub,
  });
  final IconData icon;
  final String text;
  final String sub;
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.theme,
    required this.title,
    required this.items,
  });
  final ThemeData theme;
  final String title;
  final List<_ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l16),
      decoration: BoxDecoration(
        color: AppColors.safe.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.safe.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium!.copyWith(color: AppColors.safe),
          ),
          const SizedBox(height: AppSpacing.m12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 20, color: AppColors.safe),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        item.sub,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}