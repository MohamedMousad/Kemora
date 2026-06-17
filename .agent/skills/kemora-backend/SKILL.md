---
name: kemora-backend
description: Comprehensive guide for working on the Kemora .NET backend — architecture, patterns, entities, services, and conventions.
---

# Kemora Backend Skill

## Overview
Kemora is an Egyptian tourism platform. The backend is a **.NET 10** Web API following **Clean Architecture** with 4 layers.

## Solution Structure

```
Kemora.sln
├── Kemora.Api/            # ASP.NET Web API (Controllers, Middlewares, Hubs, Program.cs)
├── Kemora.Application/    # Business logic (Services, DTOs, Interfaces, Mapping)
├── Kemora.Domain/         # Core entities, enums, repository interfaces
├── Kemora.Infrastructure/ # EF Core DbContext, Repositories, External Services
└── Kemora.Tests/          # Unit tests (xUnit + Moq)
```

## Dependency Flow (STRICT — never violate)
```
Domain ← Application ← Infrastructure ← Api
```
- **Domain** has ZERO project references (only Microsoft.AspNetCore.Identity.EntityFrameworkCore)
- **Application** references Domain
- **Infrastructure** references Domain + Application
- **Api** references all three

## Technology Stack
| Concern | Technology |
|---------|-----------|
| Framework | .NET 10, ASP.NET Core |
| ORM | Entity Framework Core 10 |
| Auth | ASP.NET Identity + JWT Bearer |
| Mapping | AutoMapper |
| Logging | Serilog (Console + Rolling File) |
| Email | MailKit/MimeKit via Brevo SMTP |
| Image Upload | Cloudinary |
| AI | Google Gemini API (gemini-3-flash-preview) |
| Places Data | OpenStreetMap Overpass API |
| Enrichment | Wikipedia API |
| Real-time | SignalR (Notifications Hub) |
| Caching | IMemoryCache |
| API Versioning | Asp.Versioning.Mvc |
| Rate Limiting | Built-in .NET rate limiter (fixed window) |
| Health Checks | AspNetCore.HealthChecks.SqlServer |
| API Docs | Swagger/Swashbuckle |
| Env Vars | dotenv.net (.env file) |

## Database: SQL Server (SQLEXPRESS in local dev)
Connection (dev): `Server=.\\SQLEXPRESS;Database=KemoraDb;Trusted_Connection=True;TrustServerCertificate=True;Encrypt=False;MultipleActiveResultSets=True`

Notes:
- LocalDB is not required for this repo's current local setup.
- `TokenKey` must be long enough for HS512 signing.
- If SMTP is not configured, registration should still continue in development.

## Domain Entities

### Core Entities (in `Kemora.Domain/Entities/`)

#### ApplicationUser (extends IdentityUser)
- FullName, ProfilePictureUrl?, Bio?, Country, TotalPoints
- RefreshToken?, RefreshTokenExpiryTime
- UserPreferencesJSON? (stores Budget, Vibe, Pace as JSON)
- Nav: UserBadges, PointHistory, Trips, Favorites, Posts, Comments

#### Place Entities (`PlaceEntities.cs`)
- **Governorate**: GovernorateID, Name, Region, ImageURL? → Places
- **Category**: CategoryID, Name → PlaceTypes
- **PlaceType**: TypeID, GoogleType, DisplayName, CategoryID → Places
- **Place**: PlaceID, GooglePlaceID?, Name, Description?, Address?, Lat/Lng (decimal), Phone?, Website?, Rating (decimal 3,2), PriceLevel (0-4), OpeningHoursJSON?, MainImageURL?, GovernorateID?, PlaceTypeID?, LastEnrichedAt?, Source? → Photos, Reviews, Events
- **Photo**: PhotoID, ImageURL, IsMain, PlaceID
- **Review**: ReviewID, AuthorName, Rating (int), Text, PlaceID
- **Event**: EventID, Name, StartDate, EndDate, PlaceID

#### Social Entities (`SocialEntities.cs`)
- **Post**: PostID, Content, CreatedAt, UserID, LinkedTripId? → Media, Reactions, Comments
- **PostMedia**: MediaID, MediaURL, MediaType ("Image"/"Video"), PostID
- **PostReaction**: Composite key (PostID, UserID), ReactionType, ReactedAt
- **Comment**: CommentID, Content, CreatedAt, PostID, UserID, ParentCommentId? → Replies, Media, Reactions
- **CommentMedia**: MediaID, MediaURL, MediaType, CommentID
- **CommentReaction**: Composite key (CommentID, UserID), ReactionType, ReactedAt
- **Message**: MessageID, Content, SentAt, IsRead, SenderID, ReceiverID

#### Planning Entities (`PlanningEntities.cs`)
- **Trip**: TripID, Name, Description, StartDate, EndDate, UserID → TripPlaces
- **TripPlace**: TripPlaceID, TripID, PlaceID, VisitDate, Notes?

#### Gamification Entities (`GamificationEntities.cs`)
- **Badge**: BadgeID, Name, Description, IconUrl, Criteria, PointsReward
- **UserBadge**: Composite key (UserID, BadgeID), EarnedAt
- **UserPoint**: UserPointID, PointsGained, GainedAt, UserID, SourcePlaceID?
- **UserFavorite**: Composite key (UserID, PlaceID)

#### Notification
- NotificationID, UserID, Title, Message, IsRead, CreatedAt

### Enums
- **TourismType**: Leisure, CulturalHeritage, Adventure, EcoTourism, Business, MedicalWellness, ReligiousPilgrimage, Sports, Culinary

## EF Core Configuration (ApplicationDbContext)
- Inherits: `IdentityDbContext<ApplicationUser>`
- Composite keys: UserBadge, UserFavorite, PostReaction, CommentReaction
- Decimal precision: Place Lat(10,8), Lng(11,8), Rating(3,2)
- Cascade delete prevention: Comment→User, PostReaction→User, CommentReaction→User, TripPlace→Place (all Restrict)
- Cascade allowed: Post→Media

## Repository Pattern
- **IRepository<T>**: Generic CRUD (in Domain/Interfaces/)
- **Repository<T>**: Generic implementation (in Infrastructure/Repositories/)
- Specialized repos: IPostRepository, ICommentRepository, IPlaceRepository, ITripRepository, etc.
- **IUnitOfWork / UnitOfWork**: Transaction management

## Service Pattern
Services are split between Application (business logic) and Infrastructure (external integrations):

### Application Services (Kemora.Application/Services/)
| Service | Purpose |
|---------|---------|
| BadgeService | Badge CRUD, user badge assignment, leaderboard |
| ChatService | Message sending, conversation listing |
| CommentService | CRUD comments with media, nested replies |
| EventService | CRUD events for places |
| FavoriteService | Toggle favorites, list user favorites |
| NotificationService | Create/list/mark-read notifications |
| PhotoService | Place photo management |
| PlaceManagementService | Admin CRUD for governorates, categories, place types, places |
| PlacePublicService | Public place listing, detail, search |
| PostService | CRUD posts with media, feed with pagination |
| ReactionService | Toggle reactions on posts and comments |
| ReviewService | CRUD reviews for places |
| TripPlannerService | AI-powered trip planning via Gemini |
| TripService | CRUD trips, add/remove places, save AI plans |

### Infrastructure Services (Kemora.Infrastructure/Services/)
| Service | Purpose |
|---------|---------|
| AuthService | Register, login, Google OAuth, refresh tokens, email confirm, password reset/change |
| CloudinaryImageService | Image upload to Cloudinary |
| MemoryCacheService | In-memory caching wrapper |
| OverpassPlacesService | Fetch places from OpenStreetMap Overpass API |
| ProfileService | Get/update profile, upload profile picture |
| SmtpEmailService | Send emails via Brevo SMTP |
| TokenService | JWT token generation |
| UserManagementService | Admin user listing/deletion |
| WikipediaService | Fetch place descriptions from Wikipedia |

## API Controllers (17 total, all in Kemora.Api/Controllers/)

| Controller | Route Prefix | Auth Required | Key Endpoints |
|-----------|-------------|---------------|---------------|
| AuthController | /api/auth | Mixed | register, login, google-login, refresh-token, confirm-email, forgot-password, reset-password, change-password, change-email |
| BadgesController | /api/badges | Yes | GET all, GET my-badges, GET leaderboard, POST (Admin), POST award |
| ChatsController | /api/chats | Yes | GET conversations, GET messages, POST send |
| CommentsController | /api/comments | Yes | GET by post, POST create, PUT update, DELETE |
| EventsController | /api/events | Yes | GET by place, POST create (Admin), PUT, DELETE |
| FavoritesController | /api/favorites | Yes | GET my, POST toggle, GET check |
| ImagesController | /api/images | Yes | POST upload |
| NotificationsController | /api/notifications | Yes | GET all, POST mark-read, POST mark-all-read |
| PhotosController | /api/photos | Yes | GET by place, POST add (Admin), DELETE |
| PlacesController | /api/places | Mixed | GET list, GET detail, GET top-rated, GET by-governorate, GET governorates, POST nearby, POST trip-plan |
| PlacesManagementController | /api/admin/places | Admin | Full CRUD for governorates, categories, place-types, places |
| PostsController | /api/posts | Yes | GET feed, GET detail, POST create, PUT update, DELETE, GET my-posts |
| ProfileController | /api/profile | Yes | GET me, PUT update, POST upload-picture, GET public/{userId} |
| ReactionsController | /api/reactions | Yes | POST react-to-post, POST react-to-comment |
| ReviewsController | /api/reviews | Yes | GET by place, POST create, DELETE |
| TripsController | /api/trips | Yes | GET my, GET detail, POST create, PUT update, DELETE, POST add-place, PUT update-place, DELETE remove-place, POST save-ai-plan |
| UserManagementController | /api/admin/users | Admin | GET all, DELETE user |

## Authentication & Authorization
- JWT Bearer tokens (HS512, configurable via `TokenKey`)
- Roles: "User" (default), "Admin"
- Admin endpoints use `[Authorize(Roles = "Admin")]`
- Rate limiting: "auth" policy (10/min), "fixed" policy (60/min)

## Configuration (appsettings.json + .env)
```
ConnectionStrings:DefaultConnection  → SQL Server
TokenKey                             → JWT signing key
Gemini:ApiKey                        → Google Gemini API key
Gemini:Model                         → gemini-3-flash-preview
Cloudinary:CloudName/ApiKey/ApiSecret → Image hosting
EmailSettings:Host/Port/Username/Password/FromEmail/FromName → SMTP
```

## AutoMapper Profile (Kemora.Application/Mapping/MappingProfile.cs)
Maps all entities to their response DTOs. Key mappings:
- ApplicationUser → AuthResponseDto, ProfileDto, PublicProfileDto, LeaderboardEntryDto
- Post → PostListResponseDto, PostDetailResponseDto (with author info, counts)
- Comment → CommentResponseDto (with nested replies)
- Place → PlaceAdminDto, PlacePublicDto, PlaceDetailPublicDto
- Trip → TripListDto, TripDetailDto
- All gamification/social entities mapped

## Middleware
- **ExceptionHandlingMiddleware**: Global catch-all, returns 500 with generic message, logs via Serilog

## Real-time
- **SignalR NotificationHub**: `/hubs/notifications`
- **INotificationPusher → SignalRNotificationPusher**

## Data Seeding
- **RoleSeeder**: Creates "User" and "Admin" roles on startup
- **DataSeeder**: Seeds sample data in Development environment

## Conventions & Rules (from PROJECT_CONSTITUTION.md)
1. PascalCase for classes/methods, camelCase for local variables
2. XML comments for complex business logic
3. Never commit code that breaks the build
4. Use FluentValidation for data integrity
5. Global exception handling middleware for consistent error responses
6. JWT + role-based auth (User/Admin)
7. Always run `dotnet build` to verify changes compile

## Common Patterns When Adding a New Feature

### Adding a new entity:
1. Create entity class in `Kemora.Domain/Entities/`
2. Add `DbSet<Entity>` to `ApplicationDbContext`
3. Configure relationships/keys in `OnModelCreating` if needed
4. Create and run EF migration: `dotnet ef migrations add <Name> --project Kemora.Infrastructure --startup-project Kemora.Api`

### Adding a new service:
1. Create interface in `Kemora.Application/Interfaces/`
2. Create implementation in `Kemora.Application/Services/` (business logic) or `Kemora.Infrastructure/Services/` (external)
3. Create DTOs in `Kemora.Application/DTOs/`
4. Add AutoMapper mappings in `MappingProfile.cs`
5. Register in `Program.cs` DI container
6. Create controller in `Kemora.Api/Controllers/`

### Adding a new repository:
1. Create interface in `Kemora.Domain/Interfaces/`
2. Create implementation in `Kemora.Infrastructure/Repositories/`
3. Register in `Program.cs`
