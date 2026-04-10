import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:dofirst/features/auth/presentation/login/login_page.dart';
import 'package:dofirst/features/auth/presentation/login/login_view_model.dart';
import 'package:dofirst/features/auth/presentation/signup/signup_view_model.dart';
import 'package:dofirst/features/home/presentation/home_page.dart';
import 'package:dofirst/features/home/presentation/home_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';
import 'package:dofirst/features/profile/presentation/profile_view_model.dart';
import 'package:dofirst/shared/theme/app_theme.dart';
import 'package:dofirst/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  void _openLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
          child: const LoginPage(),
        ),
      ),
    );
  }

  void _refreshValidity(SignupViewModel vm) {
    final valid =
        _formKey.currentState?.validate(
          focusOnInvalid: false,
          autoScrollWhenFocusOnInvalid: false,
        ) ??
        false;
    vm.updateFormValidity(valid);
  }

  Future<void> _submit(SignupViewModel vm) async {
    vm.markInteracted();
    final valid =
        _formKey.currentState?.saveAndValidate(
          focusOnInvalid: false,
          autoScrollWhenFocusOnInvalid: true,
        ) ??
        false;
    vm.updateFormValidity(valid);

    if (!valid) {
      return;
    }

    final values = _formKey.currentState!.value;
    final fullName = values['fullName'] as String;
    final email = values['email'] as String;
    final password = values['password'] as String;

    final success = await vm.signupWithApi(fullName, email, password);

    if (!mounted) return;

    if (success) {
      context.read<HomeViewModel>().loadDashboard();
      context.read<TaskListViewModel>().loadTasks();
      context.read<ProfileViewModel>().loadProfile();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();

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
                          onPressed: () {
                            final focus = FocusScope.of(context);
                            if (focus.hasFocus) {
                              focus.unfocus();
                            }
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              _openLoginPage();
                            }
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create your account',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 42),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join DoFirst today and start mastering your\nproductivity journey.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
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
                      padding: const EdgeInsets.all(24),
                      child: FormBuilder(
                        key: _formKey,
                        autovalidateMode: vm.autovalidateMode,
                        onChanged: () => _refreshValidity(vm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _InputLabel(title: 'FULL NAME'),
                            FormBuilderTextField(
                              key: const Key('full_name_field'),
                              name: 'fullName',
                              autofillHints: const [AutofillHints.name],
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'John Doe',
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'Full name is required.',
                                ),
                                FormBuilderValidators.minLength(
                                  2,
                                  errorText: 'Please enter a valid name.',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 18),
                            _InputLabel(title: 'EMAIL ADDRESS'),
                            FormBuilderTextField(
                              key: const Key('email_field'),
                              name: 'email',
                              autofillHints: const [AutofillHints.email],
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'name@example.com',
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'Email address is required.',
                                ),
                                FormBuilderValidators.email(
                                  errorText: 'Please enter a valid email.',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 18),
                            _InputLabel(title: 'PASSWORD'),
                            FormBuilderTextField(
                              key: const Key('password_field'),
                              name: 'password',
                              obscureText: vm.obscurePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(vm),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  key: const Key('password_visibility_button'),
                                  onPressed: vm.togglePasswordVisibility,
                                  tooltip: vm.obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    vm.obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'Password is required.',
                                ),
                                FormBuilderValidators.minLength(
                                  8,
                                  errorText: 'Use at least 8 characters.',
                                ),
                                FormBuilderValidators.match(
                                  RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$'),
                                  errorText: 'Use letters and numbers.',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 24),
                            Semantics(
                              button: true,
                              enabled: vm.canSubmit,
                              label: 'Sign up',
                              child: PrimaryButton(
                                key: const Key('sign_up_button'),
                                label: 'Sign Up',
                                isLoading: vm.isSubmitting,
                                onPressed: vm.canSubmit
                                    ? () => _submit(vm)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _OrDivider(),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: vm.isSubmitting ? null : () async {
                                  final success = await vm.signupWithGoogle();
                                  if (!context.mounted) return;
                                  if (success) {
                                    context.read<HomeViewModel>().loadDashboard();
                                    context.read<TaskListViewModel>().loadTasks();
                                    context.read<ProfileViewModel>().loadProfile();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const HomePage()),
                                      (route) => false,
                                    );
                                  } else if (vm.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(vm.errorMessage!)),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.cardBorder,
                                  ),
                                  shape: const StadiumBorder(),
                                  foregroundColor: AppColors.textPrimary,
                                ),
                                icon: const _GoogleGlyph(),
                                label: const Text(
                                  'Sign up with Google',
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
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextButton(
                        onPressed: _openLoginPage,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Log in',
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
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.33,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.cardBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.cardBorder)),
      ],
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/google_logo.svg',
        width: 20,
        height: 20,
      ),
    );
  }
}
