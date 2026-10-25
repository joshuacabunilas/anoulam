import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/basket_bar_widget.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

Future<void> _pump(
  WidgetTester tester, {
  required List<String> ingredients,
  VoidCallback? onSubmit,
  double textScale = 1,
}) {
  tester.view.physicalSize = const Size(375, 667);
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: BasketBarWidget(ingredients: ingredients, onSubmit: onSubmit),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('empty basket explains itself and cannot submit', (tester) async {
    await _pump(tester, ingredients: const []);

    expect(find.text(StringHelper.basketEmpty), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows the count and names, and submits', (tester) async {
    var submitted = false;
    await _pump(
      tester,
      ingredients: const ['Chicken', 'Garlic', 'Rice', 'Sugar'],
      onSubmit: () => submitted = true,
    );

    expect(find.text(StringHelper.basketCount(4)), findsOneWidget);
    expect(find.text('Chicken, Garlic, Rice, Sugar'), findsOneWidget);

    await tester.tap(find.text(StringHelper.seeRecipes));
    expect(submitted, isTrue);
  });

  testWidgets('button moves under the basket at 200% text', (tester) async {
    await _pump(
      tester,
      ingredients: const ['Chicken', 'Garlic'],
      onSubmit: () {},
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.byType(FilledButton)).dy,
      greaterThan(tester.getTopLeft(find.text(StringHelper.basketCount(2))).dy),
    );
  });
}
