import 'package:digital_kavach/features/dev/feature_test_console.dart';
import 'package:digital_kavach/features/sentinel/feed/feed_screen.dart';
import 'package:digital_kavach/features/sentinel/health/health_center_screen.dart';
import 'package:digital_kavach/features/settings/dev/ai_panel_screen.dart';
import 'package:digital_kavach/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/ai/ai_router.dart';
import '../../data/local/user_prefs.dart';
import '../../features/family/family_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/onboarding/onboarding_controller.dart';
import '../../features/onboarding/onboarding_host.dart';
import '../../features/recovery/recovery_screen.dart';
import '../../features/scanner/dev_harness_screen.dart';
import '../../features/scanner/models/qr_payload.dart';
import '../../features/scanner/scan_result_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../l10n/l10n.dart';
import '../theme/theme_provider.dart';
import '../widgets/kavach_scaffold.dart';
import '../widgets/loading_view.dart';

class Routes {
  const Routes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String scanResult = '/scan/result';
  static const String qrResult = '/qr-result';
  static const String feed = '/feed';
  static const String recovery = '/recovery';
  static const String family = '/family';
  static const String settings = '/settings';
  static const String settingsHealth = '/settings/health';
  static const String devAi = '/dev/ai';
  static const String devRules = '/dev/rules';
  static const String devTests = '/dev/tests';

}

/// Notifies the router when session-critical state changes:
/// - onboarding completion flag
/// - onboarding-step transitions (during flow)
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen<bool>(onboardedProvider, (_, __) => notifyListeners());
    _ref.listen<OnboardingState>(
      onboardingControllerProvider,
          (_, __) => notifyListeners(),
    );
  }
  final Ref _ref;
}

final Provider<GoRouter> appRouterProvider =
Provider<GoRouter>((Ref<GoRouter> ref) {
  // Hydrate onboardedProvider from persisted UserPrefs on first read.
  final UserPrefs prefs = ref.read(userPrefsProvider);
  Future<void>.microtask(() {
    ref.read(onboardedProvider.notifier).state = prefs.isOnboarded;
  });

  final _RouterRefreshNotifier refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final bool onboarded = ref.read(onboardedProvider);
      final String loc = state.matchedLocation;

      final bool onSplash = loc == Routes.splash;
      final bool onOnboarding = loc.startsWith(Routes.onboarding);

      if (onSplash) return onboarded ? Routes.home : Routes.onboarding;
      if (!onboarded && !onOnboarding) return Routes.onboarding;
      if (onboarded && onOnboarding) return Routes.home;
      return null;
    },
    routes: <RouteBase>[
      // Core Routes
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingHost(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, __) => const HomeShell(),
      ),

      // Manual Scanner & Verdict Screens
      GoRoute(
        path: Routes.scan,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic>? extra =
          state.extra as Map<String, dynamic>?;
          return ScannerScreen(
            initialText: extra?['sharedText'] as String?,
            initialImagePath: extra?['sharedImagePath'] as String?,
          );
        },
      ),
      GoRoute(
        path: Routes.scanResult,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic> extra =
          state.extra as Map<String, dynamic>;
          return ScanResultScreen(
            scanResult: extra['result'] as HybridScanResult,
            inputText: extra['inputText'] as String?,
            imagePath: extra['imagePath'] as String?,
            qrPayload: extra['qrPayload'] as UpiQrPayload?,
          );
        },
      ),
      GoRoute(
        path: Routes.qrResult,
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic>? extra =
          state.extra as Map<String, dynamic>?;
          if (extra != null && extra.containsKey('result')) {
            return ScanResultScreen(
              scanResult: extra['result'] as HybridScanResult,
              qrPayload: extra['qrPayload'] as UpiQrPayload?,
            );
          }
          return const ScannerScreen();
        },
      ),

      // Activity Feed (Real-time Sentinel & Scan logs)
      GoRoute(
        path: Routes.feed,
        builder: (_, __) => const FeedScreen(),
      ),

      // Golden Hour Recovery Copilot (Phase 08)
      GoRoute(
        path: Routes.recovery,
        builder: (_, __) => const RecoveryScreen(),
      ),

      // Family Shield (Phase 09)
      GoRoute(
        path: Routes.family,
        builder: (_, __) => const FamilyScreen(),
      ),

      // Settings & Sentinel Health Center (Phase 07)
      GoRoute(
        path: Routes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.settingsHealth,
        builder: (_, __) => const HealthCenterScreen(),
      ),

      // Developer Tools & Testing Panels (Phase 03 & 04)
      GoRoute(
        path: Routes.devAi,
        builder: (_, __) => const AiPanelScreen(),
      ),
      GoRoute(
        path: Routes.devRules,
        builder: (_, __) => const DevRulesHarnessScreen(),
      ),
      GoRoute(
        path: '/dev/tests',
        builder: (_, __) => const FeatureTestConsole(),
      ),
    ],
  );
});

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = ref.watch(l10nProvider);
    return KavachScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.shield_rounded,
              size: 72,
              color: Color(0xFFE85D04),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.strings.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const LoadingView(),
          ],
        ),
      ),
    );
  }
}