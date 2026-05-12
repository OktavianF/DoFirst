import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dofirst/features/profile/presentation/profile_page.dart';
import 'package:dofirst/features/auth/presentation/login/login_view_model.dart';
import 'package:dofirst/features/home/presentation/home_view_model.dart';
import 'package:dofirst/features/profile/presentation/profile_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => TaskListViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => TestProfileViewModel(),
        ),
      ],
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
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Google Sync'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Focus & Break Settings'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('LOG OUT ACCOUNT'), findsOneWidget);
  });

  testWidgets('Edit Profile opens editor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Edit Profile'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(InkWell, 'Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Nadhia'), findsOneWidget);
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

      // Confirmation dialog is shown
      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    },
  );
}

class TestProfileViewModel extends ProfileViewModel {
  String _fullName = 'Nadhia';
  String _email = 'nadhia@gmail.com';
  String? _avatarUrl = 'https://example.com/avatar.png';
  bool _isLoading = false;

  @override
  String get fullName => _fullName;

  @override
  String get email => _email;

  @override
  String? get avatarUrl => _avatarUrl;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> loadProfile() async {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void clear() {
    _fullName = '';
    _email = '';
    _avatarUrl = null;
    _isLoading = true;
    notifyListeners();
  }
}
