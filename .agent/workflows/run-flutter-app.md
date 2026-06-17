---
description: How to run the Flutter app on different platforms (Android emulator, Chrome, Desktop) with correct project paths and dart defines.
---

# Run Flutter App Workflow

## 1. Ensure dependencies are installed
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter pub get
```

## 2. Run on Android Emulator
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```
- API base URL automatically set to `http://10.0.2.2:5299` for Android emulator

## 3. Run on Chrome (Web)
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter run -d chrome --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```
- API base URL: `http://localhost:5299`

## 4. Run on Windows Desktop
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter run -d windows
```

## 5. Hot Restart
Press `R` (capital) in the terminal for a full hot restart, or `r` for hot reload.

## 6. Common issues
- `Gradle build failure`: Run `flutter clean` then `flutter pub get` and retry
- `No connected devices`: Start Android emulator from Android Studio or run `flutter emulators --launch <emulator_name>`
- `pub get failed`: Check internet connection and `pubspec.yaml` for typos
- `Missing localization files`: Ensure `flutter gen-l10n` runs (auto via `generate: true` in pubspec.yaml)
