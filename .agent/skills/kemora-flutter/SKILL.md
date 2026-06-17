# Kemora Flutter App Documentation

## Tech Stack
- **State Management**: Provider (`ChangeNotifierProvider`) with `GetIt` for Dependency Injection.
- **HTTP Client**: Dio (with a `TokenStorage` interceptor for JWT authorization).
- **Navigation Pattern**: Standard Flutter `Navigator` (`Navigator.push`, `Navigator.pop`, etc.). Custom route transitions (`FadePageRoute`, `SlidePageRoute`) are occasionally used. No external routing packages.
- **Repository**: [https://github.com/0Zyad1/Kemora/tree/FINAL](https://github.com/0Zyad1/Kemora/tree/FINAL)



## Screen Map
| Screen | Route/Location | Status / Notes | APIs Called |
|--------|----------------|----------------|-------------|
| **Auth** | | | |
| LoginScreen | `auth/login_screen.dart` | Active | `POST /api/v1/auth/login`, `POST /api/v1/auth/google-login` |
| RegisterScreen | `auth/register_screen.dart` | Active | `POST /api/v1/auth/register`, `POST /api/v1/auth/google-login` |
| **Badges** | | | |
| BadgesScreen | `badges/badges_screen.dart` | Active | `GET /api/v1/my/badges`, `GET /api/v1/badges` |
| **Explore** | | | |
| GovernoratesMapScreen | `explore/governorates_map_screen.dart` | Active | `GET /api/v1/places/governorates` |
| GovernorateDetailScreen | `explore/governorate_detail_screen.dart`| Active | |
| GovernoratePlacesScreen | `explore/governorate_places_screen.dart`| Active | |
| PlacesScreen | `explore/places_screen.dart` | Active | `GET /api/v1/places` |
| PlaceDetailScreen | `explore/place_detail_screen.dart` | Active — accepts `placeId` (API) or legacy `PlaceInfo` | `GET /api/v1/places/{id}` (via `PlacesViewModel.getPlaceById`) |
| **Home** | | | |
| HomeScreen | `home/home_screen.dart` | Active | `GET /api/v1/places/top` |
| HomeContentScreen | `home/home_content_screen.dart` | Active — uses `PlacesViewModel` for place cards, `StoryViewModel` for stories, `AuthViewModel` for user name | |
| **Onboarding** | | | |
| OnboardingScreen | `onboarding/onboarding_screen.dart` | Active | None |
| **Profile** | | | |
| AllAchievementsScreen | `profile/all_achievements_screen.dart` | Active | |
| PublicProfileScreen | `profile/public_profile_screen.dart` | Active | `GET /api/v1/profile/{id}/public` |
| RedeemedVouchersScreen | `profile/redeemed_vouchers_screen.dart` | Active | |
| SavedPlacesScreen | `profile/saved_places_screen.dart` | Active | |
| SettingsScreen | `profile/settings_screen.dart` | Active | `PUT /api/v1/profile/my`, change-password, change-email |
| **Social** | | | |
| ChatDetailScreen | `social/chat_detail_screen.dart` | Active | `GET /api/v1/chats/conversation/{id}`, `POST /api/v1/chats/send` |
| ChatListScreen | `social/chat_list_screen.dart` | Active | `GET /api/v1/chats/conversations` |
| CreatePostScreen | `social/create_post_screen.dart` | Active — supports `isStory: true` to create stories | `POST /api/v1/profile/image`, `POST /api/v1/posts` |
| FeedScreen | `social/feed_screen.dart` | Active | `GET /api/v1/posts`, `POST /api/v1/posts/{id}/like` |
| PostDetailScreen | `social/post_detail_screen.dart` | Active | `GET /api/v1/posts/{id}/comments`, `POST /api/v1/posts/{id}/comment` |
| StoryViewerScreen | `social/widgets/story_viewer_screen.dart` | Active — now uses real `UserStoriesGroup` from `StoryViewModel` | |
| **Splash** | | | |
| SplashScreen | `splash/splash_screen.dart` | Active | None |
| **Trip** | | | |
| AiItineraryResultScreen | `trip/ai_itinerary_result_screen.dart` | **[DEPRECATED]** | Old screen, replaced by TripRoadmapScreen. |
| AiStepQuestionsScreen | `trip/ai_step_questions_screen.dart` | Active | `POST /api/v1/places/trip-plan` |
| CustomRoadmapScreen | `trip/custom_roadmap_screen.dart` | Active | |
| GenerateAiItineraryScreen | `trip/generate_ai_itinerary_screen.dart`| Active | `POST /api/v1/places/trip-plan` |
| TripDetailScreen | `trip/trip_detail_screen.dart` | Active | Handles both Local Trips and AI Itineraries. |
| TripPlannerEntryScreen | `trip/trip_planner_entry_screen.dart` | Active | |
| TripPlannerScreen | `trip/trip_planner_screen.dart` | **[MOCK UI]** | Mock UI — needs connection to AiStepQuestionsScreen. |
| TripViewRoadmapScreen | `trip/trip_view_roadmap_screen.dart` | Active | |

## Auth Flow
- **Endpoints**: `POST /api/v1/auth/login`, `POST /api/v1/auth/register`, `POST /api/v1/auth/google-login`
- **Token Storage**: Uses a `TokenStorage` singleton wrapping `SharedPreferences`. The JWT is automatically attached to API requests via a `Dio` interceptor. `UserModel` details are persisted locally.
- **Dev Bypass**: ✅ **REMOVED**. Login always goes through real backend. Admin account `zyadkhaled151@gmail.com` / `123456789@Zz` is seeded in the database with `Admin` role.

## AI Trip Planner Flow
- **Questions Flow**: 5-step flow in `AiStepQuestionsScreen` asking for location, duration, budget, interests (`tourismTypes` mapped to backend enums), and companions (`preferences`).
- **Endpoint**: `POST /api/v1/places/trip-plan` handled by `TripViewModel.generateAiItinerary()`.
- **Results Display**: Displayed via `TripDetailScreen`, which parses the real AI itinerary.
- **Swap Location**: Uses `GET /api/v1/places/swap`.
- **Save Trip**: Uses `POST /api/v1/trips/save-plan`. Awards **AI Pioneer** and **City Hopper** badges automatically.

## Posts / Comments Flow
- **State Handling**: Managed by `PostViewModel`.
- **Current Status**: Real API data. Dev bypass fully removed.
- **Endpoints**:
  - Load Feed: `GET /api/v1/posts`
  - Create Post/Story: `POST /api/v1/posts` (Supports `locationId` and `isStory` toggle).
  - Like: `POST /api/v1/posts/{id}/like`
  - Get Comments: `GET /api/v1/posts/{id}/comments`
  - Add Comment: `POST /api/v1/posts/{id}/comment`
- Awards **Community Starter** badge on first post (via `BadgeAwardService`).

## Image Uploads
- **Previous**: Cloudinary (broken — credentials missing).
- **Current**: ✅ Local file system via `LocalImageService`. Files saved to `wwwroot/uploads/`. URL format: `http://<host>/uploads/<uuid>.<ext>`.
- **Profile Pictures**: `POST /api/v1/profile/image` → `LocalImageService` → returns public URL.
- **Post Images**: `POST /api/v1/posts/image` → same service.

## Database Seeding (Backend)
- **Admin User**: `zyadkhaled151@gmail.com` / `123456789@Zz` seeded with `Admin` role via `DataSeeder.SeedAdminRolesAsync`.
- **Places**: 20 real Egyptian places seeded across 9 governorates (Cairo, Giza, Luxor, Aswan, Alexandria, Red Sea, South Sinai, Matrouh, Fayoum, New Valley) with real descriptions, Google Maps links, and reviews.
- **Social Posts**: 3 seed posts linked to real `PlaceID` values.
- **Badges**: 17 total badges including new ones: Community Starter, AI Pioneer, City Hopper, Daily Devotee, governorate-specific explorer badges.

## Badge System
- **Interface**: `IBadgeAwardService` in `Kemora.Application.Interfaces`.
- **Service**: `BadgeAwardService` in `Kemora.Infrastructure.Services` — all methods idempotent (safe to call multiple times).
- **Triggers**:
  - `TryAwardCommunityStarterAsync(userId)` — called by `PostsController.CreatePost`.
  - `TryAwardAiPioneerAsync(userId)` — called by `TripsController.SaveAIPlan`.
  - `TryAwardCityHopperAsync(userId)` — called by `TripsController.SaveAIPlan`, checks if user's trips span 5+ governorates.

## Place Entity (Flutter)
- `Place` entity extended with: `type`, `address`, `governorateName`, `mainImageUrl`, `priceLevel`, `website`, `reviews: List<ReviewSummary>`.
- `PlaceModel.fromJson` parses all these fields from backend JSON.
- `PlacesViewModel.getPlaceById(id)` checks local caches then triggers API load.

## Known Issues & Pending TODOs
1. **`trip_planner_screen.dart`**: Mock UI — not yet connected to `AiStepQuestionsScreen`.
2. **`custom_roadmap_screen.dart`**: Still uses deprecated `onReorder` callback.
3. **`PlaceDetailScreen` / Community tab**: Still shows placeholder text — should show `PostViewModel` posts filtered by `locationId`.
4. **"Add to trip" button** on `PlaceDetailScreen`: Disabled — needs to pre-seed `AiStepQuestionsScreen`.
5. **AI Trip Planner saved trips**: Edit/delete/swap within saved trips not implemented in Flutter UI.
