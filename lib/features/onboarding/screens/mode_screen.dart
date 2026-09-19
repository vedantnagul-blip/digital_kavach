import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../onboarding_controller.dart';
import '../onboarding_strings.dart';
import '../widgets/mode_preview_card.dart';
import '../widgets/step_progress_bar.dart';

class ModeScreen extends ConsumerWidget {
  const ModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingStrings s = ref.watch(onboardingStringsProvider);
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController ctrl =
    ref.read(onboardingControllerProvider.notifier);
    final ThemeData t = Theme.of(context);

    return KavachScaffold(
      title: Text(s.modeTitle),
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
          Text(s.modeSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: 20),
          ModePreviewCard(
            title: s.modeStandardTitle,
            bullets: s.modeStandardBullets,
            previewText: s.modePreviewSample,
            textScale: 1.0,
            buttonHeight: 44,
            selected: state.modeCode == 'standard',
            onTap: () => ctrl.setMode('standard'),
          ),
          const SizedBox(height: 12),
          ModePreviewCard(
            title: s.modeElderTitle,
            bullets: s.modeElderBullets,
            previewText: s.modePreviewSample,
            textScale: 1.4,
            buttonHeight: 60,
            selected: state.modeCode == 'elder',
            onTap: () => ctrl.setMode('elder'),
          ),
          const SizedBox(height: 24),
          if (state.modeCode != null)
            KavachButton(
              label: s.next,
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: () => ctrl.setMode(state.modeCode!),
            ),
        ],
      ),
    );
  }
}