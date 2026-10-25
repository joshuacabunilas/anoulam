import 'package:dio/dio.dart';
import 'package:mobile/src/common/constant/api_helper.dart';

import 'package:mobile/src/app/recipe/data/data_source/recipe_remote_data_source.dart';
import 'package:mobile/src/app/recipe/data/model/generate_recipes_response_model.dart';

/// Test stand-in for the backend: answers like the real API from a small
/// hardcoded catalog, returning a [Response] whose JSON body has the same
/// shape as `POST /recipes/generate`, so the repository's parsing runs in
/// tests too. Never shipped in the app.
class FakeRecipeRemoteDataSource implements RecipeRemoteDataSource {
  const FakeRecipeRemoteDataSource();

  static const _maxResults = 20;

  @override
  Future<Response> generateRecipes(Map<String, dynamic> mapData) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final ingredients = (mapData['ingredients'] as List<dynamic>)
        .cast<String>();

    final have = ingredients.map(_normalize).toSet();
    final matches = <RecipeModel>[];
    for (final recipe in _catalog) {
      final needed = recipe.ingredients;
      final used = needed.where((i) => have.contains(_normalize(i))).toList();
      if (used.isEmpty) continue;
      matches.add(
        RecipeModel(
          id: recipe.id,
          name: recipe.name,
          description: recipe.description,
          cookingTimeMinutes: recipe.minutes,
          servings: recipe.servings,
          difficulty: recipe.difficulty,
          usedIngredients: used,
          missingIngredients: needed.where((i) => !used.contains(i)).toList(),
          steps: recipe.steps,
          category: recipe.category,
        ),
      );
    }
    matches.sort((a, b) {
      final byMissing = a.missingIngredients.length.compareTo(
        b.missingIngredients.length,
      );
      if (byMissing != 0) return byMissing;
      return b.usedIngredients.length.compareTo(a.usedIngredients.length);
    });
    return Response(
      requestOptions: RequestOptions(
        path: '${ApiHelper.baseUrl}${ApiHelper.generateRecipes}',
        method: 'POST',
        data: mapData,
      ),
      statusCode: 200,
      data: GenerateRecipesResponseModel(
        recipes: matches.take(_maxResults).toList(),
      ).toJson(),
    );
  }

  /// Lowercases and drops a plural "s" so "Eggs" matches "egg".
  static String _normalize(String ingredient) {
    final value = ingredient.trim().toLowerCase();
    return value.length > 3 && value.endsWith('s')
        ? value.substring(0, value.length - 1)
        : value;
  }

  static const _catalog = [
    _FakeRecipe(
      id: 'egg-fried-rice',
      category: 'rice',
      name: 'Egg Fried Rice',
      description: 'Quick wok-fried rice with scrambled egg and soy sauce.',
      minutes: 15,
      servings: 2,
      difficulty: 'easy',
      ingredients: ['rice', 'egg', 'soy sauce', 'garlic', 'green onion'],
      steps: [
        'Heat oil in a pan and saute minced garlic until fragrant.',
        'Push the garlic aside, scramble the eggs, then break them up.',
        'Add the cooked rice and stir-fry for 3 to 4 minutes.',
        'Season with soy sauce, toss, and top with green onion.',
      ],
    ),
    _FakeRecipe(
      id: 'chicken-adobo',
      category: 'meat',
      name: 'Chicken Adobo',
      description:
          'Chicken braised in vinegar, soy sauce, garlic and bay leaf.',
      minutes: 45,
      servings: 4,
      difficulty: 'easy',
      ingredients: [
        'chicken',
        'soy sauce',
        'vinegar',
        'garlic',
        'bay leaf',
        'peppercorn',
      ],
      steps: [
        'Marinate the chicken in soy sauce and garlic for 15 minutes.',
        'Brown the chicken in a pot with a little oil.',
        'Add the marinade, vinegar, bay leaves and peppercorns.',
        'Simmer covered for 30 minutes until the chicken is tender.',
        'Uncover and reduce the sauce to your liking.',
      ],
    ),
    _FakeRecipe(
      id: 'tomato-omelette',
      category: 'egg',
      name: 'Tomato Omelette',
      description: 'Fluffy omelette with fresh tomato and onion.',
      minutes: 10,
      servings: 1,
      difficulty: 'easy',
      ingredients: ['egg', 'tomato', 'onion'],
      steps: [
        'Dice the tomato and onion.',
        'Beat the eggs with a pinch of salt.',
        'Saute the onion, add the tomato, then pour in the eggs.',
        'Cook until set, fold, and serve.',
      ],
    ),
    _FakeRecipe(
      id: 'garlic-butter-pasta',
      category: 'noodles',
      name: 'Garlic Butter Pasta',
      description: 'Simple pasta tossed in garlic butter and cheese.',
      minutes: 20,
      servings: 2,
      difficulty: 'easy',
      ingredients: ['pasta', 'butter', 'garlic', 'cheese'],
      steps: [
        'Cook the pasta in salted water until al dente.',
        'Melt butter in a pan and gently cook sliced garlic.',
        'Toss in the drained pasta with a splash of pasta water.',
        'Finish with grated cheese.',
      ],
    ),
    _FakeRecipe(
      id: 'chicken-tinola',
      category: 'soup',
      name: 'Chicken Tinola',
      description: 'Light ginger chicken soup with green papaya.',
      minutes: 40,
      servings: 4,
      difficulty: 'medium',
      ingredients: [
        'chicken',
        'ginger',
        'onion',
        'garlic',
        'papaya',
        'fish sauce',
      ],
      steps: [
        'Saute garlic, onion and sliced ginger.',
        'Add the chicken and cook until lightly browned.',
        'Season with fish sauce, add water and simmer for 20 minutes.',
        'Add the papaya and cook until tender.',
      ],
    ),
    _FakeRecipe(
      id: 'beef-stir-fry',
      category: 'meat',
      name: 'Beef and Vegetable Stir-Fry',
      description: 'Tender beef strips with crisp vegetables.',
      minutes: 25,
      servings: 3,
      difficulty: 'medium',
      ingredients: [
        'beef',
        'bell pepper',
        'onion',
        'garlic',
        'soy sauce',
        'carrot',
      ],
      steps: [
        'Slice the beef thinly and toss with a little soy sauce.',
        'Sear the beef over high heat, then set aside.',
        'Stir-fry garlic, onion, carrot and bell pepper.',
        'Return the beef, add the remaining soy sauce, and toss.',
      ],
    ),
    _FakeRecipe(
      id: 'potato-soup',
      category: 'soup',
      name: 'Creamy Potato Soup',
      description: 'Comforting soup of potato, onion and milk.',
      minutes: 35,
      servings: 4,
      difficulty: 'easy',
      ingredients: ['potato', 'onion', 'milk', 'butter', 'garlic'],
      steps: [
        'Melt butter and soften the onion and garlic.',
        'Add diced potatoes and enough water to cover.',
        'Simmer until the potatoes are soft, about 20 minutes.',
        'Mash or blend, stir in the milk, and season.',
      ],
    ),
    _FakeRecipe(
      id: 'banana-pancakes',
      category: 'bread',
      name: 'Banana Pancakes',
      description: 'Soft pancakes sweetened with ripe banana.',
      minutes: 20,
      servings: 2,
      difficulty: 'easy',
      ingredients: ['banana', 'egg', 'flour', 'milk', 'sugar'],
      steps: [
        'Mash the banana and whisk in the egg and milk.',
        'Stir in the flour and sugar until just combined.',
        'Cook ladlefuls on a greased pan until bubbles form, then flip.',
      ],
    ),
  ];
}

class _FakeRecipe {
  const _FakeRecipe({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.minutes,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String category;
  final String name;
  final String description;
  final int minutes;
  final int servings;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
}
