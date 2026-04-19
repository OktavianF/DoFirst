import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dofirst/features/home/presentation/home_page.dart';
import 'package:dofirst/features/home/presentation/home_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';
import 'package:dofirst/features/profile/presentation/profile_view_model.dart';

import 'package:dofirst/features/auth/presentation/login/login_view_model.dart';
import 'package:dofirst/features/auth/presentation/signup/signup_page.dart';
import 'package:dofirst/features/auth/presentation/signup/signup_view_model.dart';
import 'package:dofirst/shared/theme/app_theme.dart';
import 'package:dofirst/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  void _openSignupPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => SignupViewModel(),
          child: const SignupPage(),
        ),
      ),
    );
  }

  void _refreshValidity(LoginViewModel vm) {
    final valid =
        _formKey.currentState?.validate(
          focusOnInvalid: false,
          autoScrollWhenFocusOnInvalid: false,
        ) ??
        false;
    vm.updateFormValidity(valid);
  }

  Future<void> _submit(LoginViewModel vm) async {
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
    final email = values['email'] as String;
    final password = values['password'] as String;

    final success = await vm.loginWithApi(email, password);

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
        SnackBar(content: Text(vm.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

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
                  const SizedBox(height: 60),
                  Text(
                    'Welcome back',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your automated priority assistant.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Wrap inside Auth Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: vm.isSubmitting ? null : () async {
                                  final success = await vm.loginWithGoogle();
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
                                  backgroundColor: Colors.white,
                                ),
                                icon: const _GoogleGlyph(),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const _OrDivider(),
                            const SizedBox(height: 24),
                            FormBuilder(
                              key: _formKey,
                              autovalidateMode: vm.autovalidateMode,
                              onChanged: () => _refreshValidity(vm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _InputLabel(title: 'Email address'),
                                  FormBuilderTextField(
                                    key: const Key('email_field'),
                                    name: 'email',
                                    autofillHints: const [AutofillHints.email],
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: 'Input your email',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                      ),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(
                                        errorText: 'Email address is required.',
                                      ),
                                      FormBuilderValidators.email(
                                        errorText:
                                            'Please enter a valid email.',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _InputLabel(title: 'Password'),
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Forgot Password flow not wired yet.',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: AppColors.primaryDark,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  FormBuilderTextField(
                                    key: const Key('password_field'),
                                    name: 'password',
                                    obscureText: vm.obscurePassword,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(vm),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: const TextStyle(
                                        color: Colors.black38,
                                      ),
                                      suffixIcon: IconButton(
                                        key: const Key(
                                          'password_visibility_button',
                                        ),
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
                                    ]),
                                  ),
                                  const SizedBox(height: 24),
                                  Semantics(
                                    button: true,
                                    enabled: vm.canSubmit,
                                    label: 'Sign in with Email',
                                    child: PrimaryButton(
                                      key: const Key('sign_in_button'),
                                      label: 'Sign in with Email',
                                      isLoading: vm.isSubmitting,
                                      onPressed: vm.canSubmit
                                          ? () => _submit(vm)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to DoFirst? ',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: _openSignupPage,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
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
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
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
            'or',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
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
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/google_logo.svg',
        width: 18,
        height: 18,
      ),
    );
  }
}
