import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/get_it_configuration/get_it_configuration.dart';
import 'package:mobile/src/common/constant/ingredient_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';
import 'package:mobile/src/common/widgets/content_width_widget.dart';
import 'package:mobile/src/common/widgets/toggle_chip_widget.dart';
import 'package:mobile/src/routes/app_route_name.dart';

import '../../domain/entities/ingredient_entities.dart';
import '../bloc/ingredients/ingredients_bloc.dart';
import '../widgets/basket_bar_widget.dart';
import '../widgets/ingredient_group_sheet_widget.dart';
import '../widgets/ingredient_shelf_widget.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IngredientsBloc>()..add(const IngredientsStarted()),
      child: const _IngredientsView(),
    );
  }
}

class _IngredientsView extends StatefulWidget {
  const _IngredientsView();

  @override
  State<_IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<_IngredientsView> {
  /// Most suggestions shown while typing.
  static const _maxSuggestions = 8;

  /// Every ingredient name in the browse list, once.
  static final _allNames = {
    for (final group in IngredientHelper.groups) ...group.ingredients,
  }.toList();

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Suggestions follow the text as it's typed.
    _controller.addListener(() => setState(() {}));
  }

  /// Known ingredients matching what's typed: names starting with it
  /// first, then names containing it.
  List<String> get _suggestions {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final starts = <String>[];
    final contains = <String>[];
    for (final name in _allNames) {
      final lower = name.toLowerCase();
      if (lower.startsWith(query)) {
        starts.add(name);
      } else if (lower.contains(query)) {
        contains.add(name);
      }
    }
    return [...starts, ...contains].take(_maxSuggestions).toList();
  }

  /// Opens one pantry category as a bottom sheet of tick chips. The sheet
  /// listens to the same bloc, so ticks show at once.
  void _openGroup(IngredientGroup group) {
    final bloc = context.read<IngredientsBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth: AppSpacing.maxContentWidth,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<IngredientsBloc, IngredientsState>(
          builder: (context, state) => IngredientGroupSheetWidget(
            group: group,
            isSelected: state.contains,
            isFull: state.isFull,
            onChanged: (name, {required selected}) => selected
                ? bloc.add(IngredientAdded(name))
                : bloc.add(IngredientRemoved(name)),
          ),
        ),
      ),
    );
  }

  /// Picking a suggestion adds it and clears the field for the next one.
  void _pickSuggestion(String name, bool selected) {
    _toggle(name, selected);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showMessage(String message, {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          // Snackbars with an action stay until dismissed by default;
          // these are quick notes, so they close on their own.
          duration: const Duration(seconds: 3),
          persist: false,
          action: onUndo == null
              ? null
              : SnackBarAction(label: StringHelper.undo, onPressed: onUndo),
        ),
      );
  }

  void _add(String name) {
    final bloc = context.read<IngredientsBloc>();
    if (bloc.state.contains(name)) {
      _showMessage(StringHelper.alreadyAdded(IngredientEntities.clean(name)));
      return;
    }
    if (bloc.state.isFull) {
      _showMessage(StringHelper.listFull(IngredientEntities.maxCount));
      return;
    }
    bloc.add(IngredientAdded(name));
  }

  /// For tick-style chips. Unticking is undone by ticking again, so it
  /// needs no snackbar.
  void _toggle(String name, bool selected) {
    if (selected) {
      _add(name);
    } else {
      context.read<IngredientsBloc>().add(IngredientRemoved(name));
    }
  }

  /// Removing is one tap, so it can always be undone.
  void _remove(String name) {
    final bloc = context.read<IngredientsBloc>();
    final index = bloc.state.ingredients.indexOf(name);
    bloc.add(IngredientRemoved(name));
    _showMessage(
      StringHelper.removedNamed(name),
      onUndo: () => bloc.add(IngredientsRestored([name], index: index)),
    );
  }

  void _clearAll() {
    final bloc = context.read<IngredientsBloc>();
    final previous = bloc.state.ingredients;
    bloc.add(const IngredientsCleared());
    _showMessage(
      StringHelper.clearedCount(previous.length),
      onUndo: () => bloc.add(IngredientsRestored(previous)),
    );
  }

  void _submitField() {
    if (_controller.text.trim().isEmpty) return;
    _add(_controller.text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(StringHelper.appName),
        actions: [
          BlocBuilder<IngredientsBloc, IngredientsState>(
            builder: (context, state) => state.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: _clearAll,
                    child: const Text(StringHelper.clearAll),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: ContentWidthWidget(
          child: BlocBuilder<IngredientsBloc, IngredientsState>(
            builder: (context, state) {
              final suggestions = _suggestions;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      0,
                    ),
                    sliver: SliverList.list(
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            StringHelper.ingredientsTitle,
                            style: textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          StringHelper.ingredientsSubtitle,
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          // The backend rejects longer names.
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              IngredientEntities.maxLength,
                            ),
                          ],
                          onSubmitted: (_) => _submitField(),
                          decoration: InputDecoration(
                            labelText: StringHelper.ingredientLabel,
                            hintText: StringHelper.ingredientSearchHint,
                            prefixIcon: const Icon(Icons.search),
                            // The field tints suffix icons grey, so the
                            // button sets its own colours; it is sized to
                            // sit inside the field with an even margin.
                            suffixIcon: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: AppSpacing.sm - 2,
                              ),
                              child: IconButton.filled(
                                tooltip: StringHelper.addIngredient,
                                icon: const Icon(Icons.add),
                                style: IconButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  fixedSize: const Size.square(44),
                                  minimumSize: const Size.square(44),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: _submitField,
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 50,
                              minHeight: 44,
                            ),
                          ),
                        ),
                        // Known ingredients matching what's typed, one tap
                        // each, so spelling never gets in the way.
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final name in suggestions)
                                ToggleChipWidget(
                                  label: name,
                                  selected: state.contains(name),
                                  onSelected: (selected) =>
                                      _pickSuggestion(name, selected),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        // Your list sits right under the field you add with.
                        const _SectionTitle(StringHelper.yourIngredients),
                        if (state.isEmpty)
                          Text(
                            StringHelper.noIngredientsMessage,
                            style: textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              // Leaf green: what's in the basket.
                              for (final name in state.ingredients)
                                InputChip(
                                  color: WidgetStatePropertyAll(scheme.primary),
                                  side: BorderSide(color: scheme.primary),
                                  labelStyle: textTheme.labelLarge?.copyWith(
                                    color: scheme.onPrimary,
                                  ),
                                  deleteIconColor: scheme.onPrimary,
                                  label: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  deleteButtonTooltipMessage:
                                      StringHelper.removeNamed(name),
                                  onDeleted: () => _remove(name),
                                ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.xxl),
                        const _SectionTitle(StringHelper.browseIngredients),
                        IngredientShelfWidget(
                          groups: IngredientHelper.groups,
                          selectedCount: (g) =>
                              g.ingredients.where(state.contains).length,
                          onOpen: _openGroup,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // The basket stays in reach at the bottom, over the page.
      bottomNavigationBar: BlocBuilder<IngredientsBloc, IngredientsState>(
        builder: (context, state) => SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: ContentWidthWidget(
            child: BasketBarWidget(
              ingredients: state.ingredients,
              onSubmit: state.isEmpty
                  ? null
                  : () => context.push(
                      AppRouteName.recipes,
                      extra: {'data': List<String>.of(state.ingredients)},
                    ),
            ),
          ),
        ),
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
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
