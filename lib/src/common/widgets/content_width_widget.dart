import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Centers [child] and caps its width so content stays readable on tablets
/// and in landscape.
class ContentWidthWidget extends StatelessWidget {
  const ContentWidthWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      // Size to the child's height so this also works in bottom bars.
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: child,
      ),
    );
  }
}
