import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/core/constants/app_dimensions.dart';
import 'package:logements_app/core/constants/app_strings.dart';
import 'package:logements_app/presentation/providers/listing_provider.dart';
import 'package:logements_app/presentation/widgets/listing_card.dart';

/// Page d'accueil
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(listingsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.appTagline,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppDimensions.spacing16),

                          // Barre de recherche
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLarge,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: AppStrings.searchPlaceholder,
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.tune),
                                  onPressed: () => context.push('/search'),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacing16,
                                  vertical: AppDimensions.spacing16,
                                ),
                              ),
                              onTap: () => context.push('/search'),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Liste des annonces
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 64,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: AppDimensions.spacing16),
                            Text(
                              AppStrings.noResults,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: AppDimensions.spacing12,
                        mainAxisSpacing: AppDimensions.spacing12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listing = listings[index];
                          return ListingCard(
                            listing: listing,
                            onTap: () => context.push('/listing/${listing.id}'),
                          );
                        },
                        childCount: listings.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppDimensions.spacing16),
                        Text(
                          'Erreur: $error',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
