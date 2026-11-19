import 'package:digital_kavach/core/theme/theme_provider.dart';
import 'package:digital_kavach/data/firebase/user_repo.dart';
import 'package:digital_kavach/features/onboarding/onboarding_strings.dart';
import 'package:digital_kavach/features/onboarding/screens/signin_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/elder_mode.dart';
import '../../core/widgets/adaptive_layout.dart';
import '../../core/widgets/info_chip.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import '../scanner/scanner_screen.dart';
import '../sentinel/feed/feed_screen.dart';
import '../sentinel/queue_drainer.dart';
import '../settings/settings_screen.dart';
import 'home_strings.dart';

final StreamProvider<AppUser?> authUserStreamProvider =
StreamProvider<AppUser?>((Ref ref) {
  return ref.watch(authRepoProvider).authStateChanges();
});

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drainSentinel();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _drainSentinel();
    }
  }

  void _drainSentinel() {
    try {
      ref.read(queueDrainerProvider).drainAll();
    } catch (_) {}
  }

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
    final ElderModeConfig elder = ref.watch(elderModeProvider);

    final String greeting = _greetingForTime(DateTime.now(), h);
    final String? name = user?.displayName;
    final AppLocale currentLocale = ref.watch(localeProvider);
    final SupportedLanguage lang = SupportedLanguage.byCode(currentLocale.code);

    return KavachScaffold(
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          // Top Greeting Row with Language Switch Shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    greeting,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name?.isNotEmpty == true ? name! : l10n.strings.appName,
                    style: t.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/settings'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.translate_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        lang.nativeName,
                        style: t.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: t.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
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
              InkWell(
                onTap: () => context.push('/settings/health'),
                borderRadius: BorderRadius.circular(8),
                child: InfoChip(
                  label: 'Sentinel 24x7 Active',
                  icon: Icons.check_circle_rounded,
                  foreground: AppColors.safe,
                  background: AppColors.safe.withOpacity(0.1),
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

          const SizedBox(height: 20),

          // 🛡️ PRODUCTION SENTINEL ACTIVE BANNER
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  t.colorScheme.primaryContainer,
                  t.colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.rXl,
              border: Border.all(color: t.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: t.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        h.shieldActiveTitle,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: t.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        h.shieldActiveSubtitle,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ⚡ QUICK ACTION TILES (Text, Screenshot OCR, QR Verify)
          Row(
            children: <Widget>[
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.edit_note_rounded,
                  label: h.actionScanText,
                  color: AppColors.primary,
                  onTap: () => context.push('/scan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.photo_camera_back_rounded,
                  label: h.actionScanScreenshot,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/scan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  label: h.actionQrPay,
                  color: const Color(0xFF06B6D4),
                  onTap: () => context.push('/scan'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

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
                          h.recoveryCardTitle,
                          style: t.textTheme.titleMedium?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h.recoveryCardSubtitle,
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

          const SizedBox(height: 24),

          // 🚨 TRENDING CYBER THREATS INTEL CARDS (Live Modus Operandi)
          Text(
            h.recentScamsTitle,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _ThreatIntelTile(
            tag: 'DIGITAL ARREST',
            title: 'Fake CBI & Police Video Call Warrants',
            description: 'Fraudsters impersonate officers on Skype/WhatsApp claiming parcels contain narcotics.',
            tagColor: AppColors.danger,
          ),
          const SizedBox(height: 8),

          _ThreatIntelTile(
            tag: 'UTILITY SCAM',
            title: 'Nighttime Electricity Bill Cutoff',
            description: 'SMS threatening power disconnection at 9:30 PM with fake APK links or officer numbers.',
            tagColor: AppColors.warning,
          ),
          const SizedBox(height: 8),

          _ThreatIntelTile(
            tag: 'TASK FRAUD',
            title: 'YouTube Like & Maps Rating Scam',
            description: 'Part-time jobs promising ₹3,000 daily that redirect victims to high-loss Telegram groups.',
            tagColor: const Color(0xFF3B82F6),
          ),

          const SizedBox(height: 20),

          // Dev Rule Engine Tooling (Debug Mode only)
          if (kDebugMode) ...<Widget>[
            KavachButton(
              label: 'Dev · Threat Engine & Rules Harness',
              icon: Icons.science_rounded,
              variant: KavachButtonVariant.outlined,
              expand: true,
              onPressed: () => context.push(Routes.devAi),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rL,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppRadius.rL,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: t.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreatIntelTile extends StatelessWidget {
  const _ThreatIntelTile({
    required this.tag,
    required this.title,
    required this.description,
    required this.tagColor,
  });

  final String tag;
  final String title;
  final String description;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: AppRadius.rL,
        border: Border.all(color: t.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.shield_outlined, size: 16, color: t.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _greetingForTime(DateTime now, HomeStrings h) {
  final int hour = now.hour;
  if (hour < 12) return h.goodMorning;
  if (hour < 17) return h.goodAfternoon;
  return h.goodEvening;
}