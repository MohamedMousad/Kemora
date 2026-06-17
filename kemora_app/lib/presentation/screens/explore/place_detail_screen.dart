import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/glassmorphism_container.dart';
import '../../../data/local/place_data.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/place.dart' as domain;


class PlaceDetailScreen extends StatefulWidget {
  // Legacy path: pass a PlaceInfo from local mock data
  final PlaceInfo? place;

  // New path: pass an API id + name; screen loads from PlacesViewModel
  final String? placeId;
  final String? placeName;

  const PlaceDetailScreen({
    super.key,
    this.place,
    this.placeId,
    this.placeName,
  }) : assert(place != null || placeId != null,
            'Either place or placeId must be provided');

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  domain.Place? _apiPlace;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.placeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final vm = context.read<PlacesViewModel>();
        final loaded = await vm.getPlaceById(widget.placeId!);
        if (mounted) setState(() => _apiPlace = loaded);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Getters for unified access ──────────────────────────────────────────────

  String get _title =>
      _apiPlace?.name ?? widget.place?.name ?? widget.placeName ?? '';

  String get _category =>
      _apiPlace?.type ??
      widget.place?.category ??
      'Place';

  String get _location =>
      _apiPlace?.address ??
      _apiPlace?.governorateName ??
      widget.place?.location ??
      '';

  String get _description =>
      _apiPlace?.description ?? widget.place?.description ?? '';

  double get _rating =>
      (_apiPlace?.rating ?? widget.place?.rating ?? 0).toDouble();

  String get _price =>
      _apiPlace?.priceLevel != null
          ? '\$' * _apiPlace!.priceLevel!
          : widget.place?.price ?? '';

  String? get _imageUrl => _apiPlace?.mainImageUrl;
  String? get _imageAsset => widget.place?.imageAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.55,
              pinned: true,
              leading: IconButton(
                icon: GlassmorphismContainer(
                  padding: const EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(999),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: GlassmorphismContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(999),
                    child: const Icon(Icons.share, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: GlassmorphismContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(999),
                    child: const Icon(Icons.favorite_border, color: Colors.white),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to favorites!')),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero image — prefer network, fallback to asset, then placeholder
                    if (_imageUrl != null)
                      Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(
                              child: Icon(Icons.image, size: 100, color: AppColors.outlineVariant)),
                        ),
                      )
                    else if (_imageAsset != null)
                      Image.asset(
                        _imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(
                              child: Icon(Icons.image, size: 100, color: AppColors.outlineVariant)),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Center(child: Icon(Icons.image, size: 100, color: AppColors.outlineVariant)),
                      ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 40,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(_category.toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSecondaryFixed)),
                          ),
                          const SizedBox(height: 16),
                          Text(_title,
                              style: AppTypography.displayMedium.copyWith(color: Colors.white)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppColors.primaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text(_location,
                                  style: AppTypography.bodyLarge.copyWith(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryContainer,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  indicatorColor: AppColors.primaryContainer,
                  indicatorWeight: 3,
                  labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Info'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Community'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: AppColors.surfaceContainerLowest,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(),
              _buildReviewsTab(),
              _buildCommunityTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -10))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STARTING FROM', style: AppTypography.labelSmall),
                RichText(
                  text: TextSpan(
                    style: AppTypography.titleLarge.copyWith(color: AppColors.onSurface),
                    children: [
                      TextSpan(text: _price.isEmpty ? 'Free' : _price),
                      TextSpan(
                          text: ' / entry',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: null, // [KEMORA-TODO] Wire to AiStepQuestionsScreen pre-seeded with this place
              child: const Text('Add to trip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final reviews = _apiPlace?.reviews ?? [];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text('08:00 – 17:00', style: AppTypography.labelMedium),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Text(_rating.toStringAsFixed(1), style: AppTypography.labelMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          _description.isNotEmpty ? _description : 'No description available.',
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: 40),
        // Google Maps link if available
        if (_apiPlace?.website != null) ...[
          OutlinedButton.icon(
            onPressed: () {
              // [KEMORA-TODO] Launch URL
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_apiPlace!.website!)),
              );
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open in Google Maps'),
          ),
          const SizedBox(height: 24),
        ],
        Container(
          height: 150,
          decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text('Map View')),
        ),
        // Real reviews preview
        if (reviews.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text('Recent Reviews', style: AppTypography.titleMedium),
          const SizedBox(height: 16),
          ...reviews.take(2).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReviewItem(r.authorName, r.text, r.rating.toDouble()),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildReviewsTab() {
    final reviews = _apiPlace?.reviews ?? [];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_rating.toStringAsFixed(1), style: AppTypography.displayLarge),
                Text(
                    'Based on ${reviews.isNotEmpty ? reviews.length : widget.place?.reviewsCount ?? 0} reviews',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildAddReviewSheet(),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Write a Review'),
            )
          ],
        ),
        const SizedBox(height: 32),
        if (reviews.isEmpty) ...[
          _buildReviewItem(
              'Sarah Jenkins',
              'Amazing experience. The history here is palpable and beautifully preserved.',
              5),
          const Divider(height: 32),
          _buildReviewItem(
              'Mark R.',
              'A must visit! We went early in the morning and avoided the crowds.',
              4.5),
        ] else
          ...reviews.map((r) => Column(
                children: [
                  _buildReviewItem(r.authorName, r.text, r.rating.toDouble()),
                  const Divider(height: 32),
                ],
              )),
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(color: AppColors.onSurface)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.titleMedium),
                  Row(
                    children: List.generate(
                        5,
                        (index) => Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: AppColors.tertiary,
                            )),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(comment, style: AppTypography.bodyMedium),
      ],
    );
  }

  Widget _buildAddReviewSheet() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Write a Review', style: AppTypography.headlineSmall),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (index) => IconButton(
                      icon: const Icon(Icons.star_border,
                          size: 40, color: AppColors.outlineVariant),
                      onPressed: () {},
                    )),
          ),
          const SizedBox(height: 24),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surfaceContainer,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56)),
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Community Posts', style: AppTypography.titleLarge),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Community posts for this place will appear here.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.surfaceContainerLowest, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
