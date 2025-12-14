import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/saved/screens/saved_listings_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/add_edit_listing_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/listing_detail/screens/listing_detail_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../widgets/bottom_nav_shell.dart';

/// Configuration du routing avec GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,

    // Redirect global pour protéger certaines routes et forcer la sélection de rôle
    redirect: (BuildContext context, GoRouterState state) {
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = auth.currentUser != null;
        final userRole = auth.userModel?.role ?? '';
        final loc = state.uri.toString();

        // Routes qui nécessitent l'authentification
        final protectedPrefixes = [
          '/saved',
          '/conversations',
          '/profile',
          '/dashboard',
          '/chat',
        ];

        final isProtected = protectedPrefixes.any((p) => loc.startsWith(p));

        // Si utilisateur non connecté et route protégée -> redirection vers login
        if (!isLoggedIn && isProtected) {
          return '/auth/login?from=${Uri.encodeComponent(loc)}';
        }

        // Après connexion, si role non défini et on n'est pas déjà sur le flow d'auth -> forcer role-selection
        final isOnAuthFlow = loc.startsWith('/auth') || loc.startsWith('/role-selection') || loc.startsWith('/auth/role-selection') || loc.startsWith('/auth/login') || loc.startsWith('/auth/register');
        if (isLoggedIn && (userRole.isEmpty) && !isOnAuthFlow) {
          return '/auth/role-selection';
        }

        return null;
      } catch (e) {
        // Si Provider non disponible (ex: au tout début de l'app), ne pas rediriger
        return null;
      }
    },

    routes: [
      // Routes d'authentification (gardées en top-level)
      GoRoute(
        path: '/auth/login',
        name: 'auth-login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) => '/auth/login',
      ),
      GoRoute(
        path: '/auth/register',
        name: 'auth-register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register',
        redirect: (context, state) => '/auth/register',
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'auth-forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        redirect: (context, state) => '/auth/forgot-password',
      ),
      GoRoute(
        path: '/auth/role-selection',
        name: 'auth-role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // ShellRoute qui contient la BottomNavigationBar pour les onglets principaux
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) => '/home',
          ),
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/saved',
            name: 'saved',
            builder: (context, state) => const SavedListingsScreen(),
          ),
          GoRoute(
            path: '/conversations',
            name: 'conversations',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Routes non-onglets / détails (restent en top-level pour être ouvertes sans la bottom bar si souhaité)
      GoRoute(
        path: '/listing/:id',
        name: 'listing-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: id);
        },
      ),

      // Routes dashboard (protégées par le redirect global)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/add-listing',
        name: 'add-listing',
        builder: (context, state) => const AddEditListingScreen(),
      ),
      GoRoute(
        path: '/dashboard/edit-listing/:id',
        name: 'edit-listing',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddEditListingScreen(listingId: id);
        },
      ),

      // Profile edit/settings
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Chat
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(conversationId: id, extra: extra);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}

