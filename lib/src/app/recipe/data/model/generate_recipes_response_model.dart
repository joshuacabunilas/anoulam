// Body of `POST /recipes/generate`. Matches `GenerateRecipesResponse` and
// `Recipe` in backend/app/schemas.py.
//
// To parse this JSON data, do
//
//     final generateRecipesResponseModel = generateRecipesResponseModelFromJson(jsonString);

import 'dart:convert';

GenerateRecipesResponseModel generateRecipesResponseModelFromJson(String str) =>
    GenerateRecipesResponseModel.fromJson(
      json.decode(str) as Map<String, dynamic>,
    );

String generateRecipesResponseModelToJson(GenerateRecipesResponseModel data) =>
    json.encode(data.toJson());

class GenerateRecipesResponseModel {
  const GenerateRecipesResponseModel({required this.recipes});

  final List<RecipeModel> recipes;

  factory GenerateRecipesResponseModel.fromJson(Map<String, dynamic> json) =>
      GenerateRecipesResponseModel(
        recipes: List<RecipeModel>.from(
          (json['recipes'] as List<dynamic>).map(
            (x) => RecipeModel.fromJson(x as Map<String, dynamic>),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
    'recipes': List<dynamic>.from(recipes.map((x) => x.toJson())),
  };
}

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.usedIngredients,
    required this.missingIngredients,
    required this.steps,
    this.category = 'meat',
    this.imageUrl,
    this.imageCredit,
  });

  final String id;
  final String name;
  final String description;
  final int cookingTimeMinutes;
  final int servings;

  /// One of `easy`, `medium`, `hard`.
  final String difficulty;
  final List<String> usedIngredients;
  final List<String> missingIngredients;
  final List<String> steps;

  /// One of the `RecipeCategory` names, e.g. `rice`, `soup`.
  final String category;

  /// Absolute URL, or a path relative to the API base URL. Null if no photo.
  final String? imageUrl;
  final String? imageCredit;

  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    cookingTimeMinutes: (json['cooking_time_minutes'] as num).toInt(),
    servings: (json['servings'] as num).toInt(),
    difficulty: json['difficulty'] as String,
    usedIngredients: List<String>.from(json['used_ingredients'] as List),
    missingIngredients: List<String>.from(json['missing_ingredients'] as List),
    steps: List<String>.from(json['steps'] as List),
    category: json['category'] as String? ?? 'meat',
    imageUrl: json['image_url'] as String?,
    imageCredit: json['image_credit'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'cooking_time_minutes': cookingTimeMinutes,
    'servings': servings,
    'difficulty': difficulty,
    'used_ingredients': List<dynamic>.from(usedIngredients),
    'missing_ingredients': List<dynamic>.from(missingIngredients),
    'steps': List<dynamic>.from(steps),
    'category': category,
    'image_url': imageUrl,
    'image_credit': imageCredit,
  };

  /// Copy with a relative [imageUrl] resolved against [requestUri], the URL
  /// the recipe was fetched from. Absolute URLs are kept as they are.
  RecipeModel withImageUrlResolvedAgainst(Uri requestUri) {
    final url = imageUrl;
    if (url == null) return this;
    return RecipeModel(
      id: id,
      name: name,
      description: description,
      cookingTimeMinutes: cookingTimeMinutes,
      servings: servings,
      difficulty: difficulty,
      usedIngredients: usedIngredients,
      missingIngredients: missingIngredients,
      steps: steps,
      category: category,
      imageUrl: requestUri.resolve(url).toString(),
      imageCredit: imageCredit,
    );
  }
}
