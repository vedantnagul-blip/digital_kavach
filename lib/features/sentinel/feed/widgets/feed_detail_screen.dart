import 'package:digital_kavach/core/theme/app_colors.dart';
import 'package:digital_kavach/core/widgets/kavach_button.dart';
import 'package:digital_kavach/features/sentinel/feed/feed_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_spacing.dart';


class FeedDetailScreen extends ConsumerWidget {
  const FeedDetailScreen({super.key, required this.entry});
  final FeedEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isRed = entry.level == 'RED';

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Detail')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l16),
            decoration: BoxDecoration(
              color: isRed
                  ? AppColors.dangerContainer
                  : AppColors.warningContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isRed ? Icons.gpp_bad_rounded : Icons.gpp_maybe_rounded,
                  color: isRed ? AppColors.danger : AppColors.warning,
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRed ? 'Khatarnak Scam' : 'Shakaspad Sandesh',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isRed ? AppColors.danger : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Risk Score: ${entry.score} / 100',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),
          _detailRow(theme, 'Pattern Family', entry.pattern),
          _detailRow(theme, 'Source', entry.source),
          _detailRow(theme, 'Detection Provider', entry.provider),
          _detailRow(
            theme,
            'Time Logged',
            '${entry.ts.day}/${entry.ts.month}/${entry.ts.year} ${entry.ts.hour}:${entry.ts.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: AppSpacing.xxl24),
          const Divider(),
          const SizedBox(height: AppSpacing.l16),
          if (isRed) ...[
            KavachButton(
              label: '1930 Helpline Call Karein',
              variant: KavachButtonVariant.filled,
              icon: Icons.phone_in_talk,
              onPressed: () => launchUrl(Uri.parse('tel:1930')),
            ),
            const SizedBox(height: AppSpacing.m12),
          ],
          KavachButton(
            label: entry.isMuted ? 'Unmute Sender' : 'Sender ko 24h Mute karein',
            variant: KavachButtonVariant.outlined,
            icon: entry.isMuted ? Icons.volume_up : Icons.volume_off,
            onPressed: () {
              ref.read(feedControllerProvider.notifier).toggleMute(entry.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}