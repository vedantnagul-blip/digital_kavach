import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_radius.dart';
import '../theme/theme_provider.dart';

/// The canonical Digital Kavach button.
///
/// Variants map to design intent — pick the variant that expresses meaning,
/// not just color:
///  * [KavachButtonVariant.filled]   — primary CTA
///  * [KavachButtonVariant.tonal]    — secondary CTA
///  * [KavachButtonVariant.outlined] — tertiary / cancel-adjacent
///  * [KavachButtonVariant.danger]   — destructive / SCAM-related
///  * [KavachButtonVariant.text]     — inline links
///
/// The loading state preserves the button's rendered width (no layout jump).
enum KavachButtonVariant { filled, tonal, outlined, danger, text }

class KavachButton extends ConsumerWidget {
  const KavachButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = KavachButtonVariant.filled,
    this.loading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final KavachButtonVariant variant;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool elder = ref.watch(elderModeProvider).enabled;
    final double minHeight = elder ? 64 : 48;

    final Widget child = _ButtonBody(
      label: label,
      icon: icon,
      loading: loading,
      textStyle: theme.textTheme.labelLarge,
    );

    final ButtonStyle baseStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(64, minHeight)),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: AppRadius.rM),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );

    final VoidCallback? effectiveOnPressed = loading ? null : onPressed;

    Widget button;
    switch (variant) {
      case KavachButtonVariant.filled:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: baseStyle,
          child: child,
        );
        break;
      case KavachButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: baseStyle,
          child: child,
        );
        break;
      case KavachButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: baseStyle,
          child: child,
        );
        break;
      case KavachButtonVariant.danger:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: baseStyle.copyWith(
            backgroundColor: WidgetStatePropertyAll<Color>(scheme.error),
            foregroundColor: WidgetStatePropertyAll<Color>(scheme.onError),
          ),
          child: child,
        );
        break;
      case KavachButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: baseStyle,
          child: child,
        );
        break;
    }

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: label,
      child: button,
    );
  }
}

class _ButtonBody extends StatelessWidget {
  const _ButtonBody({
    required this.label,
    required this.loading,
    this.icon,
    this.textStyle,
  });

  final String label;
  final bool loading;
  final IconData? icon;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    // Measure the label at natural size; overlay spinner. This preserves
    // width so the button doesn't shrink/expand when toggling loading.
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(
          opacity: loading ? 0 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
        if (loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
      ],
    );
  }
}