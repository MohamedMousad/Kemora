---
name: flutter-dotnet-integration
description: Patterns and conventions for integrating the Kemora Flutter app with the Kemora .NET 10 backend API, including DTO mapping, error handling, auth flow, and API client conventions.
---

# Flutter ↔ .NET Backend Integration Skill

## Architecture Overview
```
Flutter App                          .NET 10 Backend
─────────────                        ──────────────
Presentation (UI/ViewModel)
    ↓
Domain (Entities, UseCases)
    ↓
Data (DataSources, Models)    ←→    Controllers (API)
    ↓ Dio HTTP                           ↓
    API Endpoints              ←→    Services
                                         ↓
                                    Repositories
                                         ↓
                                    EF Core / SQL Server
```

## API Client Configuration

### Dio Setup (injection_container.dart)
```dart
final dio = Dio(BaseOptions(
  baseUrl: kIsWeb ? 'http://localhost:5299' : 'http://10.0.2.2:5299',
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Content-Type': 'application/json'},
));

// JWT Interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Attempt token refresh
      final refreshed = await _refreshToken(dio);
      if (refreshed) {
        return handler.resolve(await dio.fetch(error.requestOptions));
      }
    }
    handler.next(error);
  },
));
```

## Data Source Conventions

### Remote Data Source Template
```dart
abstract class IFeatureRemoteDataSource {
  Future<List<FeatureModel>> getAll();
  Future<FeatureModel> getById(String id);
  Future<FeatureModel> create(CreateFeatureRequest request);
  Future<void> delete(String id);
}

class FeatureRemoteDataSource implements IFeatureRemoteDataSource {
  final Dio _dio;
  FeatureRemoteDataSource(this._dio);

  @override
  Future<List<FeatureModel>> getAll() async {
    final response = await _dio.get('/api/features');
    return (response.data as List)
        .map((json) => FeatureModel.fromJson(json))
        .toList();
  }

  @override
  Future<FeatureModel> getById(String id) async {
    final response = await _dio.get('/api/features/$id');
    return FeatureModel.fromJson(response.data);
  }

  @override
  Future<FeatureModel> create(CreateFeatureRequest request) async {
    final response = await _dio.post('/api/features', data: request.toJson());
    return FeatureModel.fromJson(response.data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/features/$id');
  }
}
```

## DTO/Model Mapping

### Backend DTO → Flutter Model → Domain Entity
```
Backend Response JSON
    ↓ json.decode
FeatureModel.fromJson(Map<String, dynamic>)
    ↓ .toEntity()
Feature (domain entity, Equatable)
```

### Model Template
```dart
class PlaceModel {
  final int placeId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double rating;
  final String? mainImageUrl;

  PlaceModel({
    required this.placeId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.mainImageUrl,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    placeId: json['placeID'],          // Backend uses PascalCase keys
    name: json['name'],
    description: json['description'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    mainImageUrl: json['mainImageURL'],
  );

  Place toEntity() => Place(
    id: placeId.toString(),
    name: name,
    description: description ?? '',
    imageUrl: mainImageUrl ?? '',
    latitude: latitude,
    longitude: longitude,
    rating: rating,
  );
}
```

### Key Mapping Conventions
| Backend (C#) | Flutter (Dart) | Notes |
|--------------|---------------|-------|
| `PascalCase` properties | `camelCase` fields | JSON keys from .NET are camelCase (via System.Text.Json) |
| `int` IDs | `String` in entities | Convert `int.toString()` in toEntity |
| `decimal` | `double` | Use `(json['x'] as num).toDouble()` |
| `DateTime` | `DateTime` | Parse with `DateTime.parse(json['x'])` |
| `IFormFile` | `MultipartFile` (Dio) | Use `FormData` for file uploads |
| `null` vs missing | `Type?` | Always mark nullable fields |

## Backend API Endpoint Reference

### Auth (`/api/auth/`)
```
POST   /register              → { fullName, email, country, password }
POST   /login                 → { email, password } → AuthResponseDto
POST   /google-login          → { idToken } → AuthResponseDto
POST   /refresh-token         → { refreshToken } → AuthResponseDto
POST   /confirm-email         → { userId, token }
POST   /forgot-password       → { email }
POST   /reset-password        → { email, token, newPassword }
PUT    /change-password       → { currentPassword, newPassword }
PUT    /change-email          → { newEmail, password }
```

### Profile (`/api/profile/`)
```
GET    /me                    → ProfileDto
PUT    /update                → { fullName, bio, country }
POST   /upload-picture        → FormData (file) → { profilePictureUrl }
GET    /public/{userId}       → PublicProfileDto
```

### Places (`/api/places/`)
```
GET    /                      → List<PlacePublicDto> (paginated)
GET    /{id}                  → PlaceDetailPublicDto
GET    /top-rated             → List<PlacePublicDto>
GET    /by-governorate/{id}   → List<PlacePublicDto>
GET    /governorates          → List<GovernorateDto>
POST   /nearby                → { latitude, longitude, radiusKm }
POST   /trip-plan             → { placeIds } → TripPlanDto
```

### Trips (`/api/trips/`)
```
GET    /my                    → List<TripListDto>
GET    /{id}                  → TripDetailDto
POST   /                      → { name, description, startDate, endDate }
PUT    /{id}                  → { name, description, startDate, endDate }
DELETE /{id}
POST   /{id}/places           → { placeId, visitDate, notes }
PUT    /{id}/places/{placeId} → { visitDate, notes }
DELETE /{id}/places/{placeId}
POST   /save-ai-plan          → { aiItinerary }
```

### Posts & Social (`/api/posts/`, `/api/reactions/`, `/api/comments/`)
```
GET    /posts/feed             → List<PostListResponseDto> (paginated)
GET    /posts/{id}             → PostDetailResponseDto
POST   /posts                  → FormData (content, media[])
PUT    /posts/{id}             → { content }
DELETE /posts/{id}
GET    /posts/my-posts         → List<PostListResponseDto>
POST   /reactions/react-to-post    → { postId, reactionType }
POST   /reactions/react-to-comment → { commentId, reactionType }
GET    /comments/by-post/{id}  → List<CommentResponseDto>
POST   /comments               → { postId, content, parentCommentId? }
PUT    /comments/{id}          → { content }
DELETE /comments/{id}
```

### Badges (`/api/badges/`)
```
GET    /                       → List<BadgeDto>
GET    /my-badges              → List<UserBadgeDto>
GET    /leaderboard            → List<LeaderboardEntryDto>
```

### Chat (`/api/chats/`)
```
GET    /conversations          → List<ConversationDto>
GET    /messages/{conversationId} → List<MessageDto>
POST   /send                   → { receiverId, content }
POST   /mark-read/{conversationId}
```

### Favorites (`/api/favorites/`)
```
GET    /my                     → List<PlacePublicDto>
POST   /toggle                 → { placeId }
GET    /check/{placeId}        → { isFavorited: bool }
```

## Error Handling

### Backend Error Response Format
```json
{
  "message": "Validation failed",
  "errors": {
    "Email": ["Email is required", "Invalid email format"]
  }
}
```

### Flutter Error Mapping
```dart
// In repository implementation
Left(ServerFailure(message))        // 500 errors
Left(AuthFailure(message))          // 401/403 errors
Left(ValidationFailure(errors))     // 400 errors with field errors
Left(NetworkFailure('No connection')) // DioException.connectionTimeout
Left(NotFoundFailure(message))      // 404 errors
```

### Failure Class Hierarchy
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;
  ...
}
class NetworkFailure extends Failure { ... }
class NotFoundFailure extends Failure { ... }
```

## File Upload Pattern (Cloudinary via Backend)
```dart
Future<String> uploadImage(File imageFile) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      imageFile.path,
      filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ),
  });
  final response = await _dio.post('/api/images/upload', data: formData);
  return response.data['url'] as String; // Cloudinary URL
}
```

## Pagination Pattern
Backend uses offset-based pagination:
```dart
Future<List<PostModel>> getFeed({int page = 1, int pageSize = 20}) async {
  final response = await _dio.get('/api/posts/feed', queryParameters: {
    'page': page,
    'pageSize': pageSize,
  });
  return (response.data as List).map((j) => PostModel.fromJson(j)).toList();
}
```

## Testing Against the Backend

### Local Development Checklist
1. Start backend: `dotnet run` from `Kemora.Api/`
2. Verify health: `curl http://localhost:5299/health`
3. Check Swagger: `http://localhost:5299/swagger`
4. Run Flutter app with correct base URL
5. Test auth flow first (register → login → protected endpoints)

### Common Issues
| Symptom | Cause | Fix |
|---------|-------|-----|
| `SocketException` on emulator | Wrong base URL | Use `10.0.2.2:5299` for Android emulator |
| 401 on all requests | Expired/missing JWT | Check TokenStorage + interceptor |
| 500 on image upload | Cloudinary not configured | Set Cloudinary env vars in backend |
| Empty feed response | No seed data | Run backend in Development mode for seeding |
| CORS error (web) | Missing CORS policy | Backend must allow Flutter web origin |
