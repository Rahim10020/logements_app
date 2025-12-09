import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Widget carousel d'images pour les annonces
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final VoidCallback? onViewAll;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.onViewAll,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        // Carousel d'images
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        // Indicateur de position
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.imageUrls.length,
                  effect: const WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        // Bouton "Voir toutes les photos"
        if (widget.imageUrls.length > 1 && widget.onViewAll != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: widget.onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Voir (${widget.imageUrls.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 300,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }
}
