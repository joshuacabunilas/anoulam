import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/ingredient_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

/// The market: one soft produce-tinted tile per pantry category, three to
/// a row (two with large text). A green count badge marks categories with
/// something in the basket, so every pick stays in sight.
class IngredientShelfWidget extends StatelessWidget {
  const IngredientShelfWidget({
    super.key,
    required this.groups,
    required this.selectedCount,
    required this.onOpen,
  });

  final List<IngredientGroup> groups;

  /// How many of a group's ingredients are in the basket.
  final int Function(IngredientGroup group) selectedCount;
  final ValueChanged<IngredientGroup> onOpen;

  /// Shortest a tile gets, so the shelf reads as squares.
  static const _minTileHeight = 92.0;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2 : 3;
    final indexed = groups.indexed.toList();
    final rows = [
      for (var i = 0; i < indexed.length; i += columns)
        indexed.sublist(i, (i + columns).clamp(0, indexed.length)),
    ];
    return Column(
      children: [
        for (final (rowIndex, row) in rows.indexed) ...[
          if (rowIndex > 0) const SizedBox(height: AppSpacing.sm),
          // Tiles in a row share the tallest one's height.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: i < row.length
                        ? _Tile(
                            group: row[i].$2,
                            tint: FoodTints.of(context).at(row[i].$1),
                            count: selectedCount(row[i].$2),
                            minHeight: _minTileHeight,
                            onTap: () => onOpen(row[i].$2),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.group,
    required this.tint,
    required this.count,
    required this.minHeight,
    required this.onTap,
  });

  final IngredientGroup group;
  final Color tint;
  final int count;
  final double minHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = FoodTints.of(context).onTint;
    final status = count > 0
        ? StringHelper.selectedCount(count)
        : StringHelper.itemCount(group.ingredients.length);
    return Semantics(
      button: true,
      label: '${group.name}, $status',
      excludeSemantics: true,
      child: Material(
        color: tint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          // A green ring joins the badge on tiles with picks.
          side: count > 0
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md - 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(group.icon, size: 24, color: ink),
                      const SizedBox(height: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            StringHelper.itemCount(group.ingredients.length),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ink.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (count > 0)
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    end: AppSpacing.sm,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        '$count',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
