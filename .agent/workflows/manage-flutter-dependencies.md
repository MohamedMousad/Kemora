---
description: How to update, add, and manage Flutter packages in the Kemora app.
---

# Manage Flutter Dependencies Workflow

## 1. Check for outdated packages
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter pub outdated
```

## 2. Upgrade to latest compatible versions
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter pub upgrade
```

## 3. Upgrade to latest major versions (breaking changes possible)
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter pub upgrade --major-versions
```
⚠️ Always review changelogs before major upgrades.

## 4. Add a new package
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter pub add <package_name>
```

## 5. Add a dev dependency
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter pub add --dev <package_name>
```

## 6. Run build_runner (for code generation)
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart run build_runner build --delete-conflicting-outputs
```
Use after modifying `json_serializable` annotated models or `freezed` classes.

## 7. Generate localization files
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter gen-l10n
```
This is auto-triggered by `generate: true` in pubspec.yaml, but can be run manually.

## 8. Current recommended packages (2026)
| Category | Package | Version |
|----------|---------|---------|
| State | `provider` | ^6.1.1 |
| DI | `get_it` | ^7.6.4 |
| HTTP | `dio` | ^5.4.0 |
| Routing | `go_router` | ^13.2.0 |
| Error | `dartz` | ^0.10.1 |
| Fonts | `google_fonts` | ^6.1.0 |
| Images | `cached_network_image` | ^3.3.0 |
| Maps | `google_maps_flutter` | ^2.5.3 |
| Auth | `google_sign_in` | ^6.2.1 |
| JSON | `json_annotation` | ^4.8.1 |
| Equality | `equatable` | ^2.0.5 |
| SVG | `flutter_svg` | ^2.0.9 |
| Time | `timeago` | ^3.7.1 |
| Storage | `shared_preferences` | ^2.3.2 |

### Recommended additions for premium UI:
| Category | Package | Purpose |
|----------|---------|---------|
| Animations | `flutter_animate` | Declarative animation chains |
| Loading | `shimmer` | Skeleton loading effects |
| Theming | `flex_color_scheme` | Simplified M3 theming |
| Notifications | `elegant_notification` | Premium toast notifications |
