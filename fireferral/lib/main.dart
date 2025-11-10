import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/app_state_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/invision_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/property_dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'themes/app_themes.dart';
import 'models/user_model.dart';

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
      redirect: (context, state) async {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        final currentUser = authProvider.currentUser;

        // Show splash while loading
        if (isLoading) {
          return '/splash';
        }

        // Check if Invision admin exists (for initial setup)
        if (!isLoggedIn && state.matchedLocation == '/splash') {
          final hasAdmin = await authProvider.hasInvisionAdmin();
          if (!hasAdmin) {
            return '/invision-setup';
          }
        }

        // Redirect to login if not authenticated
        if (!isLoggedIn &&
            state.matchedLocation != '/login' &&
            state.matchedLocation != '/invision-setup') {
          return '/login';
        }

        // Redirect to appropriate dashboard based on role
        if (isLoggedIn &&
            (state.matchedLocation == '/login' ||
                state.matchedLocation == '/splash' ||
                state.matchedLocation == '/invision-setup')) {
          // Route to appropriate dashboard based on user role
          if (currentUser?.role == UserRole.invisionAdmin) {
            return '/admin-dashboard';
          } else if (currentUser?.role == UserRole.property) {
            return '/property-dashboard';
          }
          return '/admin-dashboard'; // Default fallback
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/invision-setup',
          builder: (context, state) => const InvisionSetupScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/property-dashboard',
          builder: (context, state) => const PropertyDashboardScreen(),
        ),
        // Legacy route for backward compatibility
        GoRoute(
          path: '/dashboard',
          redirect: (context, state) {
            final currentUser = authProvider.currentUser;
            if (currentUser?.role == UserRole.invisionAdmin) {
              return '/admin-dashboard';
            } else if (currentUser?.role == UserRole.property) {
              return '/property-dashboard';
            }
            return '/admin-dashboard';
          },
        ),
      ],
    );
  }
}
