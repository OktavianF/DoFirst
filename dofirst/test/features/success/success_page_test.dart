import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dofirst/features/success/presentation/success_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: SuccessPage());
  }

  testWidgets('SuccessPage renders correctly with default strings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(const Key('app_bottom_nav_bar')), findsNothing);
    expect(find.byType(Icon), findsWidgets);
    expect(find.text('Great Job!'), findsOneWidget);
    expect(
      find.text('You have successfully completed your task.'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('SuccessPage renders correctly with custom strings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SuccessPage(
          title: 'Custom Title',
          message: 'Custom Message',
          buttonText: 'Dashboard',
        ),
      ),
    );

    expect(find.text('Custom Title'), findsOneWidget);
    expect(find.text('Custom Message'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('Pressing continue triggers onPressed', (
    WidgetTester tester,
  ) async {
    bool isPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SuccessPage(
          onPressed: () {
            isPressed = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(isPressed, isTrue);
  });
}
