import 'package:flutter/material.dart';

import '../constant/color_helper.dart';

/// 4/8dp spacing rhythm. Use these instead of ad-hoc padding values.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Max width for page content so it stays readable on tablets.
  static const maxContentWidth = 600.0;
}

/// Soft, rounded corners. Chips are pills.
class AppRadius {
  AppRadius._();

  /// Fields, buttons, tiles.
  static const sm = 14.0;

  /// Cards and sheets.
  static const md = 18.0;
}

/// Soft produce tints, one per pantry category, with the ink that reads on
/// them. Read with `FoodTints.of(context)`.
@immutable
class FoodTints extends ThemeExtension<FoodTints> {
  const FoodTints({required this.tints, required this.onTint});

  /// In the order of `IngredientHelper.groups`.
  final List<Color> tints;
  final Color onTint;

  static const light = FoodTints(
    tints: ColorHelper.tints,
    onTint: ColorHelper.ink,
  );

  static const dark = FoodTints(
    tints: ColorHelper.tintsDark,
    onTint: ColorHelper.inkDark,
  );

  static FoodTints of(BuildContext context) =>
      Theme.of(context).extension<FoodTints>() ?? light;

  /// The tint for pantry category [index], wrapping if there are more
  /// categories than tints.
  Color at(int index) => tints[index % tints.length];

  @override
  FoodTints copyWith({List<Color>? tints, Color? onTint}) =>
      FoodTints(tints: tints ?? this.tints, onTint: onTint ?? this.onTint);

  @override
  FoodTints lerp(FoodTints? other, double t) {
    if (other == null) return this;
    return FoodTints(
      tints: [
        for (var i = 0; i < tints.length; i++)
          Color.lerp(tints[i], other.at(i), t)!,
      ],
      onTint: Color.lerp(onTint, other.onTint, t)!,
    );
  }
}

/// Fresh market basket: white ground, leaf green for actions, soft produce
/// tints, rounded cards with a gentle shadow.
class AppTheme {
  AppTheme._();

  static const _font = 'DMSans';

  static ThemeData get light => _build(
    ColorScheme.fromSeed(seedColor: ColorHelper.leaf).copyWith(
      primary: ColorHelper.leaf,
      onPrimary: Colors.white,
      primaryContainer: ColorHelper.haveContainer,
      onPrimaryContainer: ColorHelper.onHaveContainer,
      secondary: ColorHelper.need,
      onSecondary: Colors.white,
      secondaryContainer: ColorHelper.needContainer,
      onSecondaryContainer: ColorHelper.onNeedContainer,
      tertiary: ColorHelper.have,
      onTertiary: Colors.white,
      tertiaryContainer: ColorHelper.haveContainer,
      onTertiaryContainer: ColorHelper.onHaveContainer,
      error: ColorHelper.error,
      onError: Colors.white,
      surface: ColorHelper.paper,
      onSurface: ColorHelper.ink,
      onSurfaceVariant: ColorHelper.mutedInk,
      surfaceContainerLowest: ColorHelper.paper,
      surfaceContainerLow: ColorHelper.soft,
      surfaceContainer: ColorHelper.soft,
      surfaceContainerHigh: ColorHelper.softHigh,
      surfaceContainerHighest: ColorHelper.softHigh,
      outline: ColorHelper.outline,
      outlineVariant: ColorHelper.divider,
      inverseSurface: ColorHelper.ink,
      onInverseSurface: Colors.white,
      inversePrimary: ColorHelper.leafDark,
    ),
    FoodTints.light,
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: ColorHelper.leaf,
      brightness: Brightness.dark,
    ).copyWith(
      primary: ColorHelper.leafDark,
      onPrimary: ColorHelper.paperDark,
      primaryContainer: ColorHelper.haveContainerDark,
      onPrimaryContainer: ColorHelper.onHaveContainerDark,
      secondary: ColorHelper.needDark,
      onSecondary: ColorHelper.paperDark,
      secondaryContainer: ColorHelper.needContainerDark,
      onSecondaryContainer: ColorHelper.onNeedContainerDark,
      tertiary: ColorHelper.haveDark,
      onTertiary: ColorHelper.paperDark,
      tertiaryContainer: ColorHelper.haveContainerDark,
      onTertiaryContainer: ColorHelper.onHaveContainerDark,
      error: ColorHelper.errorDark,
      surface: ColorHelper.paperDark,
      onSurface: ColorHelper.inkDark,
      onSurfaceVariant: ColorHelper.mutedInkDark,
      surfaceContainerLowest: ColorHelper.paperDark,
      surfaceContainerLow: ColorHelper.softDark,
      surfaceContainer: ColorHelper.softDark,
      surfaceContainerHigh: ColorHelper.softHighDark,
      surfaceContainerHighest: ColorHelper.softHighDark,
      outline: ColorHelper.outlineDark,
      outlineVariant: ColorHelper.dividerDark,
      inverseSurface: ColorHelper.softHighDark,
      onInverseSurface: ColorHelper.inkDark,
      inversePrimary: ColorHelper.leaf,
    ),
    FoodTints.dark,
  );

  static ThemeData _build(ColorScheme scheme, FoodTints tints) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _font,
    );
    final text = base.textTheme;

    /// Bold, friendly, slightly tight headings.
    TextStyle? heading(TextStyle? style) => style?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -(style.fontSize ?? 16) * 0.02,
      height: 1.12,
    );

    final textTheme = text.copyWith(
      displayLarge: heading(text.displayLarge),
      displayMedium: heading(text.displayMedium),
      displaySmall: heading(text.displaySmall),
      headlineLarge: heading(text.headlineLarge),
      headlineMedium: heading(text.headlineMedium),
      headlineSmall: heading(text.headlineSmall),
      titleLarge: heading(text.titleLarge),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );
    OutlineInputBorder inputBorder(BorderSide side) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: side,
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: [tints],
      scaffoldBackgroundColor: scheme.surface,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.25),
        selectionHandleColor: scheme.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Unselected: soft fill. Selected: leaf green. Chips resolve only
      // the label colour by state, not a whole state-dependent style (that
      // renders the label invisible).
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.surfaceContainer,
          ),
        ),
        color: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainer,
        ),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurface,
          ),
        ),
        checkmarkColor: scheme.onPrimary,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          textStyle: textTheme.titleMedium,
          shape: rounded,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: textTheme.titleSmall,
          shape: rounded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          shape: rounded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: inputBorder(BorderSide.none),
        enabledBorder: inputBorder(BorderSide.none),
        focusedBorder: inputBorder(BorderSide(color: scheme.primary, width: 2)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
        actionTextColor: scheme.inversePrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.md + 6),
          ),
        ),
      ),
    );
  }
}
