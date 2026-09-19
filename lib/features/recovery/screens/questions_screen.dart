import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/kavach_button.dart';
import '../copilot_controller.dart';
import '../widgets/question_field.dart';

/// Step 3: Five questions, one per sub-screen.
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.session,
    required this.onUpdateAnswers,
    required this.onNext,
    required this.onBack,
    required this.questionLabels,
    required this.questionHints,
  });

  final RecoverySession session;
  final void Function(RecoveryAnswers Function(RecoveryAnswers)) onUpdateAnswers;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final List<String> questionLabels;
  final List<String> questionHints;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late TextEditingController _textController;

  static const _paymentApps = ['PhonePe', 'GPay', 'Paytm', 'BHIM', 'Other'];
  static const _scamFamilies = [
    'Digital Arrest',
    'Fake KYC',
    'UPI Fraud',
    'Fake Challan',
    'Lottery',
    'Investment Scam',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _syncController();
  }

  @override
  void didUpdateWidget(QuestionsScreen old) {
    super.didUpdateWidget(old);
    if (old.session.questionIndex != widget.session.questionIndex) {
      _syncController();
    }
  }

  void _syncController() {
    final idx = widget.session.questionIndex;
    final a = widget.session.answers;
    switch (idx) {
      case 0:
        _textController.text = '';
        break;
      case 1:
        _textController.text = a.amount?.toString() ?? '';
        break;
      case 2:
        _textController.text = a.toWhom ?? '';
        break;
      case 3:
        _textController.text = a.description ?? '';
        break;
      case 4:
        _textController.text = a.utrNumber ?? '';
        break;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.session.questionIndex;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == idx ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= idx
                      ? AppColors.primary
                      : theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl24),

          // Question label
          Text(
            widget.questionLabels[idx],
            style: theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.l16),

          // Question content
          Expanded(child: _buildQuestion(idx, theme)),

          // Navigation
          Row(
            children: [
              if (idx > 0)
                Expanded(
                  child: KavachButton(
                    label: 'Peechhe',
                    variant: KavachButtonVariant.outlined,
                    onPressed: widget.onBack,
                  ),
                ),
              if (idx > 0) const SizedBox(width: AppSpacing.m12),
              Expanded(
                flex: idx > 0 ? 1 : 1,
                child: KavachButton(
                  label: idx == 4 ? 'Aage' : 'Aage',
                  variant: KavachButtonVariant.filled,
                  onPressed: widget.onNext,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }

  Widget _buildQuestion(int idx, ThemeData theme) {
    switch (idx) {
      case 0: // When
        return _buildWhenPicker(theme);
      case 1: // Amount + app
        return _buildAmountApp(theme);
      case 2: // To whom
        return _buildToWhom(theme);
      case 3: // What happened
        return _buildWhatHappened(theme);
      case 4: // Name + city + UTR
        return _buildNameCityUtr(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWhenPicker(ThemeData theme) {
    final a = widget.session.answers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.questionHints[0],
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.l16),
        KavachButton(
          label: a.incidentDate != null
              ? '${a.incidentDate!.day}/${a.incidentDate!.month}/${a.incidentDate!.year} '
              '${a.incidentDate!.hour}:${a.incidentDate!.minute.toString().padLeft(2, '0')}'
              : 'Abhi select karein',
          variant: KavachButtonVariant.tonal,
          icon: Icons.calendar_today,
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: a.incidentDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (date != null && mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(a.incidentDate ?? DateTime.now()),
              );
              if (time != null) {
                widget.onUpdateAnswers(
                      (old) => old.copyWith(
                    incidentDate: DateTime(
                      date.year, date.month, date.day,
                      time.hour, time.minute,
                    ),
                  ),
                );
              } else {
                widget.onUpdateAnswers(
                      (old) => old.copyWith(incidentDate: date),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildAmountApp(ThemeData theme) {
    final a = widget.session.answers;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionField(
            label: 'Kitne paise gaye?',
            hint: 'Jaise: 50000',
            controller: _textController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              final amount = int.tryParse(v);
              widget.onUpdateAnswers((old) => old.copyWith(amount: amount));
            },
          ),
          const SizedBox(height: AppSpacing.xxl24),
          Text(
            'Kis app se paise gaye?',
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.m12),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: _paymentApps.map((app) {
              final selected = a.paymentApp == app;
              return ChoiceChip(
                label: Text(app),
                selected: selected,
                onSelected: (_) {
                  HapticFeedback.lightImpact();
                  widget.onUpdateAnswers((old) => old.copyWith(paymentApp: app));
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToWhom(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.questionHints[2],
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.l16),
          QuestionField(
            label: 'Kisko paise bheje?',
            hint: 'UPI ID / Phone / Account number',
            controller: _textController,
            onChanged: (v) {
              widget.onUpdateAnswers((old) => old.copyWith(toWhom: v));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWhatHappened(ThemeData theme) {
    final a = widget.session.answers;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kya hua tha?',
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.m12),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: _scamFamilies.map((f) {
              final selected = a.scamFamily == f;
              return ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (_) {
                  HapticFeedback.lightImpact();
                  widget.onUpdateAnswers((old) => old.copyWith(scamFamily: f));
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.l16),
          QuestionField(
            label: 'Aur detail (optional)',
            hint: 'Screenshot se copy karein ya type karein',
            controller: _textController,
            maxLines: 4,
            onChanged: (v) {
              widget.onUpdateAnswers((old) => old.copyWith(description: v));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNameCityUtr(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionField(
            label: 'UTR / Transaction ID',
            hint: 'Payment app se copy karein',
            controller: _textController,
            onChanged: (v) {
              widget.onUpdateAnswers((old) => old.copyWith(utrNumber: v));
            },
          ),
          const SizedBox(height: AppSpacing.l16),
          Text(
            'Naam aur sheher pehle se bhare hain. Galat ho toh Settings me badlein.',
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}