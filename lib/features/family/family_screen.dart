import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/loading_view.dart';
import 'family_controller.dart';
import 'family_repo.dart';
import 'pairing/pair_qr_screen.dart';
import 'pairing/pair_success_screen.dart';
import 'pairing/scan_pair_screen.dart';
import 'widgets/alert_level_selector.dart';
import 'widgets/member_card.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  Future<void> _openPairScreen(
      BuildContext context,
      WidgetRef ref,
      FamilyController controller,
      ) async {
    await controller.generatePairCode();

    if (!context.mounted) return;

    // Read fresh state after the asynchronous operation.
    final updated = ref.read(familyControllerProvider);

    final code = updated.activePairCode;
    final familyId = updated.activePairFamilyId;
    final expiry = updated.pairCodeExpiry;

    if (code == null || familyId == null || expiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.error ?? 'Could not create a pairing code.',
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PairQrScreen(
          pairCode: code,
          familyId: familyId,
          expiresAt: expiry,
          onDone: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

    if (context.mounted) {
      await controller.loadFamily();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyControllerProvider);
    final controller = ref.read(familyControllerProvider.notifier);
    final theme = Theme.of(context);

    if (state.isLoading && !state.hasFamily) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Shield')),
        body: const Center(child: LoadingView()),
      );
    }

    if (!state.hasFamily) {
      return _NoFamilyView(
        onGenerateCode: () {
          _openPairScreen(context, ref, controller);
        },
        onScanCode: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanPairScreen(
                onJoin: (familyId, code) async {
                  final ok = await controller.joinWithCode(
                    familyId.trim(),
                    code.trim(),
                  );

                  if (ok && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PairSuccessScreen(
                          guardianName: 'Guardian',
                          elderName: 'You',
                          onDone: () {
                            Navigator.popUntil(
                              context,
                                  (route) => route.isFirst,
                            );
                          },
                        ),
                      ),
                    );
                  }

                  return ok;
                },
                isLoading: state.isLoading,
                error: state.error,
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Shield'),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadFamily(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l16),
          children: [
            Text(
              'Members',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: AppSpacing.s8),

            ...state.members.map(
                  (member) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.s8,
                ),
                child: MemberCard(
                  member: member,
                  onUnpair: () => _confirmUnpair(
                    context,
                    controller,
                    member,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.l16),

            KavachButton(
              label: 'Naya member jodein',
              variant: KavachButtonVariant.tonal,
              icon: Icons.person_add,
              expand: true,
              onPressed: () {
                _openPairScreen(context, ref, controller);
              },
            ),

            const SizedBox(height: AppSpacing.xxl24),

            AlertLevelSelector(
              currentLevel: state.alertLevel,
              onChanged: controller.setAlertLevel,
            ),

            const SizedBox(height: AppSpacing.l16),

            SwitchListTile(
              title: const Text('Weekly Digest'),
              subtitle: const Text('Har Sunday shaam ko summary'),
              value: state.digestEnabled,
              onChanged: controller.setDigestEnabled,
            ),

            const Divider(),

            const SizedBox(height: AppSpacing.l16),

            Text(
              'Recent Alerts',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: AppSpacing.s8),

            if (state.recentEvents.isEmpty)
              const EmptyStateView(
                icon: Icons.shield_outlined,
                title: 'No recent alerts',
                message: 'No family alerts are available yet.',
              )
            else
              ...state.recentEvents.map(
                    (event) => _EventTile(event: event),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmUnpair(
      BuildContext context,
      FamilyController controller,
      FamilyMember member,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unpair karein?'),
        content: Text(
          '${member.displayName} ko family se hatana chahte hain?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              controller.unpairMember(member.uid);
            },
            child: const Text('Unpair'),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final FamilyEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRed = event.severity == 'RED';

    return ListTile(
      leading: Icon(
        isRed ? Icons.error : Icons.warning_amber,
        color: isRed ? AppColors.danger : AppColors.warning,
      ),
      title: Text(
        event.pattern.replaceAll('_', ' '),
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        '${event.ts.day}/${event.ts.month} '
            '${event.ts.hour}:'
            '${event.ts.minute.toString().padLeft(2, '0')}',
        style: theme.textTheme.bodySmall,
      ),
      dense: true,
    );
  }
}

class _NoFamilyView extends StatelessWidget {
  const _NoFamilyView({
    required this.onGenerateCode,
    required this.onScanCode,
  });

  final VoidCallback onGenerateCode;
  final VoidCallback onScanCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Shield'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.family_restroom,
                size: 80,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: AppSpacing.l16),

              Text(
                'Family Shield',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.s8),

              Text(
                'Connect with a trusted family member to share '
                    'scam warnings.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl32),

              KavachButton(
                label: 'Elder ko jodein (code banayein)',
                variant: KavachButtonVariant.filled,
                icon: Icons.qr_code,
                expand: true,
                onPressed: onGenerateCode,
              ),

              const SizedBox(height: AppSpacing.m12),

              KavachButton(
                label: 'Code se judein (elder hoon)',
                variant: KavachButtonVariant.outlined,
                icon: Icons.qr_code_scanner,
                expand: true,
                onPressed: onScanCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}