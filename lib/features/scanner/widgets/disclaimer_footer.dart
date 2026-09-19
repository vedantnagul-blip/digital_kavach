import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';

class DisclaimerFooter extends ConsumerWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData t = Theme.of(context);
    final AppLocale locale = ref.watch(localeProvider);
    final String msg = _msg(locale);
    return Row(
      children: <Widget>[
        Icon(Icons.info_outline_rounded,
            size: 14, color: t.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            msg,
            style: t.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String _msg(AppLocale l) {
    switch (l) {
      case AppLocale.hi:
        return 'AI मत — अंतिम निर्णय आपका';
      case AppLocale.mr:
        return 'AI मत — अंतिम निर्णय आपला';
      case AppLocale.en:
        return 'AI opinion — final decision is yours';
      default:
      // Fallback to English for ta, te, bn, gu, kn, ml, pa
        return 'AI opinion — final decision is yours';
    }
  }
}