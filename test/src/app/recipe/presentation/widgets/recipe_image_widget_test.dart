import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/recipe_image_widget.dart';

RecipeEntities _recipe({String? imageUrl}) => RecipeEntities(
  id: 'miso-soup',
  name: 'Miso Soup',
  description: 'Light soup.',
  cookingTimeMinutes: 10,
  servings: 2,
  difficulty: RecipeDifficulty.easy,
  usedIngredients: const ['tofu'],
  missingIngredients: const [],
  steps: const ['Cook.'],
  category: RecipeCategory.soup,
  imageUrl: imageUrl,
);

Widget _wrap(Widget child) =>
    MaterialApp(home: SizedBox(width: 320, height: 180, child: child));

void main() {
  testWidgets('shows the category illustration when there is no photo', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(RecipeImageWidget(recipe: _recipe())));

    expect(find.byType(RecipeIllustrationWidget), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.soup_kitchen), findsWidgets);
  });

  testWidgets('falls back to the illustration if the photo fails', (
    tester,
  ) async {
    // Network calls fail in widget tests, which exercises the error path.
    await tester.pumpWidget(
      _wrap(
        RecipeImageWidget(recipe: _recipe(imageUrl: 'http://x.invalid/a.jpg')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RecipeIllustrationWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('every category has an icon', () {
    for (final category in RecipeCategory.values) {
      expect(categoryIcon(category), isA<IconData>());
    }
  });
}
