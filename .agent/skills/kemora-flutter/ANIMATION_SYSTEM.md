---
name: kemora-animation-system
description: Kemora's animation system — curves, durations, reusable widgets, and conventions for all motion design across the app.
---

# Kemora Animation System

## Design Principles
1. **Every transition is intentional** — no instant swaps, no jarring jumps
2. **Bezier curves everywhere** — `easeInOutCubic` for navigation, `easeOutCubic` for content appearing
3. **Staggered reveals** — content fades in sequentially, top-to-bottom, 80–100ms apart
4. **Tactile feedback** — buttons scale down on press to confirm interaction
5. **Zero new packages** — all built with Flutter core animation APIs (Impeller-optimized)

---

## Standard Curves & Durations

| Animation Type | Curve | Duration | Notes |
|----------------|-------|----------|-------|
| Tab swipe (PageView) | `Curves.easeInOutCubic` | 400ms | Main tab transitions |
| Tab tap (animateToPage) | `Curves.easeInOutCubic` | 400ms | Matches swipe feel |
| Content fade-in | `Curves.easeOutCubic` | 500ms | Elements appearing |
| Content slide-up | `Curves.easeOutCubic` | 600ms | Slightly longer than fade |
| Push screen (detail) | `Curves.easeInOutCubic` | 350ms | Slide from right |
| Pop screen (back) | `Curves.easeInOutCubic` | 300ms | Slightly faster exit |
| Button scale down | `Curves.easeOutCubic` | 120ms | Snappy response |
| Button scale up | `Curves.easeOutCubic` | 200ms | Gentle release |
| NavBar entrance | `Curves.easeOutCubic` | 500ms | Slide up from bottom |
| NavBar icon active | `Curves.easeOut` | 300ms | Circle background |
| Splash sequence | `Curves.easeOutCubic` | 400ms each | Staggered cascade |

---

## Reusable Animation Widgets

### `FadeSlideIn` — Staggered Fade + Slide
**File**: `presentation/widgets/fade_slide_in.dart`

```dart
FadeSlideIn(
  delayMs: 200,           // stagger delay before animation starts
  durationMs: 500,        // animation duration
  beginOffset: Offset(0, 0.05),  // slight upward slide
  curve: Curves.easeOutCubic,
  child: MyWidget(),
)
```

**Usage**: Wrap any widget that should fade-in when the screen loads. Use incrementing `delayMs` values (0, 80, 160, 240...) for staggered reveals.

### `TapScale` — Press Feedback
**File**: `presentation/widgets/tap_scale.dart`

```dart
TapScale(
  onTap: () => navigate(),
  child: CardWidget(),
)
```

Scales to 0.96 on press, back to 1.0 on release. Applied to all interactive cards and list items.

### `SlidePageRoute` — Push/Pop Transition
**File**: `core/router/page_transitions.dart`

```dart
Navigator.push(context, SlidePageRoute(child: DetailScreen()));
```

Slides new screen in from the right with a slight fade. Pop reverses the animation.

### `FadePageRoute` — Modal/Search Transition
**File**: `core/router/page_transitions.dart`

```dart
Navigator.push(context, FadePageRoute(child: SearchScreen()));
```

Pure crossfade for overlay-style screens (search, create post).

---

## Main Tab Navigation (PageView)

### Architecture
```
HomeScreen (StatefulWidget)
├── PageController (_pageController)
├── PageView
│   ├── page 0: HomeContentScreen
│   ├── page 1: GovernoratesMapScreen
│   ├── page 2: TripPlannerEntryScreen
│   ├── page 3: FeedScreen
│   └── page 4: PublicProfileScreen
└── FloatingNavBar
    ├── onTap → _pageController.animateToPage(...)
    └── currentIndex ← PageView.onPageChanged
```

### Swipe Behavior
- `PageView` with default `PageScrollPhysics()` (snap to pages)
- Requires deliberate full-width horizontal swipe — avoids conflict with inner horizontal lists
- `onPageChanged` updates `_currentIndex` → FloatingNavBar re-renders

### NavBar Tap Behavior
- `animateToPage(index, duration: 400ms, curve: Curves.easeInOutCubic)`
- Creates smooth left↔right animated slide

---

## Per-Screen Fade-In Stagger Map

### HomeContentScreen (8 elements)
```
  0ms  → Greeting label ("WELCOME BACK")
 80ms  → Greeting name ("Good morning, Zaki")
160ms  → Search bar
240ms  → Filter chips
320ms  → "The Modern Archivist" header
400ms  → Place cards carousel
500ms  → "Community Stories" section
600ms  → "Explore by Region" card
```

### GovernoratesMapScreen (4 elements)
```
  0ms  → Background map
100ms  → Header text
200ms  → Map dots
350ms  → Bottom sheet card
```

### TripPlannerEntryScreen (5 elements)
```
  0ms  → Header text
100ms  → Subtext
200ms  → AI Planner card
350ms  → Custom Builder card
500ms  → Recent Inspiration
```

### FeedScreen (4+ elements)
```
  0ms  → Stories row
100ms  → Filter chips
200ms  → First post card
300ms+ → Subsequent posts (+100ms each)
```

### PublicProfileScreen (5 elements)
```
  0ms  → Avatar/header area
100ms  → Name + badge
200ms  → Achievements header
350ms  → Achievement bento cards
500ms  → Nav rows + buttons
```

---

## Splash Screen Animation Sequence

```
   0ms  → Logo icon fades in
 200ms  → "KIMORA" text fades in
 400ms  → "THE EGYPTIAN ODYSSEY" subtitle
 600ms  → Divider line animates width (0 → 40px)
 800ms  → "CURATING DISCOVERY" fades in
1000ms  → Bottom footer fades in
2500ms  → Transition to Onboarding (FadePageRoute)
```

---

## Conventions & Rules

### DO
- Use `FadeSlideIn` for all content that appears on screen load
- Use `TapScale` for all tappable cards and list items
- Use `SlidePageRoute` for navigating to detail/sub screens
- Use `FadePageRoute` for modal-like screens (search, create)
- Use `const` constructors in animation widgets
- Use `RepaintBoundary` around complex animated widgets
- Dispose `AnimationController` and `PageController` in `dispose()`

### DON'T
- Don't use `MaterialPageRoute` for new navigation (use custom transitions)
- Don't hardcode animation durations — use the standard values above
- Don't animate layout properties (width, height) — only `opacity` and `transform`
- Don't forget `TickerProviderStateMixin` when using `AnimationController`
- Don't use `withOpacity()` — use `withValues(alpha: x)` instead

### Performance
- `FadeSlideIn` widgets use `SlideTransition` + `FadeTransition` (compositor-layer only)
- `TapScale` uses `Transform.scale` (compositor-layer only)
- Both avoid triggering layout/paint passes — smooth 60fps on Impeller
