---
description: End-to-end checklist for setting up Google Sign-In on Android (debug and production), with correct file paths for the current project.
---

# Setup Google Sign-In (Android)

## 1. Confirm Android app identity
From app Gradle config:
- package/applicationId: `com.example.kemora`

## 2. Generate signing fingerprints
Use project Gradle signing report:
```powershell
$env:JAVA_HOME = "C:\MAD\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
cd d:\FlutterProjects\gitlove\Kemora\kemora_app\android
.\gradlew.bat signingReport
```

Collect for each signing key you use:
- SHA1
- SHA-256

## 3. Configure Google Cloud Console
In APIs & Services -> Credentials:
1. Create OAuth client: Android
2. Set package name: `com.example.kemora`
3. Add SHA-1 for debug key (and release key later)
4. Create OAuth client: Web application
5. Copy Web client ID (`*.apps.googleusercontent.com`)

In OAuth consent screen:
- Add test user accounts if app is in testing mode.

## 4. Run app with Web Client ID
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
flutter clean
flutter pub get
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

## 5. Production release setup
Before Play Store release:
- Add release keystore SHA-1 and SHA-256 in Google Cloud Android OAuth client.
- If Play App Signing is enabled, also add Play signing certificate SHA fingerprints.
- Verify OAuth consent screen publishing status and branding details.

## 6. Troubleshooting quick map
- `ApiException: 10`:
  - Wrong package name or SHA for the active signing key.
  - Wrong OAuth client type used.
  - Missing test user in consent screen.
- Works on one machine only:
  - That machine's debug keystore SHA differs; add its SHA-1.
