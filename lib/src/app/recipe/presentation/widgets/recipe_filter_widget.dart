import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';
import 'package:mobile/src/common/widgets/toggle_chip_widget.dart';

import '../../domain/entities/recipe_entities.dart';
import '../../domain/entities/recipe_filter_entities.dart';
import 'recipe_image_widget.dart';
import 'recipe_meta_row_widget.dart';

/// Filter toggles plus a dish-type picker for the recipe results.
class RecipeFilterWidget extends StatelessWidget {
  const RecipeFilterWidget({
    super.key,
    required this.filter,
    required this.availableCategories,
    required this.onChanged,
  });

  final RecipeFilterEntities filter;

  /// Dish types present in the results, in display order.
  final List<RecipeCategory> availableCategories;
  final ValueChanged<RecipeFilterEntities> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _toggle(
              label: StringHelper.filterReadyToCook,
              icon: Icons.check_circle_outline,
              selected: filter.readyToCook,
              onSelected: (v) => onChanged(filter.copyWith(readyToCook: v)),
            ),
            _toggle(
              label: StringHelper.filterQuick,
              icon: Icons.schedule,
              selected: filter.quick,
              onSelected: (v) => onChanged(filter.copyWith(quick: v)),
            ),
            _toggle(
              label: StringHelper.filterEasy,
              icon: Icons.signal_cellular_alt_1_bar,
              selected: filter.easy,
              onSelected: (v) => onChanged(filter.copyWith(easy: v)),
            ),
            _toggle(
              label: StringHelper.filterVegetarian,
              icon: Icons.eco_outlined,
              selected: filter.vegetarian,
              onSelected: (v) => onChanged(filter.copyWith(vegetarian: v)),
            ),
          ],
        ),
        if (availableCategories.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                showCheckmark: false,
                label: const Text(StringHelper.allDishTypes),
                selected: filter.category == null,
                onSelected: (_) =>
                    onChanged(filter.copyWith(category: () => null)),
              ),
              for (final category in availableCategories)
                ChoiceChip(
                  showCheckmark: false,
                  avatar: ExcludeSemantics(
                    child: Icon(categoryIcon(category), size: 18),
                  ),
                  label: Text(category.label),
                  selected: filter.category == category,
                  onSelected: (selected) => onChanged(
                    filter.copyWith(category: () => selected ? category : null),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _toggle({
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ToggleChipWidget(
      label: label,
      icon: icon,
      selected: selected,
      onSelected: onSelected,
    );
  }
}
