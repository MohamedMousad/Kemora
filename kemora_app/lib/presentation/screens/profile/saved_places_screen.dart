import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../../data/local/place_data.dart';
import '../explore/place_detail_screen.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedPlaces = placesData; // mock data

    return Scaffold(
      appBar: KemoraAppBar(
        showBack: true,
        trailing: Text('Saved Places', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: savedPlaces.length,
        itemBuilder: (context, index) {
          final place = savedPlaces[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.image, color: AppColors.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.name, style: AppTypography.titleMedium),
                          const SizedBox(height: 4),
                          Text(place.location, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.tertiary),
                              const SizedBox(width: 4),
                              Text('${place.rating}', style: AppTypography.labelSmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.favorite, color: AppColors.primaryContainer),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
