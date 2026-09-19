import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

/// Family Shield section in Settings.
class FamilySection extends ConsumerWidget {
  const FamilySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family Shield', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.s8),
        ListTile(
          leading: const Icon(Icons.family_restroom),
          title: const Text('Family members manage karein'),
          subtitle: const Text('Pairing, alerts, digest'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/family'),
        ),
        const Divider(),
      ],
    );
  }
}