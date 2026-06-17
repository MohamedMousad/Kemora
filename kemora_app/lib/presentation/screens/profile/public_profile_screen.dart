import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/local/achievement_data.dart';
import '../../../providers/voucher_provider.dart';
import 'all_achievements_screen.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/tap_scale.dart';
import '../../../core/router/page_transitions.dart';
import 'saved_places_screen.dart';
import 'redeemed_vouchers_screen.dart';
import 'package:image_picker/image_picker.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!context.mounted) return;
      await context.read<AuthViewModel>().uploadProfilePicture(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherProvider = context.watch<VoucherProvider>();
    final int availablePoints = voucherProvider.availablePoints;
    final top4Achievements = achievementsData.take(4).toList();
    
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;
    final userName = user?.fullName ?? 'Traveler';
    final userLocation = user?.country ?? 'Earth';
    final profilePic = user?.profilePictureUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surfaceContainerLow,
              padding: const EdgeInsets.only(top: 120, bottom: 40),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20)
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: profilePic != null && profilePic.isNotEmpty
                                ? Image.network(profilePic, fit: BoxFit.cover, width: 120, height: 120)
                                : const Icon(Icons.person, size: 64, color: AppColors.outlineVariant),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delayMs: 100,
                    child: Column(
                      children: [
                        Text(userName, style: AppTypography.headlineMedium),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text('ELITE TRAVELER',
                                  style: AppTypography.labelSmall
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('12 Destinations Visited • $userLocation',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.onSurfaceVariant)),
                        if (authVM.state == AuthState.loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24)
                  .copyWith(bottom: 120), // Bottom nav padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    delayMs: 200,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ACHIEVEMENTS',
                                style: AppTypography.labelSmall),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    SlidePageRoute(
                                        child: const AllAchievementsScreen()));
                              },
                              child: Text('View All →',
                                  style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.primaryContainer)),
                            ),
                          ],
                        ),

                        // Total Points and Redeem Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: AppColors.primaryContainer,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text('$availablePoints pts',
                                      style: AppTypography.labelMedium.copyWith(
                                          color: AppColors.primaryContainer)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _showRedeemModal(context, voucherProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999)),
                              ),
                              child: const Text('REDEEM'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Bento Cards for Top 4 Achievements
                        Column(
                          children: top4Achievements
                              .map((achievement) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildAchievementBento(achievement),
                                  ))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        // Nav List
                        _buildNavRow(
                            Icons.favorite, 'Saved Places', '12 places', () {
                              Navigator.push(context, SlidePageRoute(child: const SavedPlacesScreen()));
                            }),
                        _buildNavRow(
                            Icons.card_giftcard, 'Redeemed Vouchers', null, () {
                              Navigator.push(context, SlidePageRoute(child: const RedeemedVouchersScreen()));
                            }),

                        const SizedBox(height: 40),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.settings,
                                color: AppColors.onSurfaceVariant),
                            label: Text('Settings',
                                style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                          ),
                        ),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              context.read<AuthViewModel>().logout();
                            },
                            icon: const Icon(Icons.logout,
                                color: AppColors.error),
                            label: Text('Log Out',
                                style: AppTypography.labelLarge
                                    .copyWith(color: AppColors.error)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBento(AchievementInfo achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isEarned
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: achievement.isEarned
            ? Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.3))
            : null,
        boxShadow: achievement.isEarned
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isEarned
                  ? AppColors.primaryContainer.withValues(alpha: 0.1)
                  : AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .workspace_premium, // You could map icons dynamically based on ID
              color: achievement.isEarned
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
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
                    color: achievement.isEarned
                        ? AppColors.onSurface
                        : AppColors.outlineVariant,
                  ),
                ),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: achievement.isEarned
                        ? AppColors.onSurfaceVariant
                        : AppColors.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!achievement.isEarned)
                const Icon(Icons.lock,
                    size: 16, color: AppColors.outlineVariant),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${achievement.points} pts',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.outline)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(IconData icon, String title, String? subtitle, VoidCallback onTap) {
    return TapScale(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.primaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium),
                    if (subtitle != null)
                      Text(subtitle,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _showRedeemModal(BuildContext context, VoucherProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // We use StatefulBuilder so we can rebuild just the bottom sheet if points change while it's open.
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Redeem Rewards', style: AppTypography.headlineMedium),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${provider.availablePoints} pts',
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.primaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: availableRewards.map((reward) {
                          final canAfford = provider.canAfford(reward.pointsCost);
                          return _buildRewardItem(context, setState, provider, reward, canAfford);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildRewardItem(BuildContext context, StateSetter setState, VoucherProvider provider, RewardItem reward, bool canAfford) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: canAfford ? () {
          final voucher = provider.redeemVoucher(reward);
          if (voucher != null) {
            setState(() {}); // refresh the bottom sheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Redeemed ${reward.title}! Check your vouchers.')),
            );
          }
        } : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: canAfford ? AppColors.primaryContainer.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: canAfford ? [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canAfford ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(reward.icon, color: canAfford ? AppColors.primaryContainer : AppColors.outlineVariant),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reward.title, style: AppTypography.titleMedium.copyWith(color: canAfford ? AppColors.onSurface : AppColors.onSurfaceVariant)),
                    Text(reward.partner,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${reward.pointsCost} pts',
                    style: AppTypography.labelSmall
                        .copyWith(color: canAfford ? Colors.white : AppColors.outline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
