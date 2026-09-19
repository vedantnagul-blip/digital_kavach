import 'package:flutter/foundation.dart';

import '../../core/errors/kavach_exception.dart';
import 'models/verdict.dart';

/// Sealed UI state for [VerdictCard].
///
/// Phases 04–05 emit these from the AI router / scanner controller.
@immutable
sealed class VerdictUiState {
  const VerdictUiState();
}

class VerdictTier1Only extends VerdictUiState {
  const VerdictTier1Only(this.verdict);
  final Verdict verdict;
}

class VerdictAiUpgrading extends VerdictUiState {
  const VerdictAiUpgrading(this.tier1);
  final Verdict tier1;
}

class VerdictComplete extends VerdictUiState {
  const VerdictComplete(this.verdict, {this.secondOpinion = false});
  final Verdict verdict;
  final bool secondOpinion;
}

class VerdictAiFailed extends VerdictUiState {
  const VerdictAiFailed(this.tier1, this.error);
  final Verdict tier1;
  final KavachException error;
}