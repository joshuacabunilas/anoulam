import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/ingredient_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

import '../../domain/entities/ingredient_entities.dart';

/// The basket pinned at the bottom of the ingredients page: the first few
/// ingredients as round category badges, how many there are, and the
/// button that finds recipes. With large text the button moves under the
/// basket and takes the full width, so nothing is squeezed.
class BasketBarWidget extends StatelessWidget {
  const BasketBarWidget({
    super.key,
    required this.ingredients,
    required this.onSubmit,
  });

  /// Badges shown before the rest collapse into "+N".
  static const _shown = 3;
  static const _badgeSize = 32.0;

  final List<String> ingredients;

  /// Null while the basket is empty.
  final VoidCallback? onSubmit;

  /// The pantry category [name] belongs to, if it's a known ingredient.
  static (int, IngredientGroup)? _groupOf(String name) {
    final key = IngredientEntities.key(name);
    for (final (index, group) in IngredientHelper.groups.indexed) {
      if (group.ingredients.any((n) => IngredientEntities.key(n) == key)) {
        return (index, group);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tints = FoodTints.of(context);
    final empty = ingredients.isEmpty;
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final info = Row(
      children: [
        const SizedBox(width: AppSpacing.xs),
        if (empty)
          ExcludeSemantics(
            child: Icon(
              Icons.shopping_basket_outlined,
              color: scheme.onInverseSurface,
            ),
          )
        else
          // Overlapping badges, each in its category's tint.
          ExcludeSemantics(
            child: SizedBox(
              height: _badgeSize,
              width:
                  _badgeSize +
                  (ingredients.take(_shown).length - 1) * (_badgeSize * 0.7),
              child: Stack(
                children: [
                  for (final (i, name) in ingredients.take(_shown).indexed)
                    Positioned(
                      left: i * _badgeSize * 0.7,
                      child: _Badge(
                        size: _badgeSize,
                        group: _groupOf(name),
                        tints: tints,
                        ring: scheme.inverseSurface,
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empty
                      ? StringHelper.basketEmpty
                      : StringHelper.basketCount(ingredients.length),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onInverseSurface,
                  ),
                ),
                Text(
                  empty ? StringHelper.basketEmptyHint : ingredients.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onInverseSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    final button = FilledButton(
      onPressed: onSubmit,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        backgroundColor: scheme.brightness == Brightness.light
            ? scheme.inversePrimary
            : scheme.primary,
        foregroundColor: scheme.brightness == Brightness.light
            ? scheme.inverseSurface
            : scheme.onPrimary,
        disabledBackgroundColor: scheme.onInverseSurface.withValues(
          alpha: 0.15,
        ),
        disabledForegroundColor: scheme.onInverseSurface.withValues(alpha: 0.6),
      ),
      child: const Text(StringHelper.seeRecipes),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: stacked
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  info,
                  const SizedBox(height: AppSpacing.sm),
                  button,
                ],
              )
            : Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppSpacing.sm),
                  button,
                ],
              ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.size,
    required this.group,
    required this.tints,
    required this.ring,
  });

  final double size;
  final (int, IngredientGroup)? group;
  final FoodTints tints;

  /// Separates overlapping badges.
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final group = this.group;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: group == null ? tints.at(3) : tints.at(group.$1),
        border: Border.all(color: ring, width: 2),
      ),
      child: Icon(
        group?.$2.icon ?? Icons.kitchen,
        size: size * 0.5,
        color: tints.onTint,
      ),
    );
  }
}
