import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/presentation/widgets/finding_recipes_widget.dart';
import 'package:mobile/src/common/constant/string_helper.dart';

void main() {
  testWidgets('explains a slow search and offers Cancel', (tester) async {
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FindingRecipesWidget(onCancel: () => cancelled = true),
        ),
      ),
    );

    expect(find.text(StringHelper.findingRecipes), findsOneWidget);
    expect(find.text(StringHelper.cancel), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text(StringHelper.wakingUpServer), findsOneWidget);

    await tester.tap(find.text(StringHelper.cancel));
    expect(cancelled, isTrue);
  });

  testWidgets('stops its timer when the search finishes early', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FindingRecipesWidget(onCancel: () {})),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    // No pending timer error after disposal.
    await tester.pump(const Duration(seconds: 10));
  });
}
