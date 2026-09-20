import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workmanager/workmanager.dart';

import 'background/ai_scan_worker.dart';
import 'core/errors/kavach_exception.dart';
import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/elder_mode.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/app_logger.dart';
import 'data/firebase/user_repo.dart';
import 'data/local/hive_boxes.dart';
import 'features/onboarding/screens/consent_screen.dart';
import 'features/scanner/share_intake.dart'; // Phase 05 Share Sheet listener

void main() {
  runZonedGuarded(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. Global Flutter error boundary → Crashlytics
      final FlutterExceptionHandler? previousOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        previousOnError?.call(details);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // 3. Initialize Hive
      try {
        await HiveBoxes.openAll();
      } on StorageException catch (e) {
        AppLogger.w('Hive init failed, running with in-memory fallback: $e');
      }

      // 4. Initialize WorkManager for background tasks
      try {
        await Workmanager().initialize(
          aiScanWorkerDispatcher,
          isInDebugMode: kDebugMode,
        );
        AppLogger.i('WorkManager initialized');
      } catch (e) {
        AppLogger.w('WorkManager init warning: $e');
      }

      AppLogger.i('Phase 05 bootstrap complete');

      runApp(
        ProviderScope(
          overrides: <Override>[
            userRepoProvider.overrideWithValue(
              UserRepo(FirebaseFirestore.instance),
            ),
          ],
          child: const DigitalKavachApp(),
        ),
      );
    },
        (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class DigitalKavachApp extends ConsumerWidget {
  const DigitalKavachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode mode = ref.watch(themeModeProvider);
    final ElderModeConfig elder = ref.watch(elderModeProvider);
    final AppLocale locale = ref.watch(localeProvider);

    return ShareIntakeListener(
      child: MaterialApp.router(
        title: 'Digital Kavach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        locale: locale.toLocale(),
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('hi'),
          Locale('mr'),
          Locale('ta'),
          Locale('te'),
          Locale('bn'),
          Locale('gu'),
          Locale('kn'),
          Locale('ml'),
          Locale('pa'),
        ],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
        builder: (BuildContext context, Widget? child) {
          return ElderModeScope(
            config: elder,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}