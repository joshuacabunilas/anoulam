import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/recipe/domain/entities/recipe_entities.dart';
import '../app/recipe/presentation/pages/ingredients_page.dart';
import '../app/recipe/presentation/pages/recipe_detail_page.dart';
import '../app/recipe/presentation/pages/recipe_results_page.dart';
import 'app_route_name.dart';

/// Pass page arguments as a map in `extra`, e.g.
/// `context.push(AppRouteName.recipes, extra: {"data": ingredients})`.
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [routeObserver],
    initialLocation: AppRouteName.ingredients,
    routes: [
      GoRoute(
        name: 'Ingredients Page',
        path: AppRouteName.ingredients,
        builder: (context, state) => const IngredientsPage(),
      ),
      GoRoute(
        name: 'Recipe Results Page',
        path: AppRouteName.recipes,
        builder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          return RecipeResultsPage(ingredients: data['data'] as List<String>);
        },
      ),
      GoRoute(
        name: 'Recipe Detail Page',
        path: AppRouteName.recipeDetail,
        builder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          return RecipeDetailPage(recipe: data['data'] as RecipeEntities);
        },
      ),
    ],
  );
}
