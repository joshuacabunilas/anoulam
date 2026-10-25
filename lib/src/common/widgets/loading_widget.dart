import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message, this.size = 36, this.action});

  final String? message;
  final double size;

  /// Optional control under the message, e.g. a Cancel button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    final action = this.action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: size,
              child: const CircularProgressIndicator(),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              // Announced by screen readers when loading starts and whenever
              // the message changes.
              Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}

/// Keeps [child] on screen and covers it with a dimmed [LoadingWidget]
/// while [isLoading] is true. Blocks taps on [child] while visible.
///
/// Use for actions on an already-loaded screen, e.g. submitting a form.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: LoadingWidget(message: message),
            ),
          ),
      ],
    );
  }
}
