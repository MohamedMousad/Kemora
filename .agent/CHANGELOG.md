# Changelog

## Session: Frontend Integration Refinement
- **State Management**: Introduced `CommunityProvider`, `TripLocalProvider`, and `VoucherProvider` to simulate a fully connected backend.
- **Home Tab**: Refactored to `CustomScrollView` to support a sticky floating search bar. Integrated shared `CommunityProvider` stories.
- **Explore Tab**: Added `GovernorateDetailScreen` with categorized place rows (Museums, Cultural, etc.) and unified sticky search. Updated `GovernoratesMapScreen` layout with bottom sheet overflow.
- **Trip Planner**: Built `TripDetailScreen` to showcase an interactive day-by-day vertical roadmap. Wired "Recent Drafts" entry points.
- **Community Tab**: Rewrote `FeedScreen` to rely on `CommunityProvider`. Created `CommentBottomSheet` for inline replies. Converted `CreatePostScreen` to stateful with a mock image picker.
- **Profile Tab**: Integrated `VoucherProvider` to drive point redemption logic and connected it to `RedeemedVouchersScreen` for an end-to-end interactive mock experience.
- **Global Components**: Enhanced `FloatingNavBar` with shadow stack for blurry edges. Removed menu icon from `KemoraAppBar` on main screens. Replaced all gray placeholders with assets from `assets/images/mocked/`.
