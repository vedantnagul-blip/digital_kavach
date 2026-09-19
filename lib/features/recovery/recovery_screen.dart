import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/kavach_button.dart';
import 'copilot_controller.dart';
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

  Future<bool> _confirmExit() async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Wizard chhod dein?', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.m12),
            Text(
              'Aapki progress save hai — jab wapas aayenge yahin se shuru hoga.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l16),
            KavachButton(
              label: 'Haan, chhod dein',
              variant: KavachButtonVariant.outlined,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            const SizedBox(height: AppSpacing.s8),
            KavachButton(
              label: 'Nahi, jaari rakhein',
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

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recovery Copilot')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, size: 64),
                const SizedBox(height: AppSpacing.l16),
                Text(
                  'Golden Hour Recovery Copilot',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m12),
                Text(
                  'Agar aap fraud ke shikaar hue hain, hum aapki madad karenge — 7 aasan kadam.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl20),
                KavachButton(
                  label: 'Shuru karein',
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
        final exit = await _confirmExit();
        if (exit && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Step ${session.step.position}/${RecoveryStep.totalSteps}'),
          leading: session.step.canGoBack
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.previousStep(),
          )
              : IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final exit = await _confirmExit();
              if (exit && mounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            StepChecklist(currentStep: session.step),
            Expanded(child: _buildStep(session, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(RecoverySession session, CopilotController controller) {
    switch (session.step) {
      case RecoveryStep.calm:
        return CalmScreen(
          deadline: session.deadline,
          countdownExplainer: 'Bank ko 24 ghante me jawab dena zaruri hai',
          calmTitle: 'Pehle gehri saans lijiye',
          calmBody:
          'Hum saath hain. Agle 24 ghante bahut zaruri hain — hum aapko step-by-step madad karenge.',
          onNext: () => controller.nextStep(),
        );

      case RecoveryStep.call1930:
        return Call1930Screen(
          scriptTitle: '1930 par kya bolein?',
          scriptBullets: const [
            'Apna naam aur sheher batayein',
            'Kitne paise gaye — exact amount',
            'Kis app se paise gaye',
            'Fraudster ka number/UPI ID',
            'Kab hua tha — date aur time',
            'Complaint reference number likh lein',
          ],
          callLabel: 'Sabse pehle 1930 call karein',
          markDoneLabel: 'Call ho gayi — aage badhein',
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
            'Kab hua tha?',
            'Kitne paise aur kis app se?',
            'Kisko paise bheje?',
            'Kya hua tha?',
            'UTR / Transaction ID',
          ],
          questionHints: const [
            'Fraud kis din aur kis time hua',
            'Amount aur payment app select karein',
            'Payment app ki history se copy karein',
            'Scam ka type select karein',
            'Payment app me transaction ki UTR ID',
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