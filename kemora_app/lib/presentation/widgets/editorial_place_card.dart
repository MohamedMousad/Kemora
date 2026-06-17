import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_shadows.dart';
import 'glassmorphism_container.dart';

class EditorialPlaceCard extends StatelessWidget {
  final String title;
  final String category;
  final String location;
  final double rating;
  final int reviewsCount;
  final String price;
  final String? distance;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final double aspectRatio;
  final String? imageAsset;
  final String? imageUrl;

  const EditorialPlaceCard({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    this.distance,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.aspectRatio = 0.56,
    this.imageAsset,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.ambient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            AspectRatio(
              aspectRatio: aspectRatio > 1 ? aspectRatio : 1 / (1 / aspectRatio), // handle both wide and tall
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or Placeholder
                    if (imageUrl != null && imageUrl!.startsWith('http'))
                      Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainer,
                          child: const Center(
                            child: Icon(Icons.image_outlined, color: AppColors.outline, size: 48),
                          ),
                        ),
                      )
                    else if (imageAsset != null)
                      Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainer,
                          child: const Center(
                            child: Icon(Icons.image_outlined, color: AppColors.outline, size: 48),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.surfaceContainer,
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: AppColors.outline, size: 48),
                        ),
                      ),
                    
                    // Category Badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSecondaryFixed,
                          ),
                        ),
                      ),
                    ),
                    
                    // Favorite Button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: GlassmorphismContainer(
                          opacity: 0.2,
                          blurRadius: 10,
                          borderRadius: BorderRadius.circular(999),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.primaryContainer : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.tertiary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${reviewsCount ~/ 1000}k)',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.outline),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.onSurfaceVariant, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                          ),
                          Text(
                            ' / entry',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.outline),
                          ),
                        ],
                      ),
                      if (distance != null)
                        Row(
                          children: [
                            const Icon(Icons.near_me_outlined, color: AppColors.onSurfaceVariant, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              distance!,
                              style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
