---
description: How to add a new Flutter feature end-to-end (entity → screen), with correct file paths for the current project.
---

# Add Flutter Feature Workflow

## Prerequisites
- Read `Kemora/.agent/skills/kemora-flutter/SKILL.md` for architecture context
- Read `Kemora/.agent/skills/kemora-flutter/BACKEND_INTEGRATION.md` for API patterns
- Ensure the .NET backend has the corresponding endpoints ready

## 1. Create the Domain Entity
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\domain\entities\<feature>.dart`
- Extend `Equatable`, use `const` constructor
- Define all fields as `final`
- Override `props` getter for equality

## 2. Create the Repository Interface
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\domain\repositories\i_<feature>_repository.dart`
- Return `Future<Either<Failure, T>>` using dartz
- Import from `package:dartz/dartz.dart`
- One method per business action

## 3. Create Use Cases
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\domain\usecases\<feature>_usecases.dart`
- One class per use case with a single `call()` method
- Inject repository via constructor
- Return `Future<Either<Failure, T>>`

## 4. Create the Data Model (DTO)
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\data\models\<feature>_model.dart`
- Add `fromJson(Map<String, dynamic>)` factory constructor
- Add `toJson()` method for request DTOs
- Add `toEntity()` method mapping to domain entity
- Handle nullable fields and type conversions (num → double, int → String)

## 5. Create the Remote Data Source
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\data\datasources\<feature>_remote_data_source.dart`
- Create abstract class and implementation
- Inject `Dio` via constructor
- Make HTTP calls to the .NET backend API endpoints
- Return model objects (not entities)

## 6. Create the Repository Implementation
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\data\repositories\<feature>_repository_impl.dart`
- Implements the domain repository interface
- Inject data source, call it, catch DioExceptions → Left(Failure)
- Map Model → Entity using `toEntity()`

## 7. Create the ViewModel
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\presentation\viewmodels\<feature>_view_model.dart`
- Extends `ChangeNotifier`
- Inject use cases via constructor
- Manage state (loading, data, error) with `notifyListeners()`
- Use `fold()` pattern on Either results

## 8. Register Everything in DI
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\core\di\injection_container.dart`
- Register in order: ViewModel (Factory) → UseCases (LazySingleton) → Repository (LazySingleton) → DataSource (LazySingleton)

## 9. Add Provider to main.dart
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\main.dart`
- Add `ChangeNotifierProvider(create: (_) => di.sl<FeatureViewModel>())`

## 10. Create the Screen
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\presentation\screens\<feature>\<feature>_screen.dart`
- Use `context.watch<VM>()` for reactive UI, `context.read<VM>()` for actions
- Follow Desert Editorial theme (AppColors, AppTypography)
- Use `const` constructors, avoid deep nesting
- Implement loading (shimmer), error, and empty states
- Use `withValues()` instead of `withOpacity()` for colors

## 11. Add Route
- File: `d:\FlutterProjects\gitlove\Kemora\kemora_app\lib\core\router\app_router.dart`
- Add GoRoute, pass data via `state.extra`

## 12. Verify
```powershell
cd d:\FlutterProjects\gitlove\Kemora\kemora_app
dart analyze
```
No warnings or errors expected. Info-level issues are acceptable.
