import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';

class Call1930Screen extends StatelessWidget {
  const Call1930Screen({
    super.key,
    required this.scriptTitle,
    required this.scriptBullets,
    required this.callLabel,
    required this.markDoneLabel,
    required this.onNext,
    required this.onBack,
  });

  final String scriptTitle;
  final List<String> scriptBullets;
  final String callLabel;
  final String markDoneLabel;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Future<void> _dial1930(BuildContext context) async {
    final uri = Uri.parse('tel:1930');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showFallback(context);
      }
    } catch (_) {
      _showFallback(context);
    }
  }

  void _showFallback(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('1930'),
        content:
        const Text('Dialer nahi khul raha. Kripya 1930 manually dial karein.'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: '1930'));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('1930 copied')),
              );
            },
            child: const Text('Number copy karein'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
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
          const SizedBox(height: AppSpacing.l16),
          Text(
            callLabel,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.m12),
          Text(
            'Abhi 1930 par call karein. Yeh National Cyber Crime Helpline hai — 24×7 active.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),
          Center(
            child: KavachButton(
              label: '📞  1930 Call karein',
              variant: KavachButtonVariant.filled,
              onPressed: () => _dial1930(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl32),
          ExpansionTile(
            title: Text(
              scriptTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            children: scriptBullets
                .map((b) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l16,
                vertical: AppSpacing.xs4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: theme.textTheme.bodyLarge),
                  Expanded(
                    child: Text(
                      b,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
          const Spacer(),
          KavachButton(
            label: markDoneLabel,
            variant: KavachButtonVariant.tonal,
            onPressed: onNext,
          ),
          const SizedBox(height: AppSpacing.s8),
          KavachButton(
            label: 'Baad me karta hoon',
            variant: KavachButtonVariant.text,
            onPressed: onNext,
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }
}