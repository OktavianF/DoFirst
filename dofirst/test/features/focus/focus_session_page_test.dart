import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dofirst/features/focus/presentation/focus_session/focus_session_page.dart';
import 'package:dofirst/features/success/presentation/success_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: FocusSessionPage(taskName: 'Review code'));
  }

  testWidgets('FocusSessionPage renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(const Key('app_bottom_nav_bar')), findsNothing);

    // Task name
    expect(find.text('Review code'), findsOneWidget);

    // Timer default state
    expect(find.text('25:00'), findsOneWidget);

    // Play button and Reset button
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // Finished button
    expect(find.text("Task's Finished"), findsOneWidget);
  });

  testWidgets('Play button toggles to pause when is being developed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final startButtonFinder = find.widgetWithText(ElevatedButton, 'Start');
    expect(startButtonFinder, findsOneWidget);

    // Tap play
    await tester.tap(startButtonFinder);
    await tester.pump();

    // Now it should show pause
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Start'), findsNothing);

    // Tap pause
    await tester.tap(find.widgetWithText(ElevatedButton, 'Pause'));
    await tester.pump();

    // Back to play
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Finished button shows confirmation, "Yes" goes to SuccessPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Scroll if needed (ensure button is visible)
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    final finishedButton = find.widgetWithText(
      OutlinedButton,
      "Task's Finished",
    );
    expect(finishedButton, findsOneWidget);

    // Tap the 'Task's Finished' button
    await tester.tap(finishedButton);
    await tester.pumpAndSettle();

    // Verify confirmation modal appears
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(
      find.text('Do you want to finish this task and archive it?'),
      findsOneWidget,
    );

    final yesButton = find.widgetWithText(ElevatedButton, 'Yes');
    expect(yesButton, findsOneWidget);

    // Tap "Yes" in the modal
    await tester.tap(yesButton);
    await tester.pumpAndSettle();

    // Verify it navigates to SuccessPage
    expect(find.byType(SuccessPage), findsOneWidget);
    expect(find.text('Great Job!'), findsOneWidget);
  });
}
