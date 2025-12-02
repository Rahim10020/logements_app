import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logements_app/presentation/pages/auth/login_page.dart';
import 'package:logements_app/presentation/pages/auth/register_page.dart';
import 'package:logements_app/presentation/pages/auth/role_selection_page.dart';
import 'package:logements_app/presentation/pages/home/home_page.dart';
import 'package:logements_app/presentation/pages/favorites/favorites_page.dart';
import 'package:logements_app/presentation/pages/profile/profile_page.dart';
import 'package:logements_app/presentation/pages/main_page.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';

/// Configuration du routeur
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation.startsWith('/role-selection');

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) {
          final userData = state.extra as Map<String, dynamic>;
          return RoleSelectionPage(userData: userData);
        },
      ),

      // Main navigation with bottom bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Search Page - À implémenter')),
                ),
              ),
            ],
          ),

          // Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),

          // Dashboard (owners)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Dashboard Page - À implémenter')),
                ),
              ),
            ],
          ),

          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Listing detail (outside bottom navigation)
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            body: Center(child: Text('Listing Detail Page - ID: $id')),
          );
        },
      ),
    ],
  );
});
