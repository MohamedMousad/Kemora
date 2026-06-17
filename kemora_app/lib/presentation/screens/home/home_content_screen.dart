import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/editorial_place_card.dart';
import '../explore/place_detail_screen.dart';
import '../../viewmodels/places_view_model.dart';
import '../../viewmodels/story_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/tap_scale.dart';
import '../../../core/router/page_transitions.dart';
import '../trip/ai_step_questions_screen.dart';
import '../social/widgets/story_viewer_screen.dart';
import '../social/create_post_screen.dart';
import '../../../data/models/story_model.dart';

class HomeContentScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const HomeContentScreen({super.key, this.onSwitchTab});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All Odyssey',
    'Ancient Ruins',
    'Nile Cruises',
    'Desert Safari'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placesVM = context.read<PlacesViewModel>();
      if (placesVM.topPlaces.isEmpty) placesVM.loadTopPlaces();
      final storyVM = context.read<StoryViewModel>();
      if (storyVM.state == StoryState.initial) storyVM.loadActiveStories();
    });
  }

  String get _sectionTitle {
    switch (_selectedFilterIndex) {
      case 0: return 'The Modern Archivist';
      case 1: return 'Ancient Wonders';
      case 2: return 'Nile Experiences';
      case 3: return 'Desert Adventures';
      default: return 'The Modern Archivist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final placesVM = context.watch<PlacesViewModel>();
    final storyVM = context.watch<StoryViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final topPlaces = placesVM.topPlaces;
    final userName = authVM.user?.fullName?.split(' ').first ?? 'Traveller';
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
        
        // Greeting
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text(
              'WELCOME BACK',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: AppTypography.headlineLarge
                    .copyWith(color: AppColors.onSurface),
                children: [
                  const TextSpan(text: 'Good morning, '),
                  TextSpan(
                    text: userName,
                    style: const TextStyle(color: AppColors.primaryContainer),
                  ),
                ],
              ),
            ),
          ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Sticky Search Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickySearchDelegate(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Filters
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 240,
            child: FilterChipRow(
              chips: _filters,
              selectedIndex: _selectedFilterIndex,
              onSelected: (index) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // The Modern Archivist section header
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 320,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_sectionTitle, style: AppTypography.titleLarge),
                  Row(
                    children: [
                      Text(
                        'View All',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.primaryContainer),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primaryContainer, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Place cards carousel — from PlacesViewModel (real API)
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 400,
            child: SizedBox(
              height: 380,
              child: placesVM.state == PlacesState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : topPlaces.isEmpty
                      ? const Center(
                          child: Text('No places loaded yet.',
                              style: TextStyle(color: AppColors.onSurfaceVariant)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: topPlaces.length > 8 ? 8 : topPlaces.length,
                          itemBuilder: (context, index) {
                            final place = topPlaces[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 260,
                                child: TapScale(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        child: PlaceDetailScreen(
                                          placeId: place.id,
                                          placeName: place.name,
                                        ),
                                      ),
                                    );
                                  },
                                  child: EditorialPlaceCard(
                                    title: place.name,
                                    category: place.type ?? 'Place',
                                    location: place.address ?? place.governorateName ?? '',
                                    rating: place.rating,
                                    reviewsCount: 0,
                                    price: '\$' * (place.priceLevel ?? 0),
                                    distance: '',
                                    isFavorite: false,
                                    imageUrl: place.mainImageUrl,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),

        // Community Stories section — from StoryViewModel (real API)
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 500,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Community Stories', style: AppTypography.titleLarge),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildStoryItem(context, isAdd: true, name: 'Your Story'),
                        const SizedBox(width: 16),
                        if (storyVM.state == StoryState.loading)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          )
                        else
                          ...storyVM.activeStories.map((group) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildStoryItem(
                              context,
                              name: group.userName,
                              imageUrl: group.userProfilePicture ?? group.stories.first.mediaUrl,
                              userGroup: group,
                            ),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),

        // Explore by Region Card
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 600,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TapScale(
                onTap: () {
                  if (widget.onSwitchTab != null) {
                    widget.onSwitchTab!(1);
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                          child: Icon(Icons.map,
                              size: 64, color: AppColors.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CARTOGRAPHY',
                                style: AppTypography.labelSmall
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Explore by Region',
                              style: AppTypography.headlineSmall
                                  .copyWith(color: AppColors.onSurface),
                            ),
                            Text(
                              'Discover the 27 Governorates',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: AppColors.onPrimary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // AI Trip Builder Card
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delayMs: 700,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TapScale(
                onTap: () {
                  Navigator.push(context, SlidePageRoute(child: const AiStepQuestionsScreen()));
                },
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make Your Trip with AI',
                              style: AppTypography.titleLarge.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Personalized itinerary in seconds',
                              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStoryItem(BuildContext context, {
    bool isAdd = false,
    required String name,
    String? imageUrl,
    UserStoriesGroup? userGroup,
  }) {
    Widget imageWidget;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      imageWidget = Image.network(imageUrl, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceContainerHigh,
          child: const Icon(Icons.person, color: AppColors.outlineVariant, size: 40),
        ));
    } else {
      imageWidget = Container(
        color: AppColors.surfaceContainerHigh,
        child: const Icon(Icons.person, color: AppColors.outlineVariant, size: 40),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isAdd && userGroup != null) {
          Navigator.push(
            context,
            FadePageRoute(child: StoryViewerScreen(userGroup: userGroup)),
          );
        } else if (isAdd) {
          Navigator.push(context, FadePageRoute(child: const CreatePostScreen(isStory: true)));
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondaryContainer]),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipOval(child: imageWidget),
                  if (isAdd)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.add, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface, // Matches background to hide content scrolling behind
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () {
            // [KEMORA-PLACEHOLDER] SearchScreen
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppColors.primaryContainer, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Where to next?',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.outline),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // [KEMORA-PLACEHOLDER] SearchFiltersScreen
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune,
                        color: AppColors.onSurface, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchDelegate oldDelegate) => false;
}
