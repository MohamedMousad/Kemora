---
description: Diagnose Flutter emulator connectivity and auth registration failures, with correct file paths for the current project.
---

# Troubleshoot Auth + Emulator Workflow

## 1. Verify backend is running
```powershell
cd d:\FlutterProjects\gitlove\Kemora\Kemora.Api
dotnet run
```
Expected: app starts, seed logs complete, no fatal exception.

## 2. Verify backend is reachable
```powershell
curl.exe -s -o NUL -w "HTTP=%{http_code}" http://localhost:5299/health
```
Expected: `HTTP=200`

## 3. If emulator cannot connect
Check Flutter API base URL mapping in `kemora_app/lib/core/di/injection_container.dart`:
- Web: `http://localhost:5299`
- Android emulator: `http://10.0.2.2:5299`

Also ensure backend binds HTTP in development (launch profile):
- `http://0.0.0.0:5299`

## 4. If registration fails with DNS/network-like message
Check `Kemora.Api/appsettings.Development.json`:
- `TokenKey` must be sufficiently long for HS512.
- `EmailSettings` keys should be `FromEmail` and `FromName`.

## 5. If registration still fails
Call API directly to isolate frontend from backend:
```powershell
$email = "qa" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + "@example.com"
$body = @{ fullName='QA User'; email=$email; country='Egypt'; password='Qwerty@123' } | ConvertTo-Json
Invoke-WebRequest "http://localhost:5299/api/v1/auth/register" -Method POST -ContentType "application/json" -Body $body
```

## 6. If "address already in use" appears
Stop process on port 5299 and rerun:
```powershell
$portPid = (netstat -ano | Select-String ":5299" | ForEach-Object { ($_ -split "\s+")[-1] } | Where-Object { $_ -match "^\d+$" } | Select-Object -First 1)
if ($portPid) { Stop-Process -Id ([int]$portPid) -Force -ErrorAction SilentlyContinue }
cd d:\FlutterProjects\gitlove\Kemora\Kemora.Api
dotnet run
```

## 7. If Social tab shows "An internal server error occurred"
Check backend logs for Cloudinary configuration errors.

If you see:
`Cloudinary:CloudName is missing from configuration`

Then ensure image service does not throw during DI construction when Cloudinary config is absent in development. The feed endpoint should still work even if image upload is unavailable.

## 8. If Google Sign-In fails with `ApiException: 10`
Validate OAuth config in Google Cloud Console:
- Android OAuth client package name: `com.example.kemora`
- Add SHA-1 for the signing key used to run the app.
- Use a Web OAuth client ID in run command:
	- `flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com`
- Add the testing Google account in OAuth consent screen test users.

Command to extract SHA fingerprints using project Gradle:
```powershell
$env:JAVA_HOME = "C:\MAD\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
cd d:\FlutterProjects\gitlove\Kemora\kemora_app\android
.\gradlew.bat signingReport
```
