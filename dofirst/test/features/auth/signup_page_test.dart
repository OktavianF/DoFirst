import 'package:dofirst/features/auth/presentation/signup/signup_page.dart';
import 'package:dofirst/features/auth/presentation/signup/signup_view_model.dart';
import 'package:dofirst/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestableWidget() {
    return ChangeNotifierProvider(
      create: (_) => SignupViewModel(),
      child: const MaterialApp(home: SignupPage()),
    );
  }

  testWidgets('shows signup screen essentials', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const Key('full_name_field')), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('sign_up_button')), findsOneWidget);
    expect(find.text('Sign up with Google'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('tapping Log in opens login page', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

      final loginCta = find.text('Log in');
      await tester.ensureVisible(loginCta);
      await tester.tap(loginCta);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('valid signup redirects to home page', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    await tester.enterText(
      find.byKey(const Key('full_name_field')),
      'John Doe',
    );
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'john@example.com',
    );
    await tester.enterText(find.byKey(const Key('password_field')), 'abc12345');

      final signUpButton = find.byKey(const Key('sign_up_button'));
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
