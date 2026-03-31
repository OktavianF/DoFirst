import 'package:dofirst/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dofirst/features/auth/presentation/login/login_page.dart';
import 'package:dofirst/features/auth/presentation/login/login_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestableWidget() {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const MaterialApp(home: LoginPage()),
    );
  }

  testWidgets('shows login screen essentials', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.text('Sign in with Email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('password visibility can be toggled', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final field = tester.widget<FormBuilderTextField>(
      find.byKey(const Key('password_field')),
    );
    expect(field.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('password_visibility_button')));
    await tester.pump();

    final toggled = tester.widget<FormBuilderTextField>(
      find.byKey(const Key('password_field')),
    );
    expect(toggled.obscureText, isFalse);
  });

  testWidgets('shows validation errors after submit with invalid fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget());

    final loginButton = find.byKey(const Key('sign_in_button'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Email address is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('accepts valid input and submits', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    await tester.enterText(
      find.byKey(const Key('email_field')),
      'john@example.com',
    );
    await tester.enterText(find.byKey(const Key('password_field')), 'pass1234');

    final loginButton = find.byKey(const Key('sign_in_button'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(
      find.text('Logged in successfully. Navigating to Home.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping create account opens signup page', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final createAccountCta = find.text('Create an account');
    await tester.ensureVisible(createAccountCta);
    await tester.tap(createAccountCta);
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
  });
}
