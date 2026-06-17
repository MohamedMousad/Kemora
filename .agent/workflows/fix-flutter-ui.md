---
description: Workflow for fixing and improving Flutter UI screens, following the Desert Editorial design system and 2026 best practices.
---

# Fix & Improve Flutter UI Workflow

## Prerequisites
- Read `Kemora/.agent/skills/kemora-flutter/UI_PATTERNS.md` for widget patterns
- Read `Kemora/.agent/skills/kemora-flutter/SKILL.md` for design system tokens

## 1. Identify the screen to fix
- Check `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\presentation\screens\<feature>\`
- Or legacy `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\screens\<feature>\`

## 2. Run analyzer to find code issues
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart analyze
```

## 3. Common UI fixes checklist

### Colors
- [ ] Replace all `withOpacity()` calls with `withValues(alpha: x)`
- [ ] Replace hardcoded colors with `AppColors.xxx` tokens
- [ ] Use `Theme.of(context).colorScheme.xxx` for Material 3 compliance
- [ ] Check contrast ratios (4.5:1 minimum for text)

### Typography
- [ ] Replace hardcoded `TextStyle` with `AppTypography.xxx`
- [ ] Use `Theme.of(context).textTheme.xxx` for Material 3
- [ ] Ensure headline text uses Plus Jakarta Sans
- [ ] Ensure body/label text uses Manrope

### Layout
- [ ] Replace `Container` with `SizedBox` where only size is needed
- [ ] Fix overflow issues with `Expanded`/`Flexible`
- [ ] Add `const` constructors wherever possible
- [ ] Extract deep widget trees (4+ levels) into separate widgets
- [ ] Use `LayoutBuilder` for responsive layouts

### Loading & Error States
- [ ] Add shimmer skeleton loading (not just CircularProgressIndicator)
- [ ] Add meaningful error states with retry buttons
- [ ] Add empty state illustrations/messages
- [ ] Use `RefreshIndicator` for pull-to-refresh on lists

### Animations
- [ ] Add page transition animations via GoRouter
- [ ] Add staggered list item animations
- [ ] Add button press feedback (scale/opacity)
- [ ] Use `Hero` widget for shared element transitions

### Performance
- [ ] Wrap animated/complex widgets in `RepaintBoundary`
- [ ] Use `IndexedStack` for tab content preservation
- [ ] Minimize widget rebuilds (Selector, Consumer)
- [ ] Lazy-load images with `CachedNetworkImage`

## 4. Desert Editorial Design Tokens Quick Reference
```dart
// Primary Colors
AppColors.primary           // 0xFF9b4500 — Burnt Desert Orange
AppColors.primaryContainer  // 0xFFf17720 — Bright Orange (CTAs, highlights)
AppColors.secondary         // 0xFF885200 — Amber Gold
AppColors.tertiary          // 0xFF00658a — Nile Blue

// Surfaces
AppColors.surface           // 0xFFf9f9f9 — Off-white
AppColors.surfaceContainerLowest // 0xFFffffff — Pure white (cards)

// Text
AppColors.onSurface         // 0xFF1a1c1c — Primary text
AppColors.onSurfaceVariant  // 0xFF574237 — Secondary text
AppColors.outline           // 0xFF8b7265 — Hint/border text

// Shapes
Card radius: 20dp
Button radius: 9999dp (pill)
Input radius: 12dp
```

## 5. Verify after changes
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart analyze
```
Run on device/emulator to visually verify the changes.
