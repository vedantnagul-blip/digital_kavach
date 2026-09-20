import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../onboarding_controller.dart';
import '../onboarding_strings.dart';
import '../widgets/language_tile.dart';
import '../widgets/step_progress_bar.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingStrings s = ref.watch(onboardingStringsProvider);
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
        ref.read(onboardingControllerProvider.notifier);
    final ThemeData t = Theme.of(context);
    final L10n l10n = ref.watch(l10nProvider);

    return KavachScaffold(
      title: Text(l10n.strings.appName),
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StepProgressBar(step: state.step),
          const SizedBox(height: 20),
          Text(s.langTitle, style: t.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(s.langSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: SupportedLanguage.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 68,
            ),
            itemBuilder: (BuildContext context, int i) {
              final SupportedLanguage lang = SupportedLanguage.all[i];
              return LanguageTile(
                language: lang,
                selected: state.langCode == lang.code,
                onTap: () => ctrl.setLanguage(lang.code),
              );
            },
          ),
          const SizedBox(height: 16),
          if (state.langCode != null &&
              !SupportedLanguage.byCode(state.langCode!).hasFullUiSupport)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: t.colorScheme.warningLikeContainer,
                borderRadius: AppRadius.rM,
                border: Border.all(color: t.colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline_rounded,
                      size: 20, color: t.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.langComingSoonNote,
                        style: t.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          if (state.langCode != null) ...<Widget>[
            const SizedBox(height: 8),
            KavachButton(
              label: s.next,
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: () => ctrl.setLanguage(state.langCode!),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

extension _WarnColor on ColorScheme {
  Color get warningLikeContainer => surfaceContainerHighest;
}
