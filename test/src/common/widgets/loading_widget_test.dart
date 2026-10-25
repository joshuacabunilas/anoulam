import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/common/widgets/loading_widget.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('LoadingWidget', () {
    testWidgets('shows a spinner without a message by default', (tester) async {
      await tester.pumpWidget(wrap(const LoadingWidget()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows the message when provided', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingWidget(message: 'Please wait')),
      );

      expect(find.text('Please wait'), findsOneWidget);
    });
  });

  group('LoadingOverlay', () {
    testWidgets('shows only the child when not loading', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingOverlay(isLoading: false, child: Text('Content'))),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(LoadingWidget), findsNothing);
    });

    testWidgets('covers the child and blocks taps when loading', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          LoadingOverlay(
            isLoading: true,
            child: Center(
              child: ElevatedButton(
                onPressed: () => tapped = true,
                child: const Text('Tap me'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingWidget), findsOneWidget);
      await tester.tap(find.text('Tap me'), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });
}
