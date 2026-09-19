import 'package:flutter/material.dart';

/// The canonical scaffold. Every top-level screen uses this instead of
/// bare [Scaffold] so background, safe-area, and snackbar behavior stay
/// consistent across the app.
class KavachScaffold extends StatelessWidget {
  const KavachScaffold({
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.scrollable = false,
    this.padding = const EdgeInsets.all(16),
    this.safeArea = true,
    this.centerTitle = false,
    super.key,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool safeArea;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget content = Padding(padding: padding, child: body);
    if (scrollable) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(padding: padding, child: body),
      );
    }
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: (title != null || (actions?.isNotEmpty ?? false) || leading != null)
          ? AppBar(
        title: title,
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
      )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}