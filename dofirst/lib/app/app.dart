import 'package:dofirst/features/auth/presentation/login/login_page.dart';
import 'package:dofirst/features/auth/presentation/login/login_view_model.dart';
import 'package:dofirst/features/auth/presentation/signup/signup_page.dart';
import 'package:dofirst/features/auth/presentation/signup/signup_view_model.dart';
import 'package:dofirst/features/home/presentation/home_page.dart';
import 'package:dofirst/features/home/presentation/home_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';
import 'package:dofirst/features/profile/presentation/profile_view_model.dart';
import 'package:dofirst/shared/services/api_client.dart';
import 'package:dofirst/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoFirstApp extends StatelessWidget {
  const DoFirstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => TaskListViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'DoFirst',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
        routes: {
          '/login': (_) => ChangeNotifierProvider(
                create: (_) => LoginViewModel(),
                child: const LoginPage(),
              ),
          '/signup': (_) => ChangeNotifierProvider(
                create: (_) => SignupViewModel(),
                child: const SignupPage(),
              ),
        },
      ),
    );
  }
}

/// Checks for saved auth token on startup.
/// Shows HomePage if authenticated, LoginPage if not.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiClient.hasToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasToken = snapshot.data ?? false;
        if (hasToken) {
          // ViewModels already load cached data in their constructors,
          // then fetch fresh data from API in the background.
          return const HomePage();
        } else {
          return ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginPage(),
          );
        }
      },
    );
  }
}
