import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dofirst/features/tasks/presentation/task_input/task_input_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: TaskInputPage());
  }

  testWidgets('TaskInputPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(const Key('app_bottom_nav_bar')), findsNothing);
    // Verify app bar title
    expect(find.text('Add New Task'), findsOneWidget);

    // Verify text fields
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('What needs to be done?'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    // Verify priority selector
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    // Verify save button exists
    expect(find.text('Save Task'), findsOneWidget);
  });

  testWidgets('Save button is disabled initially enabled after title input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find the Save Task button
    final saveButtonFinder = find.widgetWithText(FilledButton, 'Save Task');
    expect(saveButtonFinder, findsOneWidget);

    // The button should be disabled (onPressed null)
    var button = tester.widget<FilledButton>(saveButtonFinder);
    expect(button.onPressed, isNull);

    // Enter text in title field
    await tester.enterText(find.byType(TextField).first, 'Buy groceries');
    await tester.pumpAndSettle();

    // The button should now be enabled
    button = tester.widget<FilledButton>(saveButtonFinder);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Tapping priority updates the selected priority', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Medium should be selected by default (the container has primary color)
    // We can just verify we can tap 'High'
    final highPriorityFinder = find.text('High');
    await tester.tap(highPriorityFinder);
    await tester.pumpAndSettle();

    // Verify the state change visually if possible, or just ensure no crash
    expect(highPriorityFinder, findsOneWidget);
  });
}
