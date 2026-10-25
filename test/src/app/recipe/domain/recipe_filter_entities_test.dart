import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_filter_entities.dart';

RecipeEntities _recipe(
  String id, {
  int minutes = 20,
  RecipeDifficulty difficulty = RecipeDifficulty.easy,
  List<String> used = const ['egg'],
  List<String> missing = const [],
  RecipeCategory category = RecipeCategory.egg,
}) => RecipeEntities(
  id: id,
  name: id,
  description: '',
  cookingTimeMinutes: minutes,
  servings: 1,
  difficulty: difficulty,
  usedIngredients: used,
  missingIngredients: missing,
  steps: const ['Cook.'],
  category: category,
);

void main() {
  final omelette = _recipe('omelette');
  final adobo = _recipe(
    'adobo',
    minutes: 45,
    used: const ['chicken', 'soy sauce'],
    missing: const ['vinegar'],
    category: RecipeCategory.meat,
  );
  final kareKare = _recipe(
    'kare-kare',
    minutes: 120,
    difficulty: RecipeDifficulty.hard,
    used: const ['eggplant'],
    missing: const ['beef', 'shrimp paste'],
    category: RecipeCategory.meat,
  );
  final champorado = _recipe(
    'champorado',
    minutes: 30,
    used: const ['milk'],
    missing: const ['glutinous rice'],
    category: RecipeCategory.rice,
  );
  final all = [omelette, adobo, kareKare, champorado];

  List<String> ids(RecipeFilterEntities f) =>
      f.apply(all).map((r) => r.id).toList();

  test('an empty filter keeps everything', () {
    const filter = RecipeFilterEntities();
    expect(filter.isEmpty, isTrue);
    expect(ids(filter), ['omelette', 'adobo', 'kare-kare', 'champorado']);
  });

  test('ready to cook keeps recipes with nothing missing', () {
    expect(ids(const RecipeFilterEntities(readyToCook: true)), ['omelette']);
  });

  test('under 30 min includes exactly 30', () {
    expect(ids(const RecipeFilterEntities(quick: true)), [
      'omelette',
      'champorado',
    ]);
  });

  test('easy drops medium and hard recipes', () {
    expect(ids(const RecipeFilterEntities(easy: true)), [
      'omelette',
      'adobo',
      'champorado',
    ]);
  });

  test('vegetarian checks used and missing ingredients', () {
    // Kare-kare is out because a missing ingredient (beef) is meat.
    expect(ids(const RecipeFilterEntities(vegetarian: true)), [
      'omelette',
      'champorado',
    ]);
  });

  test('dish type and other filters combine (AND)', () {
    expect(ids(const RecipeFilterEntities(category: RecipeCategory.meat)), [
      'adobo',
      'kare-kare',
    ]);
    expect(
      ids(
        const RecipeFilterEntities(category: RecipeCategory.meat, easy: true),
      ),
      ['adobo'],
    );
  });

  test('copyWith can clear the dish type', () {
    const filter = RecipeFilterEntities(category: RecipeCategory.rice);
    expect(filter.copyWith(category: () => null).category, isNull);
    expect(filter.copyWith(easy: true).category, RecipeCategory.rice);
  });
}
