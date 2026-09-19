import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Verdict severity. Serializable via [name].
enum Severity { scam, suspicious, safe }

enum SeveritySize { sm, md, lg }

/// Colored container badge for verdicts. Uses tokens + icon (not emoji)
/// so it renders consistently across OEMs and is accessible.
class SeverityBadge extends ConsumerWidget {
  const SeverityBadge({
    required this.severity,
    this.size = SeveritySize.md,
    this.showLabel = true,
    super.key,
  });

  final Severity severity;
  final SeveritySize size;
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = ref.watch(l10nProvider);
    final _SeverityStyle style = _styleFor(severity);
    final double iconSize = _iconSize(size);
    final double padH = _padH(size);
    final double padV = _padV(size);
    final TextStyle labelStyle = _labelStyle(context, size);
    final String label = _labelFor(severity, l10n);

    return Semantics(
      label: '$label severity',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: style.container,
          borderRadius: AppRadius.rPill,
          border: Border.all(color: style.fg.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(style.icon, size: iconSize, color: style.fg),
            if (showLabel) ...<Widget>[
              const SizedBox(width: 6),
              Text(
                label,
                style: labelStyle.copyWith(
                  color: style.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static _SeverityStyle _styleFor(Severity s) {
    switch (s) {
      case Severity.scam:
        return const _SeverityStyle(
          container: AppColors.dangerContainer,
          fg: AppColors.danger,
          icon: Icons.dangerous_rounded,
        );
      case Severity.suspicious:
        return const _SeverityStyle(
          container: AppColors.warningContainer,
          fg: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case Severity.safe:
        return const _SeverityStyle(
          container: AppColors.safeContainer,
          fg: AppColors.safe,
          icon: Icons.verified_rounded,
        );
    }
  }

  static String _labelFor(Severity s, L10n l10n) {
    switch (s) {
      case Severity.scam:
        return l10n.strings.severityScam;
      case Severity.suspicious:
        return l10n.strings.severitySuspicious;
      case Severity.safe:
        return l10n.strings.severitySafe;
    }
  }

  static double _iconSize(SeveritySize s) {
    switch (s) {
      case SeveritySize.sm:
        return 14;
      case SeveritySize.md:
        return 18;
      case SeveritySize.lg:
        return 24;
    }
  }

  static double _padH(SeveritySize s) => s == SeveritySize.lg ? 14 : 10;
  static double _padV(SeveritySize s) => s == SeveritySize.lg ? 8 : 6;

  static TextStyle _labelStyle(BuildContext c, SeveritySize s) {
    final TextTheme t = Theme.of(c).textTheme;
    switch (s) {
      case SeveritySize.sm:
        return t.labelSmall ?? const TextStyle(fontSize: 11);
      case SeveritySize.md:
        return t.labelMedium ?? const TextStyle(fontSize: 12);
      case SeveritySize.lg:
        return t.labelLarge ?? const TextStyle(fontSize: 14);
    }
  }
}

class _SeverityStyle {
  const _SeverityStyle({
    required this.container,
    required this.fg,
    required this.icon,
  });
  final Color container;
  final Color fg;
  final IconData icon;
}