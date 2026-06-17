import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../data/local/governorate_data.dart';
import 'governorate_detail_screen.dart';
import '../../widgets/fade_slide_in.dart';
import '../../../core/router/page_transitions.dart';

class GovernoratesMapScreen extends StatefulWidget {
  const GovernoratesMapScreen({super.key});

  @override
  State<GovernoratesMapScreen> createState() => _GovernoratesMapScreenState();
}

class _GovernoratesMapScreenState extends State<GovernoratesMapScreen> {
  int _selectedIndex = 0;

  void _nextGovernorate() {
    setState(() {
      if (_selectedIndex < governoratesData.length - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }
    });
  }

  void _prevGovernorate() {
    setState(() {
      if (_selectedIndex > 0) {
        _selectedIndex--;
      } else {
        _selectedIndex = governoratesData.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final governorate = governoratesData[_selectedIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Background Map Placeholder
          FadeSlideIn(
            delayMs: 0,
            child: Container(
              color: AppColors.surfaceContainerHigh,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                  child: Icon(Icons.map,
                      size: 200, color: AppColors.outlineVariant)),
            ),
          ),

          // Map Dots (render all 27)
          ...governoratesData.asMap().entries.map((entry) {
            final int index = entry.key;
            final GovernorateInfo gov = entry.value;
            final bool isSelected = index == _selectedIndex;

            return Positioned(
              top: MediaQuery.of(context).size.height * gov.latitude,
              left: MediaQuery.of(context).size.width * gov.longitude,
              child: FadeSlideIn(
                delayMs: 200,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: isSelected
                      ? Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        )
                      : Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
            );
          }),

          // Header Content
          FadeSlideIn(
            delayMs: 100,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTypography.displaySmall
                            .copyWith(color: AppColors.onSurface),
                        children: const [
                          TextSpan(text: 'Explore the\n'),
                          TextSpan(
                            text: 'Governorates',
                            style: TextStyle(color: AppColors.primaryContainer),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select a region to discover historical treasures and modern marvels.',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeSlideIn(
              delayMs: 350,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: AppShadows.floatingIsland,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Navigation arrows + centered name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.outline),
                          onPressed: _prevGovernorate,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(governorate.name.toUpperCase(),
                                  style: AppTypography.headlineLarge, textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text(governorate.region,
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.outline),
                          onPressed: _nextGovernorate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Weather info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wb_sunny, color: AppColors.primaryContainer, size: 20),
                        const SizedBox(width: 8),
                        Text(governorate.temperature, style: AppTypography.titleLarge.copyWith(color: AppColors.primaryContainer)),
                        const SizedBox(width: 12),
                        Text(governorate.weather, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Top Activities (2 + Show All)
                    Text('TOP ACTIVITIES', style: AppTypography.labelSmall),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...governorate.topActivities.take(2)
                            .map((act) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _buildActivityIcon(act.icon, act.label),
                                )),
                        if (governorate.topActivities.length > 2)
                          GestureDetector(
                            onTap: () => _showAllActivities(context, governorate),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Show All',
                                  style: AppTypography.labelMedium.copyWith(color: AppColors.primaryContainer)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(SlidePageRoute(
                          child: GovernorateDetailScreen(governorate: governorate),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('View Destination'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryContainer),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.labelMedium),
        ],
      ),
    );
  }

  void _showAllActivities(BuildContext context, GovernorateInfo gov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${gov.name} Activities', style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gov.topActivities
                  .map((a) => Chip(
                        avatar: Icon(a.icon, size: 16),
                        label: Text(a.label),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
