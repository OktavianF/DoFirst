import 'dart:ui';

import 'package:dofirst/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  void _backToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _sendResetLink() {
    final valid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!valid) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset link sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundGlow(),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                32 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Go back',
                        child: IconButton(
                          onPressed: _backToLogin,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Forgot password?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 160,
                    height: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.broken_image,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your email address to reset your password and continue your productivity journey.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _InputLabel(title: 'Email address'),
                            FormBuilderTextField(
                              key: const Key('forgot_email_field'),
                              name: 'email',
                              autofillHints: const [AutofillHints.email],
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                hintText: 'name@company.com',
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'Email address is required.',
                                ),
                                FormBuilderValidators.email(
                                  errorText: 'Please enter a valid email.',
                                ),
                              ]),
                              onSubmitted: (_) => _sendResetLink(),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _sendResetLink,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  elevation: 8,
                                  shadowColor: AppColors.primaryDark.withValues(alpha: 0.25),
                                ),
                                child: const Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Back to ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      TextButton(
                        onPressed: _backToLogin,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -40,
          top: -90,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                color: AppColors.indigoGlow,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          left: -80,
          bottom: -100,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                color: AppColors.mintGlow,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
