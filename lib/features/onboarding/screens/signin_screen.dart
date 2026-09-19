import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/kavach_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../../../data/firebase/auth_repo.dart';
import '../../../data/firebase/user_repo.dart';
import '../onboarding_controller.dart';
import '../onboarding_strings.dart';
import '../widgets/step_progress_bar.dart';

final Provider<AuthRepo> authRepoProvider =
Provider<AuthRepo>((Ref<AuthRepo> ref) => AuthRepo());

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loadingGoogle = false;
  bool _loadingGuest = false;
  KavachException? _error;
  String? _infoMessage;

  Future<void> _signInGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      final AppUser? user = await ref.read(authRepoProvider).signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        setState(() =>
        _infoMessage = ref.read(onboardingStringsProvider).signInCancelled);
        return;
      }
      await ref
          .read(onboardingControllerProvider.notifier)
          .markSignedIn(user: user);
    } on KavachException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  Future<void> _signInGuest() async {
    setState(() {
      _loadingGuest = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      final AppUser user = await ref.read(authRepoProvider).signInGuest();
      if (!mounted) return;
      await ref
          .read(onboardingControllerProvider.notifier)
          .markSignedIn(user: user);
    } on KavachException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loadingGuest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingStrings s = ref.watch(onboardingStringsProvider);
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);

    if (_error != null) {
      return KavachScaffold(
        title: Text(l10n.strings.appName),
        body: ErrorStateView(
          error: _error!,
          onRetry: () => setState(() => _error = null),
        ),
      );
    }

    return KavachScaffold(
      title: Text(l10n.strings.appName),
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StepProgressBar(step: state.step),
          const SizedBox(height: 32),
          Icon(Icons.verified_user_rounded,
              size: 56, color: t.colorScheme.primary),
          const SizedBox(height: 16),
          Text(s.signInTitle, style: t.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(s.signInSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: 32),
          KavachButton(
            label: s.signInGoogle,
            icon: Icons.g_mobiledata_rounded,
            loading: _loadingGoogle,
            expand: true,
            onPressed: _loadingGuest ? null : _signInGoogle,
          ),
          const SizedBox(height: 12),
          KavachButton(
            label: s.signInGuest,
            variant: KavachButtonVariant.outlined,
            loading: _loadingGuest,
            expand: true,
            onPressed: _loadingGoogle ? null : _signInGuest,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.rM,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline_rounded,
                    size: 18, color: t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.signInGuestNote,
                      style: t.textTheme.bodySmall),
                ),
              ],
            ),
          ),
          if (_infoMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _infoMessage!,
              style: t.textTheme.bodyMedium
                  ?.copyWith(color: t.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}