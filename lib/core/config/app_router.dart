import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

/// Configuration du routing avec GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Routes d'authentification
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
      GoRoute(
        path: '/role-selection',
        redirect: (context, state) => '/auth/role-selection',
      ),

      // Routes principales
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Route des favoris
      GoRoute(
        path: '/saved',
        name: 'saved',
        builder: (context, state) => const SavedListingsScreen(),
      ),

      // Routes de détail
      GoRoute(
        path: '/listing/:id',
        name: 'listing-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: id);
        },
      ),

      // Route de recherche (à implémenter)
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      // Routes dashboard
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

      // Routes profil
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
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

      // Routes chat
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
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

// Placeholder screens - Seront implémentés dans les phases suivantes

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TogoStay')),
      body: const Center(child: Text('Main Screen with Bottom Nav - Phase 3')),
    );
  }
}

class ListingDetailScreen extends StatelessWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de l\'annonce')),
      body: Center(child: Text('Listing Detail $listingId - Phase 3')),
    );
  }
}

class AddListingScreen extends StatelessWidget {
  const AddListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une annonce')),
      body: const Center(child: Text('Add Listing Screen - Phase 6')),
    );
  }
}

class EditListingScreen extends StatelessWidget {
  final String listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier l\'annonce')),
      body: Center(child: Text('Edit Listing $listingId - Phase 6')),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: const Center(child: Text('Edit Profile Screen - Phase 7')),
    );
  }
}
