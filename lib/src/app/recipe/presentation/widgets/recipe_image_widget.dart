import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

import '../../domain/entities/recipe_entities.dart';

/// The recipe's photo, or an illustration of its category when there is no
/// photo, while it loads, or if it fails to load. Purely decorative: the
/// recipe name next to it carries the meaning.
///
/// Photos are cached on disk (no re-download on every launch) and decoded
/// at the size they are shown, not their full 800 px.
class RecipeImageWidget extends StatelessWidget {
  const RecipeImageWidget({
    super.key,
    required this.recipe,
    this.iconSize = 48,
  });

  /// Overrides the disk cache, e.g. with a fake in tests.
  @visibleForTesting
  static BaseCacheManager? cacheManager;

  final RecipeEntities recipe;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = recipe.imageUrl;
    final illustration = RecipeIllustrationWidget(
      category: recipe.category,
      iconSize: iconSize,
    );
    if (url == null) return ExcludeSemantics(child: illustration);

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) => CachedNetworkImage(
          imageUrl: url,
          cacheManager: cacheManager,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: constraints.hasBoundedWidth
              ? (constraints.maxWidth * pixelRatio).round()
              : null,
          // The illustration shows until the photo arrives, then the photo
          // fades in, instantly when the system's "Remove animations" is on.
          placeholder: (_, _) => illustration,
          errorWidget: (_, _, _) => illustration,
          fadeInDuration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 250),
          fadeOutDuration: Duration.zero,
        ),
      ),
    );
  }
}

/// The recipe's category on its produce tint with a large icon.
class RecipeIllustrationWidget extends StatelessWidget {
  const RecipeIllustrationWidget({
    super.key,
    required this.category,
    this.iconSize = 48,
  });

  final RecipeCategory category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final background = category.tint(context);
    final foreground = FoodTints.of(context).onTint;
    final icon = categoryIcon(category);
    return ClipRect(
      child: ColoredBox(
        color: background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Large faded icon in the corner for texture.
            Positioned(
              right: -iconSize * 0.4,
              bottom: -iconSize * 0.5,
              child: Icon(
                icon,
                size: iconSize * 2.6,
                color: foreground.withValues(alpha: 0.12),
              ),
            ),
            Center(
              child: Icon(
                icon,
                size: iconSize,
                color: foreground.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension RecipeCategoryTint on RecipeCategory {
  /// The produce tint this kind of dish shares with its pantry category:
  /// meat, seafood, eggs, greens (vegetables, soups), fruit (drinks),
  /// grains (rice, noodles, bread), sauces (snacks), baking (desserts).
  Color tint(BuildContext context) {
    final tints = FoodTints.of(context);
    return tints.at(switch (this) {
      RecipeCategory.meat => 0,
      RecipeCategory.seafood => 1,
      RecipeCategory.egg => 2,
      RecipeCategory.vegetable || RecipeCategory.soup => 3,
      RecipeCategory.drink => 4,
      RecipeCategory.rice ||
      RecipeCategory.noodles ||
      RecipeCategory.bread => 5,
      RecipeCategory.snack => 6,
      RecipeCategory.dessert => 8,
    });
  }
}

IconData categoryIcon(RecipeCategory category) => switch (category) {
  RecipeCategory.rice => Icons.rice_bowl,
  RecipeCategory.noodles => Icons.ramen_dining,
  RecipeCategory.soup => Icons.soup_kitchen,
  RecipeCategory.egg => Icons.egg_alt,
  RecipeCategory.meat => Icons.kebab_dining,
  RecipeCategory.seafood => Icons.set_meal,
  RecipeCategory.vegetable => Icons.eco,
  RecipeCategory.bread => Icons.bakery_dining,
  RecipeCategory.dessert => Icons.cake,
  RecipeCategory.drink => Icons.local_drink,
  RecipeCategory.snack => Icons.lunch_dining,
};
