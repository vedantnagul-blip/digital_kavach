import 'package:digital_kavach/data/firebase/user_repo.dart';
import 'package:digital_kavach/features/onboarding/onboarding_strings.dart';
import 'package:digital_kavach/features/onboarding/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/elder_mode.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/adaptive_layout.dart';
import '../../core/widgets/info_chip.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import '../../data/local/user_prefs.dart';
import '../onboarding/onboarding_controller.dart';
import '../scanner/scanner_screen.dart';
import '../sentinel/feed/feed_screen.dart';
import '../settings/settings_screen.dart';
import 'home_strings.dart';

/// Streaming provider for the currently-authenticated user (or null).
final StreamProvider<AppUser?> authUserStreamProvider =
StreamProvider<AppUser?>((Ref ref) {
  return ref.watch(authRepoProvider).authStateChanges();
});

/// Root of the post-onboarding app: bottom nav (compact) or rail (expanded).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      builder: (BuildContext context, Breakpoint bp) {
        if (bp.isExpanded) {
          return _RailShell(
            currentTab: _tab,
            onTabChanged: (int i) => setState(() => _tab = i),
          );
        }
        return _BottomNavShell(
          currentTab: _tab,
          onTabChanged: (int i) => setState(() => _tab = i),
        );
      },
    );
  }
}

class _BottomNavShell extends ConsumerWidget {
  const _BottomNavShell({
    required this.currentTab,
    required this.onTabChanged,
  });
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeStrings h = ref.watch(homeStringsProvider);
    final ThemeData t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: _TabBody(index: currentTab),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab == 2 ? 1 : (currentTab == 3 ? 2 : currentTab),
        onDestinationSelected: (int i) {
          // Map slots [0,1,2] to [Home=0, Feed=2, Settings=3] (scan is center FAB)
          switch (i) {
            case 0:
              onTabChanged(0);
              break;
            case 1:
              onTabChanged(2);
              break;
            case 2:
              onTabChanged(3);
              break;
          }
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: h.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article_rounded),
            label: h.navFeed,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: h.navSettings,
          ),
        ],
      ),
      floatingActionButton: _CenterScanFab(onTap: () => onTabChanged(1)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _RailShell extends ConsumerWidget {
  const _RailShell({required this.currentTab, required this.onTabChanged});
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeStrings h = ref.watch(homeStringsProvider);
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: currentTab.clamp(0, 3),
            onDestinationSelected: onTabChanged,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: Text(h.navHome),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(Icons.qr_code_scanner_rounded),
                label: Text('Scan'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.article_outlined),
                selectedIcon: const Icon(Icons.article_rounded),
                label: Text(h.navFeed),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: Text(h.navSettings),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _TabBody(index: currentTab)),
        ],
      ),
    );
  }
}

class _CenterScanFab extends ConsumerWidget {
  const _CenterScanFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeStrings h = ref.watch(homeStringsProvider);
    return FloatingActionButton.large(
      tooltip: h.centralScanTooltip,
      onPressed: onTap,
      shape: const CircleBorder(),
      child: const Icon(Icons.qr_code_scanner_rounded, size: 32),
    );
  }
}

class _TabBody extends ConsumerWidget {
  const _TabBody({required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (index) {
      case 0:
        return const _HomeTab();
      case 1:
        return const ScannerScreen();
      case 2:
        return const FeedScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const _HomeTab();
    }
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);
    final HomeStrings h = ref.watch(homeStringsProvider);
    final AsyncValue<AppUser?> userAsync = ref.watch(authUserStreamProvider);
    final AppUser? user = userAsync.valueOrNull;
    final UserPrefs prefs = ref.read(userPrefsProvider);
    final ElderModeConfig elder = ref.watch(elderModeProvider);

    final String greeting = _greetingForTime(DateTime.now(), h);
    final String? name = user?.displayName;
    final String langCode = prefs.langCode ?? 'en';
    final SupportedLanguage lang = SupportedLanguage.byCode(langCode);

    return KavachScaffold(
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24),
          Text(
            greeting,
            style: t.textTheme.bodyLarge?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name?.isNotEmpty == true ? name! : l10n.strings.appName,
            style: t.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              InfoChip(
                label: '${h.langBadgePrefix} · ${lang.nativeName}',
                icon: Icons.language_rounded,
              ),
              InfoChip(
                label: elder.enabled ? h.elderBadge : h.standardBadge,
                icon: elder.enabled
                    ? Icons.accessibility_new_rounded
                    : Icons.person_rounded,
              ),
              InkWell(
                onTap: () => context.push('/family'),
                borderRadius: BorderRadius.circular(8),
                child: InfoChip(
                  label: 'Family Shield',
                  icon: Icons.family_restroom,
                  foreground: AppColors.primary,
                  background: AppColors.primary.withOpacity(0.1),
                ),
              ),
              if (user?.isGuest ?? false)
                InfoChip(
                  label: h.guestBadge,
                  icon: Icons.person_outline_rounded,
                  foreground: AppColors.warning,
                  background: AppColors.warningContainer,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // App Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer,
              borderRadius: AppRadius.rXl,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.shield_rounded,
                  color: t.colorScheme.primary,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.strings.appName,
                          style: t.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(l10n.strings.tagline,
                          style: t.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🆘 GOLDEN HOUR RECOVERY ACTION CARD (Phase 08)
          InkWell(
            onTap: () => context.push('/recovery'),
            borderRadius: AppRadius.rXl,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dangerContainer,
                borderRadius: AppRadius.rXl,
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'धोखा हुआ? रिकवरी शुरू करें',
                          style: t.textTheme.titleMedium?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1930 कॉल, बैंक शिकायत व FIR ड्राफ्ट',
                          style: t.textTheme.bodySmall?.copyWith(
                            color: AppColors.danger.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.danger,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dev Rule Engine Tooling
          KavachButton(
            label: 'Dev · Rule Engine',
            icon: Icons.science_rounded,
            variant: KavachButtonVariant.outlined,
            expand: true,
            onPressed: () => context.push(Routes.devAi),
          ),
        ],
      ),
    );
  }

  String _greetingForTime(DateTime now, HomeStrings h) {
    final int hour = now.hour;
    if (hour < 12) return h.goodMorning;
    if (hour < 17) return h.goodAfternoon;
    return h.goodEvening;
  }
}