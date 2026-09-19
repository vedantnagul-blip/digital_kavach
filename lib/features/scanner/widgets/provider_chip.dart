import 'package:flutter/material.dart';

import '../../../core/widgets/info_chip.dart';
import '../models/verdict.dart';

class ProviderChip extends StatelessWidget {
  const ProviderChip({required this.info, super.key});
  final AiProviderInfo info;

  @override
  Widget build(BuildContext context) {
    switch (info.provider) {
      case AiProvider.tier1:
        return const InfoChip(
          label: 'On-device rules',
          icon: Icons.bolt_rounded,
        );
      case AiProvider.gemini:
        return InfoChip(
          label: info.model == null ? 'Gemini' : 'Gemini · ${info.model}',
          icon: Icons.auto_awesome_rounded,
        );
      case AiProvider.grok:
        return InfoChip(
          label: info.model == null ? 'Grok' : 'Grok · ${info.model}',
          icon: Icons.psychology_alt_rounded,
        );
      case AiProvider.cached:
        return const InfoChip(
          label: 'Cached verdict',
          icon: Icons.history_toggle_off_rounded,
        );
    }
  }
}