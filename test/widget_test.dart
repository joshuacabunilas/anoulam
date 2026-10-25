import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/src/common/constant/storage_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';

import 'helpers/test_injection.dart';

void main() {
  setUp(setUpTestDependencies);

  testWidgets('add ingredients, find recipes, open a recipe', (tester) async {
    // Tall phone-width viewport so the whole flow fits without scrolling.
    // Small-screen layout is covered by layout_resilience_test.dart.
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text(StringHelper.ingredientsTitle), findsOneWidget);
    expect(find.text(StringHelper.noIngredientsMessage), findsOneWidget);

    // Type one ingredient, then pick another from the pantry shelf.
    await tester.enterText(find.byType(TextField), 'Egg');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Vegetables'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Tomatoes'));
    await tester.pump();
    // The sheet counts the pick live; Done closes it.
    expect(find.text(StringHelper.selectedCount(1)), findsWidgets);
    await tester.tap(find.text(StringHelper.done));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Egg'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Tomatoes'), findsOneWidget);

    expect(find.text(StringHelper.basketCount(2)), findsOneWidget);
    await tester.tap(find.text(StringHelper.seeRecipes));
    await tester.pump();
    await tester.pump();
    expect(find.text(StringHelper.findingRecipes), findsOneWidget);

    // Mock data source responds after a short delay.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Tomato Omelette'), findsOneWidget);

    await tester.tap(find.text('Tomato Omelette'));
    await tester.pumpAndSettle();
    expect(find.text(StringHelper.steps), findsOneWidget);
  });

  testWidgets('shows ingredients saved from a previous session', (
    tester,
  ) async {
    await setUpTestDependencies(
      storage: {
        StorageHelper.savedIngredients: ['Egg', 'Rice'],
      },
    );
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Egg'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Rice'), findsOneWidget);
    expect(find.text(StringHelper.basketCount(2)), findsOneWidget);
  });

  testWidgets('filters narrow the results and can be cleared', (tester) async {
    await setUpTestDependencies(
      storage: {
        StorageHelper.savedIngredients: ['Egg', 'Tomato', 'Onion', 'Rice'],
      },
    );
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text(StringHelper.seeRecipes));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Mock catalog: several recipes use these ingredients.
    final total = find.textContaining(' recipes');
    expect(total, findsOneWidget);
    expect(find.text('Tomato Omelette'), findsOneWidget);
    expect(find.text('Egg Fried Rice'), findsOneWidget);

    // Only Tomato Omelette has nothing missing.
    await tester.tap(
      find.widgetWithText(FilterChip, StringHelper.filterReadyToCook),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tomato Omelette'), findsOneWidget);
    expect(find.text('Egg Fried Rice'), findsNothing);
    expect(find.textContaining('Showing 1 of'), findsOneWidget);

    // Ready to cook + dish type Rice: nothing matches.
    await tester.tap(
      find.widgetWithText(ChoiceChip, StringHelper.categoryRice),
    );
    await tester.pumpAndSettle();
    expect(find.text(StringHelper.noFilterMatchTitle), findsOneWidget);

    await tester.tap(find.text(StringHelper.clearFilters));
    await tester.pumpAndSettle();
    expect(find.text('Tomato Omelette'), findsOneWidget);
    expect(find.text('Egg Fried Rice'), findsOneWidget);
  });

  testWidgets('typed names and known names never duplicate (Egg = Eggs)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'egg');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // The known "Eggs" counts as already added: its suggestion shows a
    // tick.
    await tester.enterText(find.byType(TextField), 'Egg');
    await tester.pump();
    final eggsChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Eggs').first,
    );
    expect(eggsChip.selected, isTrue);

    await tester.enterText(find.byType(TextField), 'EGGS');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text(StringHelper.alreadyAdded('EGGS')), findsOneWidget);
    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets('Clear all can be undone', (tester) async {
    await setUpTestDependencies(
      storage: {
        StorageHelper.savedIngredients: ['Egg', 'Rice'],
      },
    );
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text(StringHelper.clearAll));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
    expect(find.text(StringHelper.clearedCount(2)), findsOneWidget);

    await tester.tap(find.text(StringHelper.undo));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Egg'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Rice'), findsOneWidget);
  });

  testWidgets('results show the search and Edit goes back to it', (
    tester,
  ) async {
    await setUpTestDependencies(
      storage: {
        StorageHelper.savedIngredients: ['Egg', 'Tomato', 'Onion', 'Rice'],
      },
    );
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text(StringHelper.seeRecipes));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.text(StringHelper.usingIngredients('Egg, Tomato, Onion', 1)),
      findsOneWidget,
    );
    await tester.tap(find.text(StringHelper.editIngredients));
    await tester.pumpAndSettle();
    expect(find.text(StringHelper.ingredientsTitle), findsOneWidget);
  });

  testWidgets('filter toggles carry over to the next search', (tester) async {
    await setUpTestDependencies(
      storage: {
        StorageHelper.savedIngredients: ['Egg', 'Tomato', 'Onion'],
      },
    );
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    Future<void> search() async {
      await tester.tap(find.text(StringHelper.seeRecipes));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    bool readySelected() => tester
        .widget<FilterChip>(
          find.widgetWithText(FilterChip, StringHelper.filterReadyToCook),
        )
        .selected;

    await search();
    expect(readySelected(), isFalse);
    await tester.tap(
      find.widgetWithText(FilterChip, StringHelper.filterReadyToCook),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(StringHelper.editIngredients));
    await tester.pumpAndSettle();
    await search();
    expect(readySelected(), isTrue);
  });

  testWidgets('typing suggests known ingredients; a tap adds one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final before = find.widgetWithText(FilterChip, 'Garlic').evaluate().length;
    await tester.enterText(find.byType(TextField), 'gar');
    await tester.pump();
    // One more Garlic chip: the suggestion, right under the field.
    expect(
      find.widgetWithText(FilterChip, 'Garlic'),
      findsNWidgets(before + 1),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Garlic').first);
    await tester.pump();
    expect(find.widgetWithText(InputChip, 'Garlic'), findsOneWidget);
    // The field clears, ready for the next one, and suggestions go away.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.widgetWithText(FilterChip, 'Garlic'), findsNWidgets(before));
  });

  testWidgets('the add button shows a white plus on green', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final plus = tester.widget<RichText>(
      find.descendant(
        of: find.byTooltip(StringHelper.addIngredient),
        matching: find.byType(RichText),
      ),
    );
    expect(plus.text.style?.color, Colors.white);
  });

  testWidgets('the Removed note with Undo closes on its own', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Fish');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byTooltip(StringHelper.removeNamed('Fish')));
    await tester.pump();
    expect(find.text(StringHelper.removedNamed('Fish')), findsOneWidget);

    // Once it has slid in, about 3 seconds, then it leaves by itself.
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(StringHelper.removedNamed('Fish')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text(StringHelper.removedNamed('Fish')), findsNothing);
  });
}
