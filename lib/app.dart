import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:logements_app/core/config/app_router.dart';
import 'package:logements_app/core/theme/app_theme.dart';
import 'package:logements_app/shared/providers/theme_provider.dart';
import 'package:logements_app/features/auth/providers/auth_provider.dart';
import 'package:logements_app/features/home/providers/home_provider.dart';
import 'package:logements_app/features/saved/providers/saved_provider.dart';
import 'package:logements_app/features/listing_detail/providers/listing_detail_provider.dart';

/// Widget racine de l'application
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => HomeProvider()),
        provider.ChangeNotifierProvider(create: (_) => SavedProvider()),
        provider.ChangeNotifierProvider(create: (_) => ListingDetailProvider()),
      ],
      child: MaterialApp.router(
        title: 'TogoStay',
        debugShowCheckedModeBanner: false,

        // Thème
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

        // Router
        routerConfig: AppRouter.router,

        // Locale
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [
          Locale('fr', 'FR'),
        ],
      ),
    );
  }
}

