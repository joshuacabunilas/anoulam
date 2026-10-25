import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    group('$name theme contrast', () {
      final s = theme.colorScheme;

      // Text pairs need 4.5:1 (WCAG AA, normal text).
      final textPairs = {
        'onSurface / surface': (s.onSurface, s.surface),
        'onSurfaceVariant / surface': (s.onSurfaceVariant, s.surface),
        'onSurfaceVariant / card': (s.onSurfaceVariant, s.surfaceContainerLow),
        'onPrimary / primary': (s.onPrimary, s.primary),
        'onPrimaryContainer / primaryContainer': (
          s.onPrimaryContainer,
          s.primaryContainer,
        ),
        'onSecondaryContainer / secondaryContainer': (
          s.onSecondaryContainer,
          s.secondaryContainer,
        ),
        'onTertiaryContainer / tertiaryContainer': (
          s.onTertiaryContainer,
          s.tertiaryContainer,
        ),
        'primary / surface (text buttons)': (s.primary, s.surface),
        // "You have" / "You still need" group titles.
        'tertiary / surface': (s.tertiary, s.surface),
        'secondary / surface': (s.secondary, s.surface),
      };
      for (final MapEntry(key: pair, value: (fg, bg)) in textPairs.entries) {
        test('$pair >= 4.5:1', () {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }

      // Meaningful icons and field borders need 3:1 (non-text contrast).
      final nonTextPairs = {
        'outline / card': (s.outline, s.surfaceContainerLowest),
        'tertiary icon / card': (s.tertiary, s.surfaceContainerLow),
        'secondary icon / card': (s.secondary, s.surfaceContainerLow),
      };
      for (final MapEntry(key: pair, value: (fg, bg)) in nonTextPairs.entries) {
        test('$pair >= 3:1', () {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(3));
        });
      }

      // Category names and counts sit directly on the produce tints.
      final tints = theme.extension<FoodTints>()!;
      for (final (index, tint) in tints.tints.indexed) {
        test('text on tint $index >= 4.5:1', () {
          expect(_contrast(tints.onTint, tint), greaterThanOrEqualTo(4.5));
        });
      }
    });
  }
}
