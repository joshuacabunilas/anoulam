import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/domain/entities/ingredient_entities.dart';

void main() {
  test('key ignores case, spacing and plurals like the backend', () {
    const same = {
      'Egg': 'eggs',
      'Tomato': 'TOMATOES',
      'bay leaf': 'Bay   leaves',
      'chili': 'chillies',
      'berry': 'berries',
    };
    same.forEach((a, b) => expect(IngredientEntities.same(a, b), isTrue));
  });

  test('key leaves non-plural words alone', () {
    expect(IngredientEntities.key('glutinous rice'), 'glutinous rice');
    expect(IngredientEntities.key('hummus'), 'hummus');
    expect(IngredientEntities.key('glass noodles'), 'glass noodle');
  });
}
