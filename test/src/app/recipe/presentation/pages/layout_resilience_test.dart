import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/presentation/pages/recipe_detail_page.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/recipe_card_widget.dart';
import 'package:mobile/app.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

import '../../../../../helpers/test_injection.dart';

const _recipe = RecipeEntities(
  id: 'beef-stir-fry',
  name: 'Beef and Vegetable Stir-Fry',
  description: 'Tender beef strips with crisp vegetables.',
  cookingTimeMinutes: 25,
  servings: 3,
  difficulty: RecipeDifficulty.medium,
  usedIngredients: ['beef', 'onion', 'garlic'],
  missingIngredients: ['bell pepper', 'soy sauce', 'carrot'],
  steps: ['Slice the beef thinly.', 'Stir-fry everything together.'],
);

/// Small phone (375x667 logical px) with system text at 200%.
Future<void> _useSmallPhoneLargeText(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  setUp(setUpTestDependencies);

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('recipe card and detail fit at 200% text ($name)', (
      tester,
    ) async {
      await _useSmallPhoneLargeText(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [RecipeCardWidget(recipe: _recipe, onTap: () {})],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const RecipeDetailPage(recipe: _recipe),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ingredients page fits at 200% text on a small phone', (
    tester,
  ) async {
    await _useSmallPhoneLargeText(tester);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
