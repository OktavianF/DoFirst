import 'package:flutter_test/flutter_test.dart';
import 'package:dofirst/features/focus/presentation/focus_session/focus_session_page.dart';
import 'package:dofirst/features/home/presentation/home_page.dart';
import 'package:dofirst/features/profile/presentation/profile_page.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_page.dart';
import 'package:flutter/material.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: HomePage());
  }

  testWidgets('HomePage renders header nicely', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app_bottom_nav_bar')), findsOneWidget);
    expect(find.text('WELCOME BACK'), findsOneWidget);
    expect(find.textContaining('Good morning,'), findsOneWidget);
    expect(find.text('TASKS DONE'), findsOneWidget);
  });

  testWidgets('HomePage renders Hero Task correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Finish PRD\nDraft'), findsOneWidget);
    expect(find.text('HIGHEST PRIORITY'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('Start Now'), findsOneWidget);
  });

  testWidgets('HomePage renders Up Next Section correctly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400); // larger view
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Up Next'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(find.text('Review Marketing Assets'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('HomePage bottom navigation bar handles tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('TASKS'), findsOneWidget);
    expect(find.text('PROFILE'), findsOneWidget);

    final tasksTab = find.text('TASKS');
    await tester.tap(tasksTab);
    await tester.pumpAndSettle();

    expect(find.byType(TaskListPage), findsOneWidget);
  });

  testWidgets('Start Now navigates to Focus Session', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -140));
    await tester.pumpAndSettle();

    final startNowButton = find.byKey(const Key('start_now_button'));
    await tester.ensureVisible(startNowButton);
    await tester.tap(startNowButton);
    await tester.pumpAndSettle();

    expect(find.byType(FocusSessionPage), findsOneWidget);
    expect(find.text('Focus Session'), findsOneWidget);
  });

  testWidgets('View All button opens task list page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    final viewAllButton = find.byKey(const Key('view_all_tasks_button'));
    await tester.ensureVisible(viewAllButton);
    await tester.tap(viewAllButton);
    await tester.pumpAndSettle();

    expect(find.byType(TaskListPage), findsOneWidget);
    expect(find.text('Your Tasks'), findsOneWidget);
  });

  testWidgets('Profile avatar opens profile page', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home_profile_button')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Nadhia'), findsOneWidget);
  });
}
