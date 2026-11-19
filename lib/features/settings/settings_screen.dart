import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/elder_mode.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/local/user_prefs.dart';
import 'sections/family_section.dart';
import 'settings_strings.dart';
import '../scanner/local_gemma_test_screen.dart';
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

  void _showLanguagePicker(BuildContext context) {
    final currentLocale = ref.read(localeProvider);
    final s = ref.read(settingsStringsProvider);
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
                        '${s.selectLanguage} / भाषा चुनें',
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elder = ref.watch(elderModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final s = ref.watch(settingsStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.appBarTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l16),
        children: [
          // Appearance & Accessibility
          Text(s.sectionAppearance, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: Text('${s.appLanguage} / भाषा'),
            subtitle: Text(locale.nativeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context),
          ),
          SwitchListTile(
            title: Text(s.elderMode),
            subtitle: Text(s.elderModeSubtitle),
            value: elder.enabled,
            onChanged: (v) =>
                ref.read(elderModeProvider.notifier).setEnabled(v),
          ),
          SwitchListTile(
            title: Text(s.darkMode),
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
          Text(s.sectionProtection, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: Text(s.sentinelHealth),
            subtitle: Text(s.sentinelHealthSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/health'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(s.activityFeed),
            subtitle: Text(s.activityFeedSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/feed'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner_rounded),
            title: Text(s.scannerHub),
            subtitle: Text(s.scannerHubSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/scan'),
          ),
          const Divider(),

          // Emergency & Recovery
          Text(s.sectionEmergency, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.emergency_rounded, color: AppColors.danger),
            title: Text(s.recoveryCopilot),
            subtitle: Text(s.recoveryCopilotSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/recovery'),
          ),
          const Divider(),

          // Developer & Diagnostics Hub (Hidden by default; unlock with 7 taps on App Version)
          if (_devUnlocked) ...[
            Text('Developer & Diagnostic Hub', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const LocalGemmaTestScreen(),
                  ),
                );
              },
              child: const Text('Open Gemma Test'),
            ),

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
          Text(s.sectionPrivacy, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded),
            title: Text(s.clearCache),
            subtitle: Text(s.clearCacheSubtitle),
            onTap: () async {
              if (Hive.isBoxOpen(HiveBoxes.cache)) {
                await Hive.box<dynamic>(HiveBoxes.cache).clear();
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.cacheCleared),
                    backgroundColor: AppColors.safe,
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(s.appVersion),
            subtitle: Text(_devUnlocked ? '1.0.0 (Developer Mode Active ✓)' : s.appVersionSubtitle),
            trailing: _devUnlocked
                ? const Icon(Icons.code_rounded, color: AppColors.safe, size: 20)
                : null,
            onTap: _onVersionTap,
          ),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: Text(s.licenses),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}