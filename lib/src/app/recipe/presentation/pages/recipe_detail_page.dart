import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';
import 'package:mobile/src/common/widgets/content_width_widget.dart';

import '../../domain/entities/recipe_entities.dart';
import '../widgets/recipe_image_widget.dart';
import '../widgets/recipe_meta_row_widget.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key, required this.recipe});

  final RecipeEntities recipe;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  /// Header height: 40% of the screen, at most 280. Keeps the recipe in
  /// view on short screens such as a phone in landscape.
  static const _maxHeaderHeight = 280.0;
  static const _headerScreenFraction = 0.4;

  /// The rounded top edge of the page, drawn over the photo's bottom.
  static const _sheetLip = 24.0;

  double _headerHeight(BuildContext context) =>
      (MediaQuery.sizeOf(context).height * _headerScreenFraction).clamp(
        kToolbarHeight + MediaQuery.paddingOf(context).top + _sheetLip,
        _maxHeaderHeight,
      );

  final _scrollController = ScrollController();
  var _collapsed = false;

  RecipeEntities get recipe => widget.recipe;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final topInset = MediaQuery.paddingOf(context).top;
    final collapsed =
        _scrollController.offset >=
        _headerHeight(context) - kToolbarHeight - topInset - _sheetLip;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final credit = recipe.imageCredit;
    // Status bar icons over the uncollapsed header: light over a photo;
    // over the tinted illustration, whatever reads on the tint.
    final SystemUiOverlayStyle? headerOverlay = _collapsed
        ? null
        : recipe.imageUrl != null || theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _headerHeight(context),
            systemOverlayStyle: headerOverlay,
            // Filled so it stays visible on top of any photo. Centred, not
            // padded, so the touch target keeps its full 48 dp.
            leading: Center(
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: scheme.surface,
                  foregroundColor: scheme.onSurface,
                ),
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            // The page's rounded top edge, overlapping the photo.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(_sheetLip),
              child: Container(
                height: _sheetLip,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_sheetLip),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 72,
                end: AppSpacing.lg,
                bottom: AppSpacing.lg + _sheetLip,
              ),
              // The name is in the body; show it here only once the header
              // has collapsed.
              title: AnimatedOpacity(
                opacity: _collapsed ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Text(
                  recipe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.appBarTheme.titleTextStyle,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeImageWidget(recipe: recipe, iconSize: 96),
                  if (recipe.imageUrl != null)
                    // Top scrim so the status bar stays readable.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment(0, -0.2),
                          colors: [Color(0x99000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ContentWidthWidget(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        recipe.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RecipeMetaRowWidget(recipe: recipe),
                    if (credit != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        credit,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(recipe.description, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle(StringHelper.ingredients),
                    if (recipe.usedIngredients.isNotEmpty)
                      _IngredientPills(
                        title: StringHelper.youHave(
                          recipe.usedIngredients.length,
                        ),
                        names: recipe.usedIngredients,
                        owned: true,
                      ),
                    if (recipe.missingIngredients.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _IngredientPills(
                        title: StringHelper.youNeed(
                          recipe.missingIngredients.length,
                        ),
                        names: recipe.missingIngredients,
                        owned: false,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle(StringHelper.steps),
                    for (final (index, step) in recipe.steps.indexed)
                      _StepTile(number: index + 1, text: step),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

/// A labelled group of ingredients as pills: green with a tick for what
/// you have, red with a plus for what you still need. The title and icon
/// carry the meaning; colour reinforces it.
class _IngredientPills extends StatelessWidget {
  const _IngredientPills({
    required this.title,
    required this.names,
    required this.owned,
  });

  final String title;
  final List<String> names;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = owned
        ? scheme.tertiaryContainer
        : scheme.secondaryContainer;
    final foreground = owned
        ? scheme.onTertiaryContainer
        : scheme.onSecondaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final name in names)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm - 1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          owned ? Icons.check : Icons.add,
                          size: 16,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      // Read as "Step 1, <text>" instead of "1" then the text.
      child: Semantics(
        label: StringHelper.stepNumber(number),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(text, style: theme.textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
