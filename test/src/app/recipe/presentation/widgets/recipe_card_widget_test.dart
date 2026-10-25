import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/recipe_card_widget.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

const _recipe = RecipeEntities(
  id: 'adobo',
  name: 'Chicken Adobo',
  description: 'Braised chicken.',
  cookingTimeMinutes: 45,
  servings: 4,
  difficulty: RecipeDifficulty.easy,
  usedIngredients: ['chicken'],
  missingIngredients: ['vinegar'],
  steps: ['Cook it.'],
  category: RecipeCategory.meat,
);

/// Pumps the card full width on a phone of [width] dp, as in the results
/// list (16 dp side padding).
Future<void> _pump(
  WidgetTester tester, {
  RecipeEntities recipe = _recipe,
  double textScale = 1,
  double width = 390,
}) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RecipeCardWidget(recipe: recipe, onTap: () {}),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows what is missing, on the photo and by name', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(StringHelper.missingCount(1)), findsOneWidget);
    expect(find.text(StringHelper.needsNamed(['vinegar'])), findsOneWidget);
  });

  testWidgets('a ready recipe says so and lists nothing missing', (
    tester,
  ) async {
    await _pump(
      tester,
      recipe: const RecipeEntities(
        id: 'rice',
        name: 'Egg fried rice',
        description: '',
        cookingTimeMinutes: 15,
        servings: 2,
        difficulty: RecipeDifficulty.easy,
        usedIngredients: ['rice', 'eggs'],
        missingIngredients: [],
        steps: ['Fry.'],
      ),
    );

    expect(find.text(StringHelper.canCookNow), findsOneWidget);
    expect(find.textContaining('Needs'), findsNothing);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('fits at 200% text on a $width dp phone', (tester) async {
      await _pump(tester, textScale: 2, width: width);

      expect(tester.takeException(), isNull);
    });
  }
}
