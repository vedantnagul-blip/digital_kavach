import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/kavach_button.dart';
import 'copilot_controller.dart';
import 'recovery_strings.dart';
import 'screens/bank_screen.dart';
import 'screens/calm_screen.dart';
import 'screens/call_1930_screen.dart';
import 'screens/complaint_viewer_screen.dart';
import 'screens/done_screen.dart';
import 'screens/evidence_screen.dart';
import 'screens/questions_screen.dart';
import 'widgets/step_checklist.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  bool _isRegenerating = false;

  Future<bool> _confirmExit(RecoveryStrings s) async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.wizardTitle, style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.m12),
            Text(
              s.calmSubtitle,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l16),
            KavachButton(
              label: s.backStep,
              variant: KavachButtonVariant.outlined,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            const SizedBox(height: AppSpacing.s8),
            KavachButton(
              label: s.nextStep,
              variant: KavachButtonVariant.filled,
              onPressed: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(copilotControllerProvider);
    final controller = ref.read(copilotControllerProvider.notifier);
    final RecoveryStrings s = ref.watch(recoveryStringsProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.wizardTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_rounded, size: 64),
                const SizedBox(height: AppSpacing.l16),
                Text(
                  s.wizardTitle,
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m12),
                Text(
                  s.calmSubtitle,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl20),
                KavachButton(
                  label: s.nextStep,
                  variant: KavachButtonVariant.filled,
                  onPressed: () => controller.startNew(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (session.step == RecoveryStep.done) {
          if (mounted) Navigator.of(context).pop();
          return;
        }
        final exit = await _confirmExit(s);
        if (exit && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${s.wizardTitle} (${session.step.position}/${RecoveryStep.totalSteps})'),
          leading: session.step.canGoBack
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.previousStep(),
          )
              : IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final exit = await _confirmExit(s);
              if (exit && mounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            StepChecklist(currentStep: session.step),
            Expanded(child: _buildStep(session, controller, s)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(RecoverySession session, CopilotController controller, RecoveryStrings s) {
    switch (session.step) {
      case RecoveryStep.calm:
        return CalmScreen(
          deadline: session.deadline,
          countdownExplainer: s.calmSubtitle,
          calmTitle: s.calmTitle,
          calmBody: s.calmSubtitle,
          onNext: () => controller.nextStep(),
        );

      case RecoveryStep.call1930:
        return Call1930Screen(
          scriptTitle: s.call1930Title,
          scriptBullets: [
            s.call1930Subtitle,
            s.callButton,
          ],
          callLabel: s.callButton,
          markDoneLabel: s.nextStep,
          onNext: () => controller.nextStep(),
          onBack: () => controller.previousStep(),
        );

      case RecoveryStep.questions:
        return QuestionsScreen(
          session: session,
          onUpdateAnswers: controller.updateAnswers,
          onNext: () => controller.nextStep(),
          onBack: () => controller.previousStep(),
          questionLabels: const [
            'Date & Time / तारीख और समय',
            'Amount & App / राशि और ऐप',
            'To Whom / प्राप्तकर्ता',
            'Description / विवरण',
            'UTR / Transaction ID',
          ],
          questionHints: const [
            'Select incident date and time',
            'Enter loss amount and payment method',
            'Recipient UPI ID, account number or phone',
            'Describe how the fraud took place',
            '12-digit bank UTR reference number',
          ],
        );

      case RecoveryStep.complaint:
        return ComplaintViewerScreen(
          draft: session.draft,
          onUpdateDraft: controller.updateDraft,
          onRegenerate: () async {
            setState(() => _isRegenerating = true);
            await controller.regenerateDraft();
            if (mounted) setState(() => _isRegenerating = false);
          },
          onNext: () => controller.nextStep(),
          onBack: () => controller.previousStep(),
          isRegenerating: _isRegenerating,
        );

      case RecoveryStep.bank:
        return BankScreen(
          draft: session.draft,
          onSent: () {},
          onNext: () => controller.nextStep(),
          onBack: () => controller.previousStep(),
        );

      case RecoveryStep.evidence:
        return EvidenceScreen(
          session: session,
          onToggle: controller.toggleEvidence,
          onNext: () => controller.nextStep(),
          onBack: () => controller.previousStep(),
        );

      case RecoveryStep.done:
        return DoneScreen(
          session: session,
          onMarkFiled: controller.markFiled,
          onMarkResolved: controller.markResolved,
          onUndoStatus: controller.undoStatus,
          onClose: () {
            controller.clearCompleted();
            if (mounted) Navigator.of(context).pop();
          },
        );
    }
  }
}