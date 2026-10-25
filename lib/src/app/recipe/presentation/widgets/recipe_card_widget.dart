import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

import '../../domain/entities/recipe_entities.dart';
import 'recipe_image_widget.dart';
import 'recipe_meta_row_widget.dart';

/// A recipe as a rounded photo card: the photo with an availability badge
/// on it, then the name, time and difficulty, and what's missing.
class RecipeCardWidget extends StatelessWidget {
  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  final RecipeEntities recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final missing = recipe.missingIngredients;
    return DecoratedBox(
      // A soft lift off the white page.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImageWidget(recipe: recipe, iconSize: 56),
                    Positioned(
                      left: AppSpacing.sm + 2,
                      top: AppSpacing.sm + 2,
                      right: AppSpacing.sm + 2,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AvailabilityBadgeWidget(recipe: recipe),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${StringHelper.minutes(recipe.cookingTimeMinutes)}'
                      ' · ${recipe.difficulty.label}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        StringHelper.needsNamed(missing),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White pill on the photo: "Ready to cook" or "Missing N ingredients".
/// Icon and wording differ per state, so colour is never the only signal.
class AvailabilityBadgeWidget extends StatelessWidget {
  const AvailabilityBadgeWidget({super.key, required this.recipe});

  final RecipeEntities recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ready = recipe.canCookNow;
    final color = ready ? scheme.tertiary : scheme.secondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - 2,
          vertical: AppSpacing.xs + 1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                ready ? Icons.check_circle : Icons.add_shopping_cart,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Flexible(
              child: Text(
                ready
                    ? StringHelper.canCookNow
                    : StringHelper.missingCount(
                        recipe.missingIngredients.length,
                      ),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
