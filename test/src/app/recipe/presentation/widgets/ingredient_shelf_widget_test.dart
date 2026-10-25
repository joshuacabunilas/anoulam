import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/ingredient_shelf_widget.dart';
import 'package:mobile/src/common/constant/ingredient_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

Future<void> _pump(
  WidgetTester tester, {
  double textScale = 1,
  double width = 390,
  ValueChanged<IngredientGroup>? onOpen,
}) {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: IngredientShelfWidget(
            groups: IngredientHelper.groups,
            selectedCount: (g) => g.name == 'Vegetables' ? 2 : 0,
            onOpen: onOpen ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

/// Top of the tile holding [name] (names sit at the tile's bottom, so
/// their own tops vary with wrapping).
double _tileTop(WidgetTester tester, String name) => tester
    .getTopLeft(
      find.ancestor(of: find.text(name), matching: find.byType(Material)).first,
    )
    .dy;

void main() {
  test('checklist names are unique across all categories', () {
    final names = [
      for (final group in IngredientHelper.groups)
        for (final name in group.ingredients) name.toLowerCase(),
    ];
    expect(names.toSet().length, names.length);
  });

  testWidgets('a tile with picks shows the count; tapping opens it', (
    tester,
  ) async {
    IngredientGroup? opened;
    await _pump(tester, onOpen: (g) => opened = g);

    expect(find.text('2'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Vegetables, ${StringHelper.selectedCount(2)}'),
      findsOneWidget,
    );

    await tester.tap(find.text('Vegetables'));
    expect(opened?.name, 'Vegetables');
  });

  testWidgets('three tiles to a row, two at large text', (tester) async {
    await _pump(tester);
    expect(
      _tileTop(tester, 'Eggs & dairy'),
      _tileTop(tester, 'Meat & protein'),
    );

    await _pump(tester, textScale: 2, width: 320);
    expect(tester.takeException(), isNull);
    expect(
      _tileTop(tester, 'Eggs & dairy'),
      greaterThan(_tileTop(tester, 'Meat & protein')),
    );
  });
}
