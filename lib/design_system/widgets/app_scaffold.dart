import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

/// Standard page shell with consistent padding & AppBar.
class AppScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomBar;
  final Widget child;

  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottomBar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: title != null ? Text(title!) : null,
        actions: actions,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}
