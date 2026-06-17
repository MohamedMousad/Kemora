import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/editorial_place_card.dart';
import '../../../data/local/place_data.dart';
import '../../../data/local/governorate_data.dart';
import 'place_detail_screen.dart';
import 'places_screen.dart';

/// Detailed view of a single governorate with categorized place sections,
/// matching the Home design style with a sticky search bar.
class GovernorateDetailScreen extends StatefulWidget {
  final GovernorateInfo governorate;
  const GovernorateDetailScreen({super.key, required this.governorate});

  @override
  State<GovernorateDetailScreen> createState() => _GovernorateDetailScreenState();
}

class _GovernorateDetailScreenState extends State<GovernorateDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaceInfo> get _govPlaces {
    return placesData
        .where((p) => p.governorateId == widget.governorate.id)
        .where((p) {
      if (_searchController.text.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
  }

  // Category groupings for the vertically stacked sections
  static const _sectionMap = {
    'Ancient Places': {'title': 'Historical & Ancient', 'icon': Icons.account_balance},
    'Museums': {'title': 'Museums & Cultural', 'icon': Icons.museum},
    'Hotels': {'title': 'Stay & Relax', 'icon': Icons.hotel},
    'Restaurants': {'title': 'Dining & Cuisine', 'icon': Icons.restaurant},
    'Others': {'title': 'Fun & Adventure', 'icon': Icons.explore},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: _buildHeader()),
          // Sticky search bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              controller: _searchController,
              onChanged: () => setState(() {}),
            ),
          ),
          // Categorized sections
          ..._buildSections(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DISCOVER', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
          const SizedBox(height: 8),
          Text(widget.governorate.name, style: AppTypography.displaySmall),
          const SizedBox(height: 12),
          // Weather row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wb_sunny_rounded, color: AppColors.tertiary, size: 20),
                const SizedBox(width: 8),
                Text(widget.governorate.temperature, style: AppTypography.titleMedium),
                const SizedBox(width: 12),
                Text(
                  widget.governorate.weather,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Top Activities
          Row(
            children: [
              ...widget.governorate.topActivities.take(2).map((a) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Chip(
                      avatar: Icon(a.icon, size: 16, color: AppColors.primaryContainer),
                      label: Text(a.label),
                      backgroundColor: AppColors.surfaceContainerLowest,
                      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                  )),
              if (widget.governorate.topActivities.length > 2)
                ActionChip(
                  label: Text('Show All (${widget.governorate.topActivities.length})',
                      style: TextStyle(color: AppColors.primaryContainer)),
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  onPressed: () => _showAllActivities(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    final places = _govPlaces;
    final sections = <Widget>[];

    for (final entry in _sectionMap.entries) {
      final categoryPlaces = places.where((p) => p.category == entry.key).toList();
      if (categoryPlaces.isEmpty) continue;

      sections.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(entry.value['icon'] as IconData, size: 20, color: AppColors.primaryContainer),
                  const SizedBox(width: 8),
                  Text(entry.value['title'] as String, style: AppTypography.titleLarge),
                ],
              ),
              if (categoryPlaces.length > 2)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PlacesScreen(governorate: widget.governorate.name),
                  )),
                  child: Text('See All →',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.primaryContainer)),
                ),
            ],
          ),
        ),
      ));

      sections.add(SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categoryPlaces.length,
            itemBuilder: (context, index) {
              final place = categoryPlaces[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 240,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place))),
                    child: EditorialPlaceCard(
                      title: place.name,
                      category: place.category,
                      location: place.location,
                      rating: place.rating,
                      reviewsCount: place.reviewsCount,
                      price: place.price,
                      distance: place.distance,
                      isFavorite: false,
                      imageAsset: place.imageAsset,
                      aspectRatio: 1.0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ));
    }

    if (sections.isEmpty) {
      sections.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Text(
              'No places found for ${widget.governorate.name}.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.outline),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ));
    }

    return sections;
  }

  void _showAllActivities(BuildContext context) {
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
            Text('Top Activities', style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.governorate.topActivities
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

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final VoidCallback onChanged;

  _SearchBarDelegate({required this.controller, required this.onChanged});

  @override
  double get minExtent => 72;
  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Search places...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close), onPressed: () { controller.clear(); onChanged(); })
                : null,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => true;
}
