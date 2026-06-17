# Kemora App - Architecture & UI Structure

## Core Design Philosophy
- **Desert Editorial**: Kemora follows a high-end editorial visual style.
- **Tokens**: Centralized under `core/theme/` (`AppColors`, `AppTypography`, `AppShadows`). Do not use ad-hoc colors or padding; use these tokens.
- **Assets**: All mockup images are stored in `assets/images/mocked/`. No generic gray boxes; always supply fallback icons only if assets fail to load.

## State Management (Frontend-Only Mode)
The app is currently configured to function in a standalone "frontend-only" mode using `Provider` for cross-tab state sharing.
- **`CommunityProvider`**: Shared data for stories, posts, likes, and comments across the Home and Community tabs.
- **`TripLocalProvider`**: Drafts and saved trips, shared between Explore and Trip Planner.
- **`VoucherProvider`**: Simulates point spending, rewards catalog, and voucher redemption across Profile screens.

## Navigation Structure
- **Global**: `MainNavigator` acts as the root orchestrator.
- **Top Bar**: `KemoraAppBar` manages contextual UI. The menu icon is hidden on primary tabs.
- **Bottom Bar**: `FloatingNavBar` provides global navigation with a radial blurry glow effect for depth.

## Key Screens
1. **Home**: `CustomScrollView` with sticky search island via `SliverPersistentHeader`, using shared `CommunityProvider` for stories.
2. **Explore**: Contains `GovernorateDetailScreen` with sticky search and categorized dynamic places. `GovernoratesMapScreen` uses a bottom sheet to show overflow activities.
3. **Trip Planner**: Flow from `TripPlannerEntryScreen` -> AI generation -> `TripDetailScreen` vertical roadmap with timeline dots.
4. **Community**: `FeedScreen` with interactive `FeedPostCard`s, `StoryViewerScreen`, and a fully functional `CreatePostScreen` with mock image picking.
5. **Profile**: `PublicProfileScreen` showing `VoucherProvider` driven point system, bento box achievements, and a `RedeemedVouchersScreen` for visualizing saved codes.
