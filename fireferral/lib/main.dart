import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FireferralApp());
}

class FireferralApp extends StatelessWidget {
  const FireferralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          return MaterialApp.router(
            title: 'Fireferral',
            theme: AppThemes.getTheme(themeProvider.currentTheme, false),
            darkTheme: AppThemes.getTheme(themeProvider.currentTheme, true),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;

        // Show splash while loading
        if (isLoading) {
          return '/splash';
        }

        // Redirect to login if not authenticated
        if (!isLoggedIn &&
            state.matchedLocation != '/login' &&
            state.matchedLocation != '/signup') {
          return '/login';
        }

        // Redirect to dashboard if authenticated and on login/splash/signup
        if (isLoggedIn &&
            (state.matchedLocation == '/login' ||
                state.matchedLocation == '/splash' ||
                state.matchedLocation == '/signup')) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
  }
}
