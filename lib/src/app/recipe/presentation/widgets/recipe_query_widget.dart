import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

/// One line summarising the searched ingredients, with an Edit action, so
/// the results page never makes the user remember what they asked for.
class RecipeQueryWidget extends StatelessWidget {
  const RecipeQueryWidget({
    super.key,
    required this.ingredients,
    required this.onEdit,
  });

  /// How many names to show before "+N".
  static const _shown = 3;

  final List<String> ingredients;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = ingredients.take(_shown).join(', ');
    final extra = ingredients.length - _shown;
    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(Icons.kitchen_outlined, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            StringHelper.usingIngredients(shown, extra > 0 ? extra : 0),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            semanticsLabel: StringHelper.usingIngredients(
              ingredients.join(', '),
              0,
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: onEdit,
          // Visible "Edit" reads clearly next to the list; screen readers
          // hear what is being edited.
          child: const Text(
            StringHelper.editIngredients,
            semanticsLabel: StringHelper.editIngredientsAction,
          ),
        ),
      ],
    );
  }
}
