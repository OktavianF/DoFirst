import 'package:dofirst/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows signup screen essentials', (tester) async {
    await tester.pumpWidget(const DoFirstApp());

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const Key('full_name_field')), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('password visibility can be toggled', (tester) async {
    await tester.pumpWidget(const DoFirstApp());

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
    await tester.pumpWidget(const DoFirstApp());

    final signupButton = find.byKey(const Key('sign_up_button'));
    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pump();

    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('Email address is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('accepts valid input and submits', (tester) async {
    await tester.pumpWidget(const DoFirstApp());

    await tester.enterText(
      find.byKey(const Key('full_name_field')),
      'John Doe',
    );
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'john@example.com',
    );
    await tester.enterText(find.byKey(const Key('password_field')), 'pass1234');

    final signupButton = find.byKey(const Key('sign_up_button'));
    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(
      find.text('Account details look good. Continue to verification.'),
      findsOneWidget,
    );
  });
}
