import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

/// Standard card composition: optional header/footer; tapable if [onTap] set.
class AppCard extends StatelessWidget {
  final Widget? header;
  final Widget? footer;
  final Widget child;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    this.header,
    this.footer,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[header!, const SizedBox(height: AppSpacing.md)],
            child,
            if (footer != null) ...[const SizedBox(height: AppSpacing.md), footer!],
          ],
        ),
      ),
    );
    return onTap != null ? InkWell(onTap: onTap, child: card) : card;
  }
}
