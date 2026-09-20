import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/local/user_prefs.dart';
import 'sections/family_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _devTapCount = 0;
  bool _devUnlocked = false;

  void _onVersionTap() {
    setState(() {
      _devTapCount++;
      if (_devTapCount >= 7) {
        if (!_devUnlocked) {
          _devUnlocked = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Developer Options Unlocked! Developer Hub is now visible below.'),
              backgroundColor: AppColors.safe,
            ),
          );
        }
      } else if (_devTapCount >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are ${7 - _devTapCount} steps away from Developer Options.'),
            duration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.translate_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Select Language / भाषा चुनें',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: AppLocale.values.length,
                    itemBuilder: (context, i) {
                      final loc = AppLocale.values[i];
                      final isSelected = loc == currentLocale;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Text(
                            loc.code.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(loc.nativeName),
                        subtitle: Text(loc.code),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary)
                            : null,
                        onTap: () async {
                          ref.read(localeProvider.notifier).state = loc;
                          await ref.read(userPrefsProvider).setLangCode(loc.code);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final elder = ref.watch(elderModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Navigation Hub')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l16),
        children: [
          // Appearance & Accessibility
          Text('Appearance & Accessibility', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: const Text('App Language / भाषा'),
            subtitle: Text(locale.nativeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, ref),
          ),
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

          // Protection & Sentinel
          Text('Protection & Sentinel', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Sentinel Health Center'),
            subtitle: const Text('Uptime, gap logs, OEM battery settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/health'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Activity Feed'),
            subtitle: const Text('Live alert log and scan history'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/feed'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner_rounded),
            title: const Text('Scanner Hub'),
            subtitle: const Text('Text, screenshot OCR, and QR scanner'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/scan'),
          ),
          const Divider(),

          // Emergency & Recovery
          Text('Emergency Recovery', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.emergency_rounded, color: AppColors.danger),
            title: const Text('Golden Hour Recovery Copilot'),
            subtitle: const Text('1930 helpline, bank complaint, FIR generator'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/recovery'),
          ),
          const Divider(),

          // Developer & Diagnostics Hub (Hidden by default; unlock with 7 taps on App Version)
          if (_devUnlocked) ...[
            Text('Developer & Diagnostic Hub', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s8),
            ListTile(
              leading: const Icon(Icons.psychology_rounded, color: AppColors.primary),
              title: const Text('🤖 Agentic AI & Threat Engine'),
              subtitle: const Text('Test hybrid scam detection & offline threat memory'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/dev/ai'),
            ),
            ListTile(
              leading: const Icon(Icons.bolt_rounded, color: AppColors.warning),
              title: const Text('⚡ Offline Rule Engine Harness'),
              subtitle: const Text('Test 107 scam patterns offline with 5ms latency'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/dev/rules'),
            ),
            ListTile(
              leading: const Icon(Icons.science_outlined, color: Colors.purple),
              title: const Text('🧪 9-Phase Feature Test Console'),
              subtitle: const Text('Run built-in test suites for all 9 phases'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/dev/tests'),
            ),
            const Divider(),
          ],

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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(_devUnlocked ? '1.0.0 (Developer Mode Active ✓)' : '1.0.0 (Production Build)'),
            trailing: _devUnlocked
                ? const Icon(Icons.code_rounded, color: AppColors.safe, size: 20)
                : null,
            onTap: _onVersionTap,
          ),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: const Text('Open Source Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
