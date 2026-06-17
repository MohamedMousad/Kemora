---
description: Step-by-step workflow for implementing the Kemora animation system — swipe navigation, fade-ins, transitions, and micro-animations.
---

# Implement Animation Plan Workflow

## Prerequisites
- Read `Kemora/.agent/skills/kemora-flutter/ANIMATION_SYSTEM.md` for curves, durations, and conventions
- Read `Kemora/.agent/skills/kemora-flutter/SKILL.md` for project structure
- All changes are in `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\`

## Step 1: Create Reusable Animation Widgets (3 new files)

### 1a. FadeSlideIn widget
- File: `presentation/widgets/fade_slide_in.dart`
- StatefulWidget with `SingleTickerProviderStateMixin`
- Parameters: `delayMs`, `durationMs` (default 500), `beginOffset` (default 0,0.05), `curve` (default easeOutCubic), `child`
- Uses `AnimationController` → `CurvedAnimation` → `FadeTransition` + `SlideTransition`
- Starts after `delayMs` using `Future.delayed`

### 1b. TapScale widget
- File: `presentation/widgets/tap_scale.dart`
- StatefulWidget — scales to 0.96 on `GestureDetector.onTapDown`, back to 1.0 on `onTapUp`/`onTapCancel`
- Uses `AnimatedScale` with duration 120ms (down) / 200ms (up)
- Wraps child in `GestureDetector` → `AnimatedScale`

### 1c. Page transition routes
- File: `core/router/page_transitions.dart`
- `SlidePageRoute<T>` — extends `PageRouteBuilder`, slide from right with fade
- `FadePageRoute<T>` — extends `PageRouteBuilder`, pure crossfade
- Both use `Curves.easeInOutCubic`, durations per ANIMATION_SYSTEM.md

## Step 2: Replace IndexedStack with PageView

- File: `presentation/screens/home/home_screen.dart`
- Add `PageController _pageController`
- Replace `IndexedStack` with `PageView(controller: _pageController, onPageChanged: ..., children: screens)`
- On FloatingNavBar tap: `_pageController.animateToPage(index, duration: 400ms, curve: Curves.easeInOutCubic)`
- On PageView `onPageChanged`: `setState(() => _currentIndex = index)`
- Dispose `_pageController` in `dispose()`

## Step 3: Polish FloatingNavBar

- File: `presentation/widgets/floating_nav_bar.dart`
- Convert to StatefulWidget (or keep StatelessWidget if using TweenAnimationBuilder)
- Add icon scale animation: active icon scales to 1.15 via `TweenAnimationBuilder<double>`
- Add slide-up entrance: wrap entire widget in `FadeSlideIn(delayMs: 300)`
- Fix `withOpacity()` → `withValues(alpha: x)`

## Step 4: Add FadeSlideIn to All 5 Main Screens

For each screen, wrap sections in `FadeSlideIn` with staggered delays.
See `ANIMATION_SYSTEM.md` → "Per-Screen Fade-In Stagger Map" for exact delays.

### Files to modify:
1. `presentation/screens/home/home_content_screen.dart` — 8 elements
2. `presentation/screens/explore/governorates_map_screen.dart` — 4 elements
3. `presentation/screens/trip/trip_planner_entry_screen.dart` — 5 elements
4. `presentation/screens/social/feed_screen.dart` — 4+ elements
5. `presentation/screens/profile/public_profile_screen.dart` — 5 elements

## Step 5: Replace MaterialPageRoute with Custom Transitions

Replace all `Navigator.push(context, MaterialPageRoute(...))` calls with:
- `SlidePageRoute(child: ...)` for detail screens
- `FadePageRoute(child: ...)` for search/create screens

### Files to modify:
1. `home_content_screen.dart` — 3 push calls → SlidePageRoute (detail), FadePageRoute (search)
2. `governorates_map_screen.dart` — 1 push → SlidePageRoute
3. `trip_planner_entry_screen.dart` — 2 push → SlidePageRoute
4. `feed_screen.dart` — 1 push → FadePageRoute (create post)
5. `public_profile_screen.dart` — 2 push → SlidePageRoute
6. `splash_screen.dart` — 1 pushReplacement → FadePageRoute

## Step 6: Enhance Splash Screen

- File: `presentation/screens/splash/splash_screen.dart`
- Replace static layout with staggered `FadeSlideIn` wrappers
- 6 elements with delays: 0, 200, 400, 600, 800, 1000ms
- Fix `withOpacity()` calls

## Step 7: Fix All withOpacity() Deprecations

Replace `.withOpacity(x)` → `.withValues(alpha: x)` in:
- `floating_nav_bar.dart`
- `kimora_app_bar.dart`
- `home_content_screen.dart`
- `feed_screen.dart`
- `public_profile_screen.dart`
- `splash_screen.dart`
- `trip_planner_entry_screen.dart`
- `app_shadows.dart`

## Step 8: Verify

```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart analyze
```
No errors expected. Run on emulator to visually verify all animations.

## Checklist
- [ ] `fade_slide_in.dart` created
- [ ] `tap_scale.dart` created
- [ ] `page_transitions.dart` created
- [ ] HomeScreen uses PageView
- [ ] FloatingNavBar polished
- [ ] HomeContentScreen fade-ins
- [ ] GovernoratesMapScreen fade-ins
- [ ] TripPlannerEntryScreen fade-ins
- [ ] FeedScreen fade-ins
- [ ] PublicProfileScreen fade-ins
- [ ] All MaterialPageRoute replaced
- [ ] Splash screen animated
- [ ] All withOpacity() fixed
- [ ] `dart analyze` clean
