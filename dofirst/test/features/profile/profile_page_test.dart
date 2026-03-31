import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dofirst/features/profile/presentation/profile_page.dart';
import 'package:dofirst/features/auth/presentation/login/login_view_model.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoginViewModel())],
      child: const MaterialApp(home: ProfilePage()),
    );
  }

  testWidgets('ProfilePage renders header correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(const Key('app_bottom_nav_bar')), findsOneWidget);
    expect(find.byKey(const Key('profile_page_profile_button')), findsNothing);
    expect(find.text('Nadhia'), findsOneWidget);
    expect(find.text('nadhia@gmail.com'), findsOneWidget);
    expect(find.text('STUDENT'), findsOneWidget);
    expect(find.text('BETA TESTER'), findsOneWidget);
  });

  testWidgets('ProfilePage renders stats section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('TASKS DONE'), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
    expect(find.text('AVG FOCUS'), findsOneWidget);
  });

  testWidgets('ProfilePage renders settings options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('SETTINGS & ACCOUNT'), findsOneWidget);
    expect(find.text('Google Sync'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('LOG OUT ACCOUNT'), findsOneWidget);
  });

  testWidgets('Focus tab in navbar opens Home page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('FOCUS'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Logout button opens confirmation dialog and routes to LoginPage',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Scroll to find LOG OUT ACCOUNT
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOG OUT ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out?'), findsOneWidget);

      await tester.tap(find.text('Log Out').last);
      await tester.pumpAndSettle();

      // After logging out, we should be on the Login page
      expect(find.text('Welcome back'), findsWidgets);
    },
  );
}
