---
description: How to build and verify both backend and frontend compile correctly, with correct file paths for the current project.
---

# Build & Check Workflow

## 1. Build the .NET Backend
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet build Kemora.sln
```
Expect exit code 0. If build fails due to locked `.dll/.pdb`, stop running API processes and retry.

## 2. Analyze the Flutter Frontend
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart analyze
```
Check for warnings and errors (info-level issues are acceptable).

## 3. Run .NET Unit Tests
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet test
```
All tests should pass.

## 4. Flutter Format Check (optional)
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart format --set-exit-if-changed lib/
```
Ensures code follows Dart formatting conventions.

## 5. Full Pre-commit Verification
```powershell
# Backend
cd d:\FlutterProjects\gitlove\Kemora
dotnet build Kemora.sln
dotnet test

# Frontend
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart analyze
```
All commands must succeed before committing.
