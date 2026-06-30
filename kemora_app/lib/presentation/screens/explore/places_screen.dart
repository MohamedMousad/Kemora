import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/editorial_place_card.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/place.dart';
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
      final vm = context.read<PlacesViewModel>();
      if (vm.governorates.isEmpty) {
        await vm.loadGovernorates();
      }
      if (widget.governorate != null) {
        // Find governorate ID
        final govId = vm.governorateIdByName(widget.governorate!);
        if (govId != null) {
          vm.loadPlacesByGovernorate(govId);
        } else {
          vm.loadPlaces();
        }
      } else {
        vm.loadPlaces();
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

  List<Place> _getFilteredPlaces(List<Place> places) {
    return places.where((place) {
      // 1. Filter by Search Query
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final govName = place.governorateName?.toLowerCase() ?? '';
        if (!place.name.toLowerCase().contains(query) && !govName.contains(query)) {
          return false;
        }
      }

      // 2. Filter by Category chip
      if (_selectedFilter != 0 && place.type != _filters[_selectedFilter]) {
        return false; // Assuming place.type is the category name for now
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: Consumer<PlacesViewModel>(
        builder: (context, placesViewModel, child) {
          if (placesViewModel.state == PlacesState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (placesViewModel.state == PlacesState.error) {
            return Center(
              child: Text(
                'Error: ${placesViewModel.errorMessage}',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
              ),
            );
          }

          final results = _getFilteredPlaces(placesViewModel.places);

          return CustomScrollView(
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
                                builder: (context) => PlaceDetailScreen(placeId: place.id),
                              ),
                            );
                          },
                          child: EditorialPlaceCard(
                            title: place.name,
                            category: place.type ?? 'Place',
                            location: place.address ?? place.governorateName ?? 'Egypt',
                            rating: place.rating.toDouble(),
                            reviewsCount: place.reviewsCount,
                            price: place.priceLevel != null ? '\$' * place.priceLevel! : 'Free',
                            distance: 'N/A', // Distance needs location services
                            isFavorite: false,
                            imageAsset: place.mainImageUrl ?? '',
                          ),
                        ),
                      );
                    },
                    childCount: results.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
