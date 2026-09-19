import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/kavach_button.dart';
import '../copilot_controller.dart';
import '../evidence_store.dart';
import '../widgets/evidence_item.dart';

/// Step 6: Evidence checklist with progress ring.
class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({
    super.key,
    required this.session,
    required this.onToggle,
    required this.onNext,
    required this.onBack,
  });

  final RecoverySession session;
  final void Function(String key, bool value) onToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;

  static const _items = [
    (
    'screenshot_chat',
    'Chat/message ka screenshot',
    'WhatsApp/SMS me se poora message screenshot lein',
    ),
    (
    'scammer_number',
    'Scammer ka phone number save karein',
    'Contact me "SCAM - do not call" naam se save karein',
    ),
    (
    'utr_txn_id',
    'UTR / Transaction ID note karein',
    'Payment app ki history me se copy karein',
    ),
    (
    'call_log',
    'Call log entry save karein',
    'Kis time call aayi thi — screenshot lein',
    ),
    (
    'app_notifications',
    'App notifications save rakhein',
    'Bank/UPI notifications delete na karein — proof hai',
    ),
  ];

  double get _progress {
    final total = EvidenceStore.defaultKeys.length;
    if (total == 0) return 0;
    final checked =
        session.evidenceChecks.values.where((v) => v == true).length;
    return checked / total;
  }

  bool get _allChecked => _progress >= 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _progress;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sabut sambhalein',
            style: theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Yeh cheezein baad me case me kaam aayengi.',
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.l16),

          // Progress ring
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 300),
                    builder: (_, value, __) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation(
                        _allChecked ? AppColors.safe : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: _allChecked ? AppColors.safe : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl24),

          // Checklist
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return EvidenceItem(
                  label: item.$2,
                  hint: item.$3,
                  isChecked: session.evidenceChecks[item.$1] ?? false,
                  onChanged: (v) => onToggle(item.$1, v ?? false),
                );
              },
            ),
          ),

          if (_allChecked)
            Container(
              padding: const EdgeInsets.all(AppSpacing.m12),
              margin: const EdgeInsets.only(bottom: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.safe.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.safe),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Shabaash! Saare sabut taiyaar hain.',
                      style: theme.textTheme.bodyLarge!.copyWith(color: AppColors.safe),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: KavachButton(
                  label: 'Peechhe',
                  variant: KavachButtonVariant.text,
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: AppSpacing.m12),
              Expanded(
                flex: 2,
                child: KavachButton(
                  label: 'Poora karein',
                  variant: KavachButtonVariant.filled,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onNext();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }
}