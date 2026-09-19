import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/local/hive_boxes.dart';
import 'sections/family_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final elder = ref.watch(elderModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l16),
        children: [
          // Mode Section
          Text('Appearance & Accessibility', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          SwitchListTile(
            title: const Text('Elder Mode'),
            subtitle: const Text('Bade akshar aur bade buttons'),
            value: elder.enabled,
            onChanged: (v) =>
                ref.read(elderModeProvider.notifier).setEnabled(v),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (v) {
              ref.read(themeModeProvider.notifier).state =
              v ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),

          // Family Shield Section
          const FamilySection(),

          // Sentinel & Health
          Text('Protection & Sentinel', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Sentinel Health Center'),
            subtitle: const Text('Uptime, gap logs, OEM settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/health'),
          ),
          const Divider(),

          // Privacy & Cache
          Text('Privacy & Data', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Local Cache'),
            subtitle: const Text('Delete offline scan cache'),
            onTap: () async {
              await HiveBoxes.openAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local cache cleared')),
                );
              }
            },
          ),

          const Divider(),

          // About & Hidden Dev triggers
          Text('About Digital Kavach', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Production Build)'),
            onLongPress: () => context.push('/dev/ai'),
          ),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: const Text('Open Source Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('🧪 Feature Test Console'),
            subtitle: const Text('Run diagnostic tests for all phases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/dev/tests'),
          ),
        ],
      ),
    );
  }
}