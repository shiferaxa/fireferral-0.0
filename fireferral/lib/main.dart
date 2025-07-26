import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/app_state_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/organization_signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FireferralApp());
}

class FireferralApp extends StatefulWidget {
  const FireferralApp({super.key});

  @override
  State<FireferralApp> createState() => _FireferralAppState();
}

class _FireferralAppState extends State<FireferralApp> {
  late AuthProvider _authProvider;
  late ThemeProvider _themeProvider;
  
  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _themeProvider = ThemeProvider();
    
    // Initialize app state coordination
    AppStateService.instance.initialize(_themeProvider, _authProvider);
  }
  
  @override
  void dispose() {
    AppStateService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          debugPrint('🎨 Building app with theme: ${themeProvider.currentTheme.name}, dark: ${themeProvider.isDarkMode}');
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
            state.matchedLocation != '/signup' &&
            state.matchedLocation != '/organization-signup') {
          return '/login';
        }

        // Redirect to dashboard if authenticated and on login/splash/signup
        if (isLoggedIn &&
            (state.matchedLocation == '/login' ||
                state.matchedLocation == '/splash' ||
                state.matchedLocation == '/signup' ||
                state.matchedLocation == '/organization-signup')) {
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
          path: '/organization-signup',
          builder: (context, state) {
            final adminData = state.extra as Map<String, String>?;
            return OrganizationSignupScreen(prefillAdminData: adminData);
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
  }
}
