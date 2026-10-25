import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/common/theme/app_theme.dart';
import 'package:mobile/src/common/widgets/toggle_chip_widget.dart';

void main() {
  testWidgets('keeps the same width when toggled', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) => ToggleChipWidget(
                label: 'Tomatoes',
                selected: selected,
                onSelected: (v) => setState(() => selected = v),
              ),
            ),
          ),
        ),
      ),
    );
    final before = tester.getSize(find.byType(ToggleChipWidget));
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byType(ToggleChipWidget));
    await tester.pumpAndSettle();

    expect(selected, isTrue);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.getSize(find.byType(ToggleChipWidget)), before);
  });

  // Regression: a state-dependent TextStyle in the chip theme rendered the
  // labels with no colour, so only the icons showed.
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('label is visible in $name theme, on and off', (tester) async {
      for (final selected in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: ToggleChipWidget(
                  label: 'Tomatoes',
                  selected: selected,
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        );
        final style = tester
            .widget<RichText>(
              find.descendant(
                of: find.text('Tomatoes'),
                matching: find.byType(RichText),
              ),
            )
            .text
            .style;
        final scheme = theme.colorScheme;
        expect(
          style?.color,
          selected ? scheme.onPrimary : scheme.onSurface,
          reason: 'selected: $selected',
        );
        expect(style?.fontFamily, 'DMSans');
      }
    });
  }
}
