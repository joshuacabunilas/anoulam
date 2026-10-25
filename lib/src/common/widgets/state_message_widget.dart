import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Centered icon, title and message for empty and error states, with an
/// optional action button.
class StateMessageWidget extends StatelessWidget {
  const StateMessageWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = this.message;
    final actionLabel = this.actionLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative: the title below carries the meaning.
            ExcludeSemantics(
              child: Icon(icon, size: 48, color: scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
