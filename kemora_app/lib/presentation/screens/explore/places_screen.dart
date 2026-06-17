import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/editorial_place_card.dart';
import '../../../data/local/place_data.dart';
import '../../../data/local/governorate_data.dart';
import 'place_detail_screen.dart';

class PlacesScreen extends StatefulWidget {
  final String? governorate;
  
  const PlacesScreen({super.key, this.governorate});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Ancient Places', 'Museums', 'Hotels', 'Restaurants', 'Others'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<PlaceInfo> get _filteredPlaces {
    return placesData.where((place) {
      // 1. Filter by governorate if provided
      if (widget.governorate != null) {
        final govId = governoratesData.firstWhere((g) => g.name == widget.governorate, orElse: () => governoratesData.first).id;
        if (place.governorateId != govId) {
          return false;
        }
      }

      // 2. Filter by Search Query
      if (_searchController.text.isNotEmpty &&
          !place.name.toLowerCase().contains(_searchController.text.toLowerCase())) {
        return false;
      }

      // 3. Filter by Category chip
      if (_selectedFilter != 0 && place.category != _filters[_selectedFilter]) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredPlaces;

    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.governorate != null) ...[
                    Text('DISCOVER', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
                    const SizedBox(height: 8),
                    Text(widget.governorate!, style: AppTypography.headlineLarge),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search places...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchController.clear())
                          : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: FilterChipRow(
              chips: _filters,
              selectedIndex: _selectedFilter,
              onSelected: (i) => setState(() => _selectedFilter = i),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          if (results.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Text(
                    'No places found matching your criteria.',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.outline),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final place = results[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailScreen(place: place),
                          ),
                        );
                      },
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
                      ),
                    ),
                  );
                },
                childCount: results.length,
              ),
            ),
        ],
      ),
    );
  }
}
