import 'package:flutter/widgets.dart';

/// Layout breakpoints. Standard screen design targets 360×640 first.
enum Breakpoint { compact, standard, medium, expanded }

extension BreakpointX on Breakpoint {
  bool get isCompact => this == Breakpoint.compact;
  bool get isAtLeastMedium =>
      this == Breakpoint.medium || this == Breakpoint.expanded;
  bool get isExpanded => this == Breakpoint.expanded;
}

Breakpoint classifyWidth(double width) {
  if (width < 360) return Breakpoint.compact;
  if (width < 600) return Breakpoint.standard;
  if (width < 910) return Breakpoint.medium;
  return Breakpoint.expanded;
}

/// Publishes the current [Breakpoint] to descendants.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({required this.builder, super.key});

  final Widget Function(BuildContext context, Breakpoint bp) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Breakpoint bp = classifyWidth(constraints.maxWidth);
        return _BreakpointScope(
          breakpoint: bp,
          child: Builder(builder: (BuildContext ctx) => builder(ctx, bp)),
        );
      },
    );
  }

  static Breakpoint of(BuildContext context) {
    final _BreakpointScope? scope =
    context.dependOnInheritedWidgetOfExactType<_BreakpointScope>();
    return scope?.breakpoint ?? Breakpoint.standard;
  }
}

class _BreakpointScope extends InheritedWidget {
  const _BreakpointScope({required this.breakpoint, required super.child});
  final Breakpoint breakpoint;

  @override
  bool updateShouldNotify(_BreakpointScope oldWidget) =>
      oldWidget.breakpoint != breakpoint;
}