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

  testWidgets('Focus & Break Settings tile navigates to FocusSettingsPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Scroll down to find Focus & Break Settings tile
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    // Tap on Focus & Break Settings
    await tester.tap(find.text('Focus & Break Settings'));
    await tester.pumpAndSettle();

    // Verify we're now on FocusSettingsPage with the header
    expect(find.text('Focus & Break Settings'), findsWidgets);
    expect(find.text('Customize your focus sessions and break to match your workflow'), findsOneWidget);
  });

  testWidgets('FocusSettingsPage renders duration settings correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Navigate to Focus Settings
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Focus & Break Settings'));
    await tester.pumpAndSettle();

    // Verify duration sections are visible
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('Focus Duration'), findsOneWidget);
    expect(find.text('Short Break'), findsOneWidget);
    expect(find.text('Weekly Team Sync'), findsOneWidget);
  });

  testWidgets('FocusSettingsPage renders options section with toggles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Navigate to Focus Settings
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Focus & Break Settings'));
    await tester.pumpAndSettle();

    // Scroll in the settings page to see all options
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    // Verify options are visible
    expect(find.text('OPTIONS'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Vibration'), findsOneWidget);
    expect(find.text('Auto Start Next Session'), findsOneWidget);
    expect(find.text('Auto Start Break'), findsOneWidget);
  });

  testWidgets('Back button returns to ProfilePage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Navigate to Focus Settings
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Focus & Break Settings'));
    await tester.pumpAndSettle();

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Should be back at ProfilePage
    expect(find.text('SETTINGS & ACCOUNT'), findsOneWidget);
  });
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
  int get totalTasks => 42;

  @override
  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    _fullName = fullName ?? _fullName;
    _avatarUrl = avatarUrl ?? _avatarUrl;
    notifyListeners();
  }
}
