# Kemora

**Kemora** is a comprehensive Egyptian tourism platform consisting of a .NET 10 backend API and a Flutter mobile application. The platform provides detailed place discovery, AI-powered trip planning, a social community feed, real-time chats, and a gamified badge system.

## Project Statistics
- **Total Source Files:** ~6,200+ (C# and Dart files across backend and frontend)
- **Architecture Style:** Clean Architecture (Strictly enforced across both Backend & Frontend)
- **Core Entities:** 15+ including Places, Trips, Posts, Comments, Badges, and Users

## Technology Stack

### Backend (.NET 10 Web API)
- **Framework:** .NET 10, ASP.NET Core
- **Database / ORM:** SQL Server (LocalDB) / Entity Framework Core 10
- **Authentication:** ASP.NET Identity + JWT Bearer Token (Role-based: User/Admin)
- **Mapping:** AutoMapper
- **Logging:** Serilog (Console + Rolling File)
- **Third-Party Integrations:**
  - **Email:** MailKit/MimeKit via Brevo SMTP
  - **Storage:** Cloudinary (Image Uploads)
  - **AI / Trip Planning:** WisdomGate AI (OpenAI-compatible)
  - **Places Data:** Google Maps Places API
  - **Data Enrichment:** Wikipedia API
- **Real-time:** SignalR (Notifications Hub)
- **API Utilities:** Asp.Versioning.Mvc, Swagger/Swashbuckle, Rate Limiting

### Frontend (Flutter)
- **State Management:** `provider` (ChangeNotifier / ViewModels)
- **Dependency Injection:** `get_it`
- **Networking:** `dio` (with JWT interceptors)
- **Routing:** `go_router`
- **Functional / Error Handling:** `dartz` (Either / Left-Right pattern)
- **UI & Assets:** `google_maps_flutter`, `google_fonts` (Outfit), `cached_network_image`, `flutter_svg`

## Architecture Overview

### Backend Architecture
The backend strictly follows a 4-layer Clean Architecture dependency flow: `Domain ← Application ← Infrastructure ← Api`
1. **Domain:** Core entities (e.g., `ApplicationUser`, `Place`, `Trip`, `Post`, `Badge`), enums, and repository interfaces. Contains zero external project references.
2. **Application:** Business logic encapsulation through Services (e.g., `TripPlannerService`, `PostService`), DTOs, and AutoMapper profiles.
3. **Infrastructure:** EF Core `ApplicationDbContext`, Repository implementations (`IUnitOfWork`), and external service clients.
4. **Api:** Controllers handling HTTP requests, global exception handling middleware, and dependency injection composition.

### Frontend Architecture
The mobile app leverages a feature-based 3-layer Clean Architecture:
1. **Domain Layer:** Pure Dart entities (`User`, `Place`, `Trip`), abstract repositories, and single-responsibility Use Cases (e.g., `CreateTripPlanUseCase`).
2. **Data Layer:** Remote Data Sources utilizing `dio` for API communication, JSON serializable models, and Repository implementations that handle mapping and error wrapping via `dartz`.
3. **Presentation Layer:** ChangeNotifiers acting as ViewModels to manage view state, and UI components separated by feature (e.g., Auth, Map, AI Planner, Community).

## Gamification & Social Features
- **Gamification:** Users earn points and badges for exploring and interacting with the app.
- **Social Feed:** A fully-featured community section allowing users to create posts with media, react to content, and nest comments.
- **AI Integration:** WisdomGate AI dynamically generates rich itineraries based on user preferences (budget, pace, vibe, and tourism type).

## UI/UX Aesthetics
- **Typography:** Outfit (Google Fonts).
- **Color Palette:** Egyptian themes incorporating Classic Gold (`#D4AF37`), Sand Gold (`#F4E4BC`), and Deep Nile Blue (`#0D253F`).
- **Visuals:** Uses glassmorphism, subtle micro-animations, and smooth gradients for a premium experience.