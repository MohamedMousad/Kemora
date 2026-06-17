import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../../data/local/achievement_data.dart';

class AllAchievementsScreen extends StatelessWidget {
  const AllAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int totalPoints = achievementsData.where((a) => a.isEarned).fold(0, (sum, a) => sum + a.points);

    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR LEGACY', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('All Achievements', style: AppTypography.headlineLarge),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.primaryContainer, size: 20),
                        const SizedBox(width: 8),
                        Text('$totalPoints Points Earned', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final achievement = achievementsData[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildAchievementBento(achievement),
                  );
                },
                childCount: achievementsData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBento(AchievementInfo achievement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: achievement.isEarned ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: achievement.isEarned ? Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)) : null,
        boxShadow: achievement.isEarned ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isEarned ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium, // You could map this dynamically later
              color: achievement.isEarned ? AppColors.primaryContainer : AppColors.outlineVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: achievement.isEarned ? AppColors.onSurface : AppColors.outlineVariant,
                  ),
                ),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: achievement.isEarned ? AppColors.onSurfaceVariant : AppColors.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!achievement.isEarned) const Icon(Icons.lock, size: 16, color: AppColors.outlineVariant),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${achievement.points} pts', style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
