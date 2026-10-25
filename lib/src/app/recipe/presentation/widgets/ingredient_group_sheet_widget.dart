import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/ingredient_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';
import 'package:mobile/src/common/widgets/toggle_chip_widget.dart';

import '../../domain/entities/ingredient_entities.dart';

/// Contents of the bottom sheet for one pantry category: its ingredients
/// as tick chips, and Done.
class IngredientGroupSheetWidget extends StatelessWidget {
  const IngredientGroupSheetWidget({
    super.key,
    required this.group,
    required this.isSelected,
    required this.isFull,
    required this.onChanged,
  });

  final IngredientGroup group;
  final bool Function(String name) isSelected;

  /// The list is at its limit: unticked chips can't be added.
  final bool isFull;
  final void Function(String name, {required bool selected}) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = group.ingredients.where(isSelected).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(group.name, style: theme.textTheme.headlineSmall),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                count == 0
                    ? StringHelper.itemCount(group.ingredients.length)
                    : StringHelper.selectedCount(count),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: count == 0
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                  fontWeight: count == 0 ? null : FontWeight.w800,
                ),
              ),
            ],
          ),
          if (isFull) ...[
            const SizedBox(height: AppSpacing.sm),
            // Snackbars would sit behind the sheet, so say it here.
            Semantics(
              liveRegion: true,
              child: Text(
                StringHelper.listFull(IngredientEntities.maxCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final name in group.ingredients)
                    ToggleChipWidget(
                      label: name,
                      selected: isSelected(name),
                      onSelected: (selected) =>
                          onChanged(name, selected: selected),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(StringHelper.done),
          ),
        ],
      ),
    );
  }
}
