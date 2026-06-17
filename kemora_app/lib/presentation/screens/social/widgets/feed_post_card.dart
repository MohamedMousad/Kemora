import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class FeedPostCard extends StatelessWidget {
  final String? postId;
  final String authorName;
  final String location;
  final String timeAgo;
  final String content;
  final String hashtags;
  final String imageUrl;
  final int initialLikes;
  final bool isLiked;
  final int initialComments;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const FeedPostCard({
    super.key,
    this.postId,
    required this.authorName,
    required this.location,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.imageUrl,
    required this.initialLikes,
    this.isLiked = false,
    required this.initialComments,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  child: Center(
                      child: Text(authorName[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: AppColors.onSurface))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName, style: AppTypography.titleMedium),
                      Text(
                        '$location • $timeAgo',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
              ],
            ),
          ),

          // Post image
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainer,
                        child: const Center(
                            child: Icon(Icons.image,
                                size: 64, color: AppColors.outlineVariant)))),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text('EXPERT TIP',
                        style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLikeTap,
                      child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked
                              ? AppColors.primaryContainer
                              : AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text('$initialLikes',
                        style: AppTypography.labelLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: onCommentTap,
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text('$initialComments',
                              style: AppTypography.labelLarge
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.share, color: AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.onSurface, height: 1.5),
                    children: [
                      TextSpan(
                        text: '$authorName ',
                        style: AppTypography.labelLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: content),
                      TextSpan(
                        text: ' $hashtags',
                        style: const TextStyle(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
