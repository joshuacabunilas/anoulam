import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/presentation/pages/recipe_detail_page.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/recipe_image_widget.dart';
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
);

Future<void> _pump(WidgetTester tester, Size screen) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const RecipeDetailPage(recipe: _recipe),
    ),
  );
}

void main() {
  testWidgets('back button keeps a 48 dp touch target', (tester) async {
    await _pump(tester, const Size(390, 844));

    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('header is 280 tall on a portrait phone', (tester) async {
    await _pump(tester, const Size(390, 844));

    expect(tester.getSize(find.byType(RecipeImageWidget)).height, 280);
  });

  testWidgets('header shrinks on a landscape phone', (tester) async {
    await _pump(tester, const Size(844, 390));

    // 40% of 390 = 156, leaving room for the recipe below.
    expect(tester.getSize(find.byType(RecipeImageWidget)).height, 156);
  });

  testWidgets('photo appears without a fade when animations are off', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(
            child: SizedBox(
              width: 300,
              height: 150,
              child: RecipeImageWidget(
                recipe: RecipeEntities(
                  id: 'x',
                  name: 'X',
                  description: '',
                  cookingTimeMinutes: 1,
                  servings: 1,
                  difficulty: RecipeDifficulty.easy,
                  usedIngredients: [],
                  missingIngredients: [],
                  steps: ['s'],
                  imageUrl: 'http://x.invalid/a.jpg',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.fadeInDuration, Duration.zero);
    // Decoded at the displayed width, not the photo's full 800 px.
    expect(image.memCacheWidth, 300);
  });
}
