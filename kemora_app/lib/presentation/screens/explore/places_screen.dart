import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/editorial_place_card.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/place.dart' as domain;
import '../../../data/local/governorate_data.dart';
import 'place_detail_screen.dart';

class PlacesScreen extends StatefulWidget {
  final String? governorate;
  final String? initialSearchQuery;
  
  const PlacesScreen({super.key, this.governorate, this.initialSearchQuery});

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
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _searchController.addListener(_onSearchChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final placesVM = context.read<PlacesViewModel>();
      if (placesVM.governorates.isEmpty) {
        await placesVM.loadGovernorates();
      }
      
      if (widget.governorate != null && placesVM.governorates.isNotEmpty) {
        final gov = placesVM.governorates.firstWhere(
          (g) => g.name.toLowerCase() == widget.governorate!.toLowerCase(),
          orElse: () => placesVM.governorates.first,
        );
        placesVM.loadPlacesByGovernorate(gov.id.toString());
      } else {
        placesVM.loadPlaces();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<domain.Place> get _filteredPlaces {
    final vm = context.watch<PlacesViewModel>();
    final places = vm.places;

    return places.where((place) {
      // 1. Filter by Search Query (Name)
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!place.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 2. Filter by Category chip
      // Adjust category logic to match your API format. Our API returns "Hotels", "Museums" etc.
      // Or we can just check if place.category contains it.
      if (_selectedFilter != 0) {
        final selectedCat = _filters[_selectedFilter];
        final cat = place.category.toLowerCase();
        switch (selectedCat) {
          case 'Museums': return cat.contains('museum');
          case 'Hotels': return cat.contains('hotel') || cat.contains('resort');
          case 'Restaurants': return cat.contains('restaurant') || cat.contains('cafe') || cat.contains('food');
          case 'Ancient Places': return cat.contains('temple') || cat.contains('pyramid') || cat.contains('historical') || cat.contains('citadel');
          case 'Others': return cat.contains('park') || cat.contains('beach') || cat.contains('adventure') || cat.contains('shopping') || cat.contains('market') || cat.contains('mosque') || cat.contains('church') || cat == 'uncategorized';
          default: return false;
        }
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
                            builder: (context) => PlaceDetailScreen(placeId: place.id.toString()),
                          ),
                        );
                      },
                      child: EditorialPlaceCard(
                        title: place.name,
                        category: place.category,
                        location: place.address ?? place.governorateName ?? 'Egypt',
                        rating: place.rating,
                        reviewsCount: place.reviews.length,
                        price: place.priceLevel != null && place.priceLevel! > 0 ? '\$' * place.priceLevel! : 'Free',
                        distance: null,
                        isFavorite: false,
                        imageUrl: place.mainImageUrl ?? place.imageUrl,
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
