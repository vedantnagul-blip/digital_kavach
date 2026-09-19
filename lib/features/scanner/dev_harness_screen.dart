import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../data/rules/rule.dart';
import '../../data/rules/rule_engine.dart';
import '../../data/rules/score_aggregator.dart';
import 'models/verdict.dart';
import 'verdict_card.dart';
import 'verdict_ui_state.dart';

final FutureProvider<RuleEngine> ruleEngineProvider =
FutureProvider<RuleEngine>((Ref ref) => RuleEngine.instance());

class DevRulesHarnessScreen extends ConsumerStatefulWidget {
  const DevRulesHarnessScreen({super.key});
  @override
  ConsumerState<DevRulesHarnessScreen> createState() =>
      _DevRulesHarnessScreenState();
}

class _DevRulesHarnessScreenState
    extends ConsumerState<DevRulesHarnessScreen> {
  final TextEditingController _c = TextEditingController();
  Tier1Result? _last;
  Verdict? _lastVerdict;
  int _demoStateIndex = 0;

  final List<String> _samples = <String>[
    'सावधान! Digital Arrest वारंट जारी हुआ है, CBI officer से तुरंत बात करें। कस्टम पार्सल में drugs मिले हैं। पैसे भेजो या 2 hours में गिरफ़्तारी।',
    'Your SBI account KYC has expired. Update immediately: http://sbi-verify.xyz/kyc otherwise account will be blocked in 24 hours.',
    'Dear customer, Rs.2,499 debited from A/c XX1234 on 12-Nov to VPA merchant@upi. Balance Rs.15,201. Not you? SMS BLOCK to 567676.',
    'Congratulations! You won KBC lottery Rs.25,00,000. Pay registration fee Rs.5,499 to claim. Call now.',
    'Scan this QR to receive money. Enter your UPI PIN to get Rs.5000.',
  ];

  void _run() async {
    final RuleEngine engine = await ref.read(ruleEngineProvider.future);
    final AppLocale locale = ref.read(localeProvider);
    final Tier1Result r = engine.run(ScanInput(
      text: _c.text,
      source: ScanSource.paste,
      langCode: locale.code,
    ));
    final Verdict v = VerdictBuild.fromTier1(
      hits: r.hits,
      score: r.score,
      level: r.level,
      langCode: locale.code,
    );
    setState(() {
      _last = r;
      _lastVerdict = v;
      _demoStateIndex = 0;
    });
  }

  VerdictUiState _currentState() {
    if (_lastVerdict == null) {
      return VerdictTier1Only(
        VerdictBuild.fromTier1(
          hits: const <RuleHit>[],
          score: 0,
          level: VerdictLevel.green,
          langCode: 'en',
        ),
      );
    }
    switch (_demoStateIndex) {
      case 0: return VerdictTier1Only(_lastVerdict!);
      case 1: return VerdictAiUpgrading(_lastVerdict!);
      case 2: return VerdictComplete(_lastVerdict!, secondOpinion: true);
      case 3:
        return VerdictAiFailed(
        _lastVerdict!,
        const AiProviderException('dev', 'Simulated AI failure'),
        );
      default: return VerdictTier1Only(_lastVerdict!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return KavachScaffold(
      title: const Text('Dev · Rule Engine'),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionHeader(title: 'Paste text to scan'),
          TextField(
            controller: _c,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste a WhatsApp / SMS text…',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (int i = 0; i < _samples.length; i++)
                ActionChip(
                  label: Text('Sample ${i + 1}'),
                  onPressed: () {
                    _c.text = _samples[i];
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          KavachButton(
            label: 'Run Tier-1 scan',
            icon: Icons.play_arrow_rounded,
            onPressed: _run,
            expand: true,
          ),
          const SizedBox(height: AppSpacing.xl20),
          if (_last != null) ...<Widget>[
            SectionHeader(
              title:
              'Result · ${_last!.latencyMicros}µs · ${_last!.hits.length} hits',
              subtitle:
              'Score ${_last!.score} → ${_last!.level.wire.toLowerCase()}',
            ),
            const SizedBox(height: 8),
            _StateSelector(
              index: _demoStateIndex,
              onChanged: (int i) => setState(() => _demoStateIndex = i),
            ),
            const SizedBox(height: 12),
            VerdictCard(state: _currentState()),
            const SizedBox(height: AppSpacing.xl20),
            SectionHeader(title: 'Rule Hits (${_last!.hits.length})'),
            _HitsTable(hits: _last!.hits),
          ],
        ],
      ),
    );
  }
}



class _StateSelector extends StatelessWidget {
  const _StateSelector({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>[
      'Tier-1 only',
      'AI upgrading',
      'Complete (2-AI)',
      'AI failed',
    ];
    return SegmentedButton<int>(
      segments: <ButtonSegment<int>>[
        for (int i = 0; i < labels.length; i++)
          ButtonSegment<int>(value: i, label: Text(labels[i])),
      ],
      selected: <int>{index},
      onSelectionChanged: (Set<int> s) => onChanged(s.first),
    );
  }
}

class _HitsTable extends StatelessWidget {
  const _HitsTable({required this.hits});
  final List<RuleHit> hits;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    if (hits.isEmpty) {
      return Text('No hits.', style: t.textTheme.bodyMedium);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rM,
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < hits.length; i++) ...<Widget>[
            if (i > 0) Divider(color: t.colorScheme.outlineVariant, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 42,
                    child: Text('${hits[i].weight}',
                        style: t.textTheme.titleMedium),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${hits[i].ruleId} · ${hits[i].family.wireName}',
                            style: t.textTheme.labelLarge),
                        const SizedBox(height: 2),
                        Text(hits[i].matchedSnippet,
                            style: t.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}