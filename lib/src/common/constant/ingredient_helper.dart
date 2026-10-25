import 'package:flutter/material.dart';

/// A group of ingredients in the "Browse ingredients" checklist.
class IngredientGroup {
  const IngredientGroup({
    required this.name,
    required this.icon,
    required this.ingredients,
  });

  final String name;
  final IconData icon;
  final List<String> ingredients;
}

/// Every ingredient the recipe database uses, grouped for browsing. Each
/// name matches at least one recipe on the backend (checked against
/// backend/data/recipes.json); update this list when adding recipes with
/// new ingredients.
class IngredientHelper {
  IngredientHelper._();

  static const List<IngredientGroup> groups = [
    IngredientGroup(
      name: 'Meat & protein',
      icon: Icons.kebab_dining,
      ingredients: ['Chicken', 'Pork', 'Beef', 'Bacon', 'Hotdog', 'Tofu'],
    ),
    IngredientGroup(
      name: 'Seafood',
      icon: Icons.set_meal,
      ingredients: ['Fish', 'Shrimp', 'Salmon', 'Tuna'],
    ),
    IngredientGroup(
      name: 'Eggs & dairy',
      icon: Icons.egg_alt,
      ingredients: [
        'Eggs',
        'Milk',
        'Butter',
        'Cheese',
        'Cream',
        'Yogurt',
        'Condensed milk',
        'Evaporated milk',
      ],
    ),
    IngredientGroup(
      name: 'Vegetables',
      icon: Icons.eco,
      ingredients: [
        'Onion',
        'Garlic',
        'Tomatoes',
        'Potatoes',
        'Carrots',
        'Cabbage',
        'Bell pepper',
        'Eggplant',
        'Green onion',
        'String beans',
        'Spinach',
        'Kangkong',
        'Broccoli',
        'Celery',
        'Lettuce',
        'Cucumber',
        'Squash',
        'Mushrooms',
        'Bok choy',
        'Radish',
        'Okra',
        'Bitter melon',
        'Zucchini',
        'Corn',
        'Peas',
        'Bean sprouts',
        'Avocado',
      ],
    ),
    IngredientGroup(
      name: 'Fruits',
      icon: Icons.apple,
      ingredients: [
        'Bananas',
        'Mangoes',
        'Lemon',
        'Lime',
        'Calamansi',
        'Apples',
        'Pineapple',
        'Papaya',
      ],
    ),
    IngredientGroup(
      name: 'Rice, noodles & bread',
      icon: Icons.rice_bowl,
      ingredients: [
        'Rice',
        'Glutinous rice',
        'Pasta',
        'Macaroni',
        'Noodles',
        'Rice noodles',
        'Glass noodles',
        'Instant noodles',
        'Bread',
        'Tortillas',
        'Burger buns',
        'Oats',
        'Flour',
        'Spring roll wrappers',
        'Rice paper',
        'Breadcrumbs',
      ],
    ),
    IngredientGroup(
      name: 'Sauces & condiments',
      icon: Icons.water_drop,
      ingredients: [
        'Soy sauce',
        'Vinegar',
        'Fish sauce',
        'Ketchup',
        'Banana ketchup',
        'Tomato sauce',
        'Mayonnaise',
        'Shrimp paste',
        'Coconut milk',
        'Peanut butter',
        'Honey',
        'Sesame oil',
        'Olive oil',
        'Chili bean paste',
        'Green curry paste',
        'Miso',
        'Liver spread',
        'Chicken broth',
        'Kimchi',
      ],
    ),
    IngredientGroup(
      name: 'Herbs & spices',
      icon: Icons.grass,
      ingredients: [
        'Ginger',
        'Chili',
        'Bay leaves',
        'Peppercorns',
        'Basil',
        'Lemongrass',
        'Curry powder',
        'Garam masala',
        'Cumin',
        'Turmeric',
        'Chili powder',
        'Tamarind',
      ],
    ),
    IngredientGroup(
      name: 'Baking & pantry',
      icon: Icons.kitchen,
      ingredients: [
        'Sugar',
        'Brown sugar',
        'Baking powder',
        'Baking soda',
        'Cocoa',
        'Chocolate chips',
        'Cornstarch',
        'Peanuts',
        'Chickpeas',
        'Lentils',
        'Kidney beans',
        'Mung beans',
        'Graham crackers',
        'Fruit cocktail',
        'Seaweed',
      ],
    ),
  ];
}
