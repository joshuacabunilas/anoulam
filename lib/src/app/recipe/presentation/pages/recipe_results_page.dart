import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/get_it_configuration/get_it_configuration.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';
import 'package:mobile/src/common/widgets/content_width_widget.dart';
import 'package:mobile/src/common/widgets/state_message_widget.dart';
import 'package:mobile/src/routes/app_route_name.dart';

import '../../domain/entities/recipe_entities.dart';
import '../../domain/entities/recipe_filter_entities.dart';
import '../bloc/generate_recipes/generate_recipes_bloc.dart';
import '../bloc/recipe_filter/recipe_filter_bloc.dart';
import '../widgets/finding_recipes_widget.dart';
import '../widgets/recipe_card_widget.dart';
import '../widgets/recipe_filter_widget.dart';
import '../widgets/recipe_query_widget.dart';

class RecipeResultsPage extends StatelessWidget {
  const RecipeResultsPage({super.key, required this.ingredients});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<GenerateRecipesBloc>()
                ..add(GenerateRecipesRequested(ingredients)),
        ),
        BlocProvider(
          create: (_) =>
              getIt<RecipeFilterBloc>()..add(const RecipeFilterStarted()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text(StringHelper.recipesTitle)),
        body: BlocBuilder<GenerateRecipesBloc, GenerateRecipesState>(
          builder: (context, state) => switch (state) {
            GenerateRecipesInitial() || GenerateRecipesLoading() =>
              FindingRecipesWidget(onCancel: () => context.pop()),
            GenerateRecipesFailure(:final failure) => StateMessageWidget(
              icon: Icons.error_outline,
              title: StringHelper.recipesErrorTitle,
              message: failure.message,
              actionLabel: StringHelper.retry,
              onAction: () => context.read<GenerateRecipesBloc>().add(
                GenerateRecipesRequested(ingredients),
              ),
            ),
            GenerateRecipesSuccess(:final recipes) when recipes.isEmpty =>
              StateMessageWidget(
                icon: Icons.no_food_outlined,
                title: StringHelper.noRecipesTitle,
                message: StringHelper.noRecipesMessage,
                actionLabel: StringHelper.editIngredientsAction,
                onAction: () => context.pop(),
              ),
            GenerateRecipesSuccess(:final recipes) => _RecipeResultsList(
              ingredients: ingredients,
              recipes: recipes,
            ),
          },
        ),
      ),
    );
  }
}

/// The search summary, filters and recipe list. Filtering happens on the
/// phone, instantly.
class _RecipeResultsList extends StatelessWidget {
  const _RecipeResultsList({required this.ingredients, required this.recipes});

  final List<String> ingredients;
  final List<RecipeEntities> recipes;

  /// Dish types present in the results, most common first.
  List<RecipeCategory> get _categories {
    final counts = <RecipeCategory, int>{};
    for (final recipe in recipes) {
      counts.update(recipe.category, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<RecipeFilterBloc, RecipeFilterState>(
      builder: (context, filterState) {
        final filter = filterState.filter;
        final shown = filter.apply(recipes);
        void setFilter(RecipeFilterEntities f) =>
            context.read<RecipeFilterBloc>().add(RecipeFilterChanged(f));
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RecipeQueryWidget(
              ingredients: ingredients,
              onEdit: () => context.pop(),
            ),
            const SizedBox(height: AppSpacing.md),
            RecipeFilterWidget(
              filter: filter,
              availableCategories: _categories,
              onChanged: setFilter,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Announced so screen reader users hear the effect of a filter.
            Semantics(
              liveRegion: true,
              child: Text(
                StringHelper.showingCount(shown.length, recipes.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
        // Item 0 is the header; the rest are cards, built only as they
        // scroll into view so off-screen photos don't load up front.
        return SafeArea(
          child: ContentWidthWidget(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              itemCount: 1 + (shown.isEmpty ? 1 : shown.length),
              itemBuilder: (context, index) {
                if (index == 0) return header;
                if (shown.isEmpty) {
                  return StateMessageWidget(
                    icon: Icons.filter_alt_off_outlined,
                    title: StringHelper.noFilterMatchTitle,
                    message: StringHelper.noFilterMatchMessage,
                    actionLabel: StringHelper.clearFilters,
                    onAction: () => setFilter(const RecipeFilterEntities()),
                  );
                }
                final recipe = shown[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: RecipeCardWidget(
                    key: ValueKey(recipe.id),
                    recipe: recipe,
                    onTap: () => context.push(
                      AppRouteName.recipeDetail,
                      extra: {'data': recipe},
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
