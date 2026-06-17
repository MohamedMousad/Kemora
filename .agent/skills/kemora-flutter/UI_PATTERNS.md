---
name: flutter-ui-patterns
description: Modern Flutter UI/UX patterns, Material 3 best widgets, animation techniques, and premium design patterns for the Kemora app (2026).
---

# Flutter UI/UX Patterns Skill (2026)

## Material 3 Essential Widgets

### Navigation
| Widget | Purpose | When to Use |
|--------|---------|-------------|
| `NavigationBar` | Bottom navigation (M3) | Primary app navigation (replaces BottomNavigationBar) |
| `NavigationRail` | Side navigation | Tablet/desktop layouts |
| `NavigationDrawer` | Slide-out navigation | Secondary navigation or settings |
| `SearchBar` + `SearchAnchor` | Search UI | Global or feature-level search |
| `MenuAnchor` + `MenuBar` | Context/desktop menus | Options, filters, sort menus |

### Content Display
| Widget | Purpose | When to Use |
|--------|---------|-------------|
| `CarouselView` | Horizontal carousel | Featured items, image galleries |
| `SliverAppBar` | Collapsible header | Detail pages with hero images |
| `SliverList` / `SliverGrid` | Lazy scrollable lists/grids | Large data sets in CustomScrollView |
| `Card` (M3) | Content container | Place cards, post cards |
| `ListTile` | Row items | Settings, chat lists |
| `ExpansionTile` | Collapsible sections | FAQ, itinerary details |

### Actions & Input
| Widget | Purpose | When to Use |
|--------|---------|-------------|
| `FilledButton` | High-emphasis action | Primary CTA (e.g., "Book Now") |
| `FilledButton.tonal` | Medium-emphasis action | Secondary CTA |
| `OutlinedButton` | Low-emphasis action | Cancel, back |
| `IconButton.filled` | Icon action | Like, share, bookmark |
| `FloatingActionButton.extended` | Prominent action | Create post, add trip |
| `SegmentedButton` | Toggle group | Filter by category |
| `FilterChip` / `ChoiceChip` | Selectable tags | Category filters |
| `Switch.adaptive` | Toggle setting | Cross-platform toggle |

### Feedback & Status
| Widget | Purpose | When to Use |
|--------|---------|-------------|
| `SnackBar` (M3 style) | Brief notification | Action confirmation |
| `Badge` | Count indicator | Notification count on icons |
| `CircularProgressIndicator.adaptive` | Loading | API call pending |
| `LinearProgressIndicator` | Progress | Upload/download progress |
| `Tooltip` | Hover/long-press help | Icon buttons |

## Premium UI Patterns for Kemora

### 1. Hero Image Detail Page
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(place.name),
        background: CachedNetworkImage(
          imageUrl: place.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    ),
    SliverToBoxAdapter(child: PlaceDetails(place: place)),
    SliverList(...), // Reviews, nearby places
  ],
)
```

### 2. Skeleton Loading (Shimmer)
```dart
// Always show shimmer while loading, never empty screens
if (viewModel.isLoading) {
  return Shimmer.fromColors(
    baseColor: AppColors.surfaceContainerHigh,
    highlightColor: AppColors.surfaceContainerLowest,
    child: _buildSkeletonCard(),
  );
}
```

### 3. Animated List Items
```dart
// Use flutter_animate for staggered list animations
ListView.builder(
  itemBuilder: (context, index) => PlaceCard(place: places[index])
    .animate()
    .fadeIn(delay: Duration(milliseconds: 50 * index))
    .slideX(begin: 0.1, end: 0),
)
```

### 4. Glassmorphism Effect
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: content,
    ),
  ),
)
```

### 5. Pull-to-Refresh Pattern
```dart
RefreshIndicator(
  color: AppColors.primaryContainer,
  onRefresh: () => viewModel.refreshData(),
  child: CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [...],
  ),
)
```

### 6. Empty State Pattern
```dart
// Always provide visual empty states, never blank screens
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.explore_outlined, size: 64, color: AppColors.outline),
      const SizedBox(height: 16),
      Text('No places found', style: AppTypography.titleMedium),
      const SizedBox(height: 8),
      Text('Try adjusting your filters', style: AppTypography.bodyMedium),
      const SizedBox(height: 24),
      FilledButton.tonal(
        onPressed: () => viewModel.clearFilters(),
        child: const Text('Clear Filters'),
      ),
    ],
  ),
)
```

## Responsive Design Patterns

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
```

### Responsive Layout Builder
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= Breakpoints.tablet) {
      return _buildTabletLayout();
    }
    return _buildMobileLayout();
  },
)
```

### Responsive Grid
```dart
// Use LayoutBuilder, not MediaQuery, for responsive grids
SliverGrid(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 300,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.75,
  ),
  delegate: SliverChildBuilderDelegate(...),
)
```

## Animation Best Practices

### Micro-Animations (2026)
1. **Page transitions**: Use `CustomTransitionPage` with slide + fade
2. **Button feedback**: Scale on press (0.95) with `AnimatedScale`
3. **Card hover/tap**: Subtle elevation + scale on tap
4. **List entry**: Staggered fade + slide using `flutter_animate`
5. **Tab switch**: Cross-fade between tab content
6. **Loading**: Skeleton shimmer, not spinners (for list content)

### Performance Rules for Animations
1. Only animate `opacity` and `transform` — they use the compositor layer
2. Wrap animated widgets in `RepaintBoundary` to isolate repaints
3. Use `TickerMode(enabled: false)` to pause off-screen animations
4. Prefer `TweenAnimationBuilder` for simple single-property animations
5. Use `AnimationController` + `AnimatedBuilder` for complex multi-property animations

## Accessibility Checklist
1. All interactive elements have `Semantics` labels
2. Touch targets are at least 48×48dp
3. Color contrast meets WCAG AA (4.5:1 for text)
4. Support `MediaQuery.textScaleFactor` for dynamic text sizing
5. Test with TalkBack (Android) and VoiceOver (iOS)

## Dark Mode Preparation
The app currently uses light theme only. When implementing dark mode:
1. Add `AppColors.dark*` variants or use `ColorScheme.dark()`
2. Switch via `MaterialApp(themeMode: ThemeMode.system)`
3. Use `Theme.of(context).colorScheme.xxx` in widgets (not hardcoded `AppColors.xxx`)
4. Test all screens in both modes

## Image Guidelines
1. Use `CachedNetworkImage` for all remote images
2. Always provide `placeholder` (shimmer) and `errorWidget`
3. Use `memCacheWidth` for thumbnails: `memCacheWidth: 200`
4. Hero images: full resolution, no cache limits
5. SVG assets via `flutter_svg` for icons/illustrations
6. Use `BoxFit.cover` for place images, `BoxFit.contain` for logos
