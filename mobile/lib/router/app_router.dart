import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart' show authProvider, AuthState;
import '../ui/screens/app_settings_screen.dart';
import '../ui/screens/booking_detail_loader_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (auth.isLoading && loc != '/splash') {
        return '/splash';
      }
      if (auth.isAuthenticated &&
          (loc == '/splash' || loc == '/login' || loc == '/onboarding')) {
        return '/home';
      }
      if (!auth.isAuthenticated &&
          (loc == '/home' || loc.startsWith('/booking/'))) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/booking/:bookingId',
        builder: (_, state) {
          final id = state.pathParameters['bookingId']!;
          return BookingDetailLoaderScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const AppSettingsScreen(),
      ),
    ],
  );

  ref.listen<AuthState>(authProvider, (_, __) => router.refresh());
  return router;
});
