import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_page.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: TaskListPage());
  }

  testWidgets('TaskListPage renders header correctly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app_bottom_nav_bar')), findsOneWidget);
    expect(find.text('Your Tasks'), findsOneWidget);
    expect(find.text('Search tasks...'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('TaskListPage renders sections and default tasks', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('HIGH PRIORITY'), findsOneWidget);
    expect(find.text('3 TASKS'), findsOneWidget);
    expect(find.text('Finalize Q4 Strategy Deck'), findsOneWidget);
    expect(find.text('Emergency Server Patch'), findsOneWidget);

    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;

    await tester.scrollUntilVisible(
      find.text('MEDIUM PRIORITY'),
      50.0,
      scrollable: scrollable,
    );

    expect(find.text('MEDIUM PRIORITY'), findsOneWidget);
    expect(find.text('2 TASKS'), findsOneWidget);
    expect(find.text('Update Onboarding Docs'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('TaskListPage filters tasks on search', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Emergency');
    await tester.pumpAndSettle();

    expect(find.text('Emergency Server Patch'), findsOneWidget);
    expect(
      find.text('Finalize Q4 Strategy Deck'),
      findsNothing,
    ); // Filtered out

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Focus tab in navbar opens Home page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('FOCUS'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
