import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/errors/kavach_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/firebase/auth_repo.dart';
import '../../../data/firebase/user_repo.dart';
import '../onboarding_controller.dart';
import '../onboarding_strings.dart';
import '../widgets/consent_checklist.dart';
import '../widgets/step_progress_bar.dart';
import 'signin_screen.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});
  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _saving = false;
  KavachException? _error;

  Future<void> _choose(bool allow) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final AuthRepo auth = ref.read(authRepoProvider);
      final UserRepo users = ref.read(userRepoProvider);
      final AppUser? user = auth.currentUser;
      if (user == null) {
        throw const AuthException('No signed-in user at consent step');
      }
      final PackageInfo info = await PackageInfo.fromPlatform();
      final OnboardingState state = ref.read(onboardingControllerProvider);
      await users.ensureUserDoc(
        user: user,
        lang: state.langCode ?? 'en',
        mode: state.modeCode ?? 'standard',
        consentAi: allow,
        consentTs: DateTime.now(),
        consentVersion: kConsentVersion,
        appVersion: info.version,
      );
      await ref
          .read(onboardingControllerProvider.notifier)
          .setConsent(allow: allow);
    } on KavachException catch (e) {
      if (mounted) setState(() => _error = e);
    } catch (e, st) {
      AppLogger.e('Consent write failed', error: e, stackTrace: st);
      if (mounted) setState(() => _error = UnknownException(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingStrings s = ref.watch(onboardingStringsProvider);
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
        ref.read(onboardingControllerProvider.notifier);
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);

    if (_saving) {
      return KavachScaffold(
        title: Text(l10n.strings.appName),
        body: const LoadingView(),
      );
    }
    if (_error != null) {
      return KavachScaffold(
        title: Text(l10n.strings.appName),
        leading: ctrl.canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: ctrl.back,
              )
            : null,
        scrollable: true,
        body: ErrorStateView(
          error: _error!,
          onRetry: () => setState(() => _error = null),
        ),
      );
    }

    return KavachScaffold(
      title: Text(l10n.strings.appName),
      leading: ctrl.canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: ctrl.back,
            )
          : null,
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StepProgressBar(step: state.step),
          const SizedBox(height: 20),
          Text(s.consentTitle, style: t.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(s.consentSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: 18),
          ConsentChecklistItem(
            icon: Icons.notifications_active_rounded,
            title: s.consentReadTitle,
            body: s.consentReadBody,
          ),
          ConsentChecklistItem(
            icon: Icons.smartphone_rounded,
            title: s.consentLocalTitle,
            body: s.consentLocalBody,
          ),
          ConsentChecklistItem(
            icon: Icons.cloud_upload_rounded,
            title: s.consentLeavesTitle,
            body: s.consentLeavesBody,
            emphasize: true,
          ),
          ConsentChecklistItem(
            icon: Icons.fingerprint_rounded,
            title: s.consentStorageTitle,
            body: s.consentStorageBody,
          ),
          const SizedBox(height: 14),
          KavachButton(
            label: s.consentAllow,
            icon: Icons.verified_rounded,
            expand: true,
            onPressed: () => _choose(true),
          ),
          const SizedBox(height: 10),
          KavachButton(
            label: s.consentOfflineOnly,
            variant: KavachButtonVariant.outlined,
            expand: true,
            onPressed: () => _choose(false),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              s.consentFooter,
              style: t.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
