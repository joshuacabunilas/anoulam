import 'package:flutter/material.dart';

/// Brand palette, "fresh market basket": white ground, deep green-black
/// ink, leaf green for actions, and soft produce tints per food category.
///
/// Use these through `Theme.of(context)` in widgets, not directly, so dark
/// mode keeps working. See `AppTheme` and `FoodTints`.
class ColorHelper {
  ColorHelper._();

  // Light theme.
  static const Color ink = Color(0xFF14261B);
  static const Color paper = Colors.white;

  /// Leaf green for buttons and selection (5:1 with white text).
  static const Color leaf = Color(0xFF17803F);

  /// Secondary text (5.6:1 on white).
  static const Color mutedInk = Color(0xFF5D6B62);

  /// Search field, unselected chips.
  static const Color soft = Color(0xFFF1F5F2);
  static const Color softHigh = Color(0xFFE6EDE8);

  /// Control borders (3.4:1 on white).
  static const Color outline = Color(0xFF8A968E);
  static const Color divider = Color(0xFFE6EBE7);

  /// "Still need": tomato red, as text and badges.
  static const Color need = Color(0xFFB5462B);
  static const Color needContainer = Color(0xFFFBE9E3);
  static const Color onNeedContainer = Color(0xFF8A2F18);

  /// "You have": deep leaf, as text and badges.
  static const Color have = Color(0xFF17773F);
  static const Color haveContainer = Color(0xFFE2F3E8);
  static const Color onHaveContainer = Color(0xFF0F5A2E);

  static const Color error = Color(0xFFB3261E);

  // Dark theme.
  static const Color inkDark = Color(0xFFE7F0EA);
  static const Color paperDark = Color(0xFF0F1712);
  static const Color leafDark = Color(0xFF5FCB8C);
  static const Color mutedInkDark = Color(0xFFA9B8AE);
  static const Color softDark = Color(0xFF1A241D);
  static const Color softHighDark = Color(0xFF243028);
  static const Color outlineDark = Color(0xFF7C8A81);
  static const Color dividerDark = Color(0xFF263129);
  static const Color needDark = Color(0xFFF29A80);
  static const Color needContainerDark = Color(0xFF4A1C10);
  static const Color onNeedContainerDark = Color(0xFFFFD9CD);
  static const Color haveDark = Color(0xFF7FD8A2);
  static const Color haveContainerDark = Color(0xFF123822);
  static const Color onHaveContainerDark = Color(0xFFC6EED5);
  static const Color errorDark = Color(0xFFF2B8B5);

  /// Produce tints, one per pantry category, in the order of
  /// `IngredientHelper.groups`: meat, seafood, eggs and dairy, vegetables,
  /// fruits, grains, sauces, herbs, baking. Ink text reads on all of them.
  static const List<Color> tints = [
    Color(0xFFFBE9E3),
    Color(0xFFE3EEF8),
    Color(0xFFFFF1D6),
    Color(0xFFE2F3E8),
    Color(0xFFFDE7EE),
    Color(0xFFF4EBDD),
    Color(0xFFEDE4F6),
    Color(0xFFE8F2DC),
    Color(0xFFF6ECE2),
  ];

  /// The same tints, deepened for dark mode; light ink reads on them.
  static const List<Color> tintsDark = [
    Color(0xFF3E2620),
    Color(0xFF1E2E3D),
    Color(0xFF3B3220),
    Color(0xFF1C3526),
    Color(0xFF3D2430),
    Color(0xFF362D22),
    Color(0xFF2E2640),
    Color(0xFF26331E),
    Color(0xFF382C22),
  ];
}
