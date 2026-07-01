using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Domain.Models;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace Kemora.Application.Services
{
    public class TripPlannerService : ITripPlannerService
    {
        private readonly IPlacesDataService _placesDataService;
        private readonly IAiService _aiService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICacheService _cache;
        private readonly ILogger<TripPlannerService> _logger;

        public TripPlannerService(
            IPlacesDataService placesDataService, 
            IAiService aiService, 
            IUnitOfWork unitOfWork, 
            ICacheService cache, 
            ILogger<TripPlannerService> logger)
        {
            _placesDataService = placesDataService;
            _aiService = aiService;
            _unitOfWork = unitOfWork;
            _cache = cache;
            _logger = logger;
        }

        public async Task<TripPlanResponseDto> GenerateTripPlanAsync(TripPlanRequestDto request)
        {
            if (request.MinRadiusKm >= request.MaxRadiusKm)
                throw new ArgumentException("MinRadiusKm must be less than MaxRadiusKm.");

            // 1. In-memory cache handling (Level 1)
            string prefs = request.Preferences ?? "none";
            string cacheKey = $"plan_v2_{request.CenterPlaceId}_{request.Latitude}_{request.Longitude}_{request.DurationDays}_{request.Location}_{prefs}_{request.AlternativeIndex}";

            var cachedPlan = _cache.Get<TripPlanResponseDto>(cacheKey);
            if (cachedPlan != null)
                return cachedPlan;

            // 1.5. DB Persistence Cache
            var dbCachedPlan = await _unitOfWork.Repository<PrecomputedTripPlan>()
                .FirstOrDefaultAsync(p => p.CacheKey == cacheKey);
            
            if (dbCachedPlan != null)
            {
                var responseFromDb = new TripPlanResponseDto
                {
                    TripPlan = dbCachedPlan.ItineraryJson,
                    Places = System.Text.Json.JsonSerializer.Deserialize<List<FetchedPlaceDto>>(dbCachedPlan.PlacesJson) ?? [],
                    TotalPlacesFound = System.Text.Json.JsonSerializer.Deserialize<List<FetchedPlaceDto>>(dbCachedPlan.PlacesJson)?.Count ?? 0
                };
                
                // Repopulate memory cache
                _cache.Set(cacheKey, responseFromDb, TimeSpan.FromHours(24));
                return responseFromDb;
            }

            // 2. Center around specific landmark if provided
            if (request.CenterPlaceId.HasValue && request.CenterPlaceId > 0)
            {
                var centerPlace = await _unitOfWork.Repository<Place>().GetByIdAsync(request.CenterPlaceId.Value);
                if (centerPlace != null)
                {
                    request.Latitude = (double)centerPlace.Latitude;
                    request.Longitude = (double)centerPlace.Longitude;
                }
            }

            // 3. Smart Fetching Strategy: Local DB first — strict proximity to avoid cross-city results
            // Cap at 30km regardless of requested radius to ensure city-accurate results
            var strictRadiusKm = Math.Min(request.MaxRadiusKm, 30.0);
            var allDbPlaces = await _unitOfWork.Repository<Place>()
                .GetAllAsync(
                    p => p.PlaceType, 
                    p => p.PlaceType.Category, 
                    p => p.Photos, 
                    p => p.Reviews
                );
            var localPlaces = allDbPlaces
                .Select(p =>
                {
                    // Resolve the best available image: prefer MainImageURL, fall back
                    // to the first non-empty Photo URL. This guarantees every candidate
                    // the AI sees has a usable picture that can be re-injected later.
                    var resolvedImage = !string.IsNullOrWhiteSpace(p.MainImageURL)
                        ? p.MainImageURL
                        : p.Photos?.Select(ph => ph.ImageURL).FirstOrDefault(u => !string.IsNullOrWhiteSpace(u));
                    return new FetchedPlaceDto
                    {
                        DbPlaceId = p.PlaceID,
                        ExternalId = p.GoogleDataId,
                        Name = p.Name,
                        Latitude = (double)p.Latitude,
                        Longitude = (double)p.Longitude,
                        Address = p.Address ?? "",
                        ImageUrl = resolvedImage ?? "",
                        PhotoUrls = p.Photos?.Select(ph => ph.ImageURL).ToList() ?? new List<string>(),
                        Reviews = p.Reviews?.Select(r => new FetchedReviewDto { AuthorName = r.AuthorName, Rating = r.Rating, Text = r.Text }).ToList() ?? new List<FetchedReviewDto>(),
                        Rating = (double)p.Rating,
                        PriceLevel = p.PriceLevel.ToString(),
                        // Populate Types with real GoogleType AND category name so
                        // downstream categorisation (hotels / restaurants / etc.) works.
                        Types = new List<string> {
                            p.PlaceType?.GoogleType ?? "",
                            p.PlaceType?.DisplayName ?? "",
                            p.PlaceType?.Category?.Name ?? "",
                        }.Where(t => !string.IsNullOrEmpty(t)).ToList(),
                        DistanceKm = Math.Round(HaversineKm(request.Latitude, request.Longitude, (double)p.Latitude, (double)p.Longitude), 2)
                    };
                })
                // Only include places within strict radius, with valid coordinates (non-zero),
                // AND that have a usable picture. This ensures the AI can only pick places
                // whose image (stored in Cloudinary) will actually render in the plan.
                .Where(p => p.DistanceKm <= strictRadiusKm
                            && (p.Latitude != 0 || p.Longitude != 0)
                            && !string.IsNullOrWhiteSpace(p.ImageUrl)
                            && !p.ImageUrl.Contains("placeholder", StringComparison.OrdinalIgnoreCase))
                .OrderBy(p => p.DistanceKm)
                .ToList();

            _logger.LogInformation("[TripPlanner] Found {Count} local DB places within {Radius}km of {Location}",
                localPlaces.Count, strictRadiusKm, request.Location);

            List<FetchedPlaceDto> finalPlaces = new List<FetchedPlaceDto>(localPlaces);

            // Removed Foursquare API fallback to strictly use DB places
            // if (finalPlaces.Count < 15) { ... }

            // Sequential image fetching removed to massively improve API response time.
            // Images are now fetched concurrently only for places the AI actually selected.

            if (finalPlaces.Count == 0)
            {
                return new TripPlanResponseDto
                {
                    TotalPlacesFound = 0,
                    Places = [],
                    TripPlan = "No places found in the specified area. Try enlarging the radius."
                };
            }

            // Build a rich place list grouping by type for better AI context
            var hotels = finalPlaces.Where(p => (p.Categories ?? p.Types).Any(t => 
                t.Contains("hotel", StringComparison.OrdinalIgnoreCase) || 
                t.Contains("hostel", StringComparison.OrdinalIgnoreCase) ||
                t.Contains("accommodation", StringComparison.OrdinalIgnoreCase) ||
                t.Contains("resort", StringComparison.OrdinalIgnoreCase))).ToList();

            var restaurants = finalPlaces.Where(p => (p.Categories ?? p.Types).Any(t => 
                t.Contains("restaurant", StringComparison.OrdinalIgnoreCase) || 
                t.Contains("food", StringComparison.OrdinalIgnoreCase) ||
                t.Contains("dining", StringComparison.OrdinalIgnoreCase) ||
                t.Contains("bistro", StringComparison.OrdinalIgnoreCase))).ToList();

            var cafes = finalPlaces.Where(p => (p.Categories ?? p.Types).Any(t => 
                t.Contains("cafe", StringComparison.OrdinalIgnoreCase) || 
                t.Contains("café", StringComparison.OrdinalIgnoreCase) ||
                t.Contains("coffee", StringComparison.OrdinalIgnoreCase) ||
                t.Contains("bakery", StringComparison.OrdinalIgnoreCase))).ToList();

            var attractions = finalPlaces.Except(hotels).Except(restaurants).Except(cafes).ToList();

            // Combine: put hotels first, then top attractions, then dining
            var orderedPlaces = hotels.Take(3)
                .Concat(attractions.OrderByDescending(p => p.Rating).Take(20))
                .Concat(restaurants.OrderByDescending(p => p.Rating).Take(8))
                .Concat(cafes.OrderByDescending(p => p.Rating).Take(4))
                .DistinctBy(p => p.Name)
                .Take(35)
                .ToList();

            if (orderedPlaces.Count == 0) orderedPlaces = finalPlaces.Take(35).ToList();

            var placesListText = string.Join("\n", orderedPlaces.Select((p, idx) =>
            {
                var typeLabel = hotels.Any(h => h.Name == p.Name) ? "[HOTEL]" :
                                restaurants.Any(r => r.Name == p.Name) ? "[RESTAURANT]" :
                                cafes.Any(c => c.Name == p.Name) ? "[CAFÉ]" : "[ATTRACTION]";
                var cats = string.Join(", ", (p.Categories ?? p.Types).Take(2));
                return $"{idx + 1}. {typeLabel} {p.Name} | ID: {p.DbPlaceId} | Rating: {p.Rating:F1} | {cats} | {p.Address}";
            }));

            var sysPrompt = @"You are Kemora, an expert Egyptian travel planner building premium itineraries.
You MUST output ONLY valid JSON, exactly matching this structure:
{
  ""itinerary"": [
    {
      ""day"": 1,
      ""theme"": ""Theme for the day e.g. Historic Cairo & Culture"",
      ""activities"": [
        { ""time"": ""08:00"", ""time_slot"": ""Morning"", ""place"": ""Exact Name From List"", ""place_id"": 123, ""description"": ""2-3 sentence vivid description of what to do there and why it is special."" },
        { ""time"": ""10:30"", ""time_slot"": ""Morning"", ""place"": ""Exact Name From List"", ""place_id"": 456, ""description"": ""..."" },
        { ""time"": ""13:00"", ""time_slot"": ""Afternoon"", ""place"": ""Restaurant Name"", ""place_id"": 789, ""description"": ""Lunch stop description."" },
        { ""time"": ""15:00"", ""time_slot"": ""Afternoon"", ""place"": ""Exact Name From List"", ""place_id"": 101, ""description"": ""..."" },
        { ""time"": ""17:30"", ""time_slot"": ""Afternoon"", ""place"": ""Cafe Name"", ""place_id"": 202, ""description"": ""Afternoon coffee break."" },
        { ""time"": ""19:30"", ""time_slot"": ""Evening"", ""place"": ""Restaurant Name"", ""place_id"": 303, ""description"": ""Dinner description."" }
      ]
    }
  ]
}

RULES:
- You MUST select activities ONLY from the provided curated list. DO NOT invent or hallucinate any places not on the list.
- Use the EXACT `ID` from the list for the `place_id` field. This is strictly required!
- Use the EXACT `Name` from the list for the `place` field.
- Assign realistic times: Morning (07:00-12:00), Afternoon (12:00-18:00), Evening (18:00-23:00)
- time_slot MUST be one of: Morning, Afternoon, Evening
- Each day MUST include: 1 hotel check-in (day 1 only), 1-2 restaurants for meals, 3-5 sightseeing attractions, 1 cafe break
- Write rich engaging 2-3 sentence descriptions for each activity
- Spread activities logically across the full day";

            var userPrompt = $@"Generate a {request.DurationDays}-day itinerary for {request.Location}, Egypt.
Budget: {request.Budget}. Interests: {request.TourismTypes}. User preferences: {prefs}.
Ensure each day has Morning + Afternoon + Evening activities with realistic times.
Select ONLY from this curated list:

{placesListText}";


            var tripPlanContent = await _aiService.GenerateCompletionAsync(sysPrompt, userPrompt, jsonMode: true);

            if (string.IsNullOrEmpty(tripPlanContent) || tripPlanContent.StartsWith("AI Error:"))
            {
                _logger.LogError("AI Trip Planning failed: {Error}", tripPlanContent);
                return new TripPlanResponseDto
                {
                    TotalPlacesFound = finalPlaces.Count,
                    Places = finalPlaces,
                    TripPlan = "Sorry, our AI travel planner is currently busy or rate-limited. Please try again in a few moments."
                };
            }

            // Clean response content (OpenRouter models usually return clean JSON, but strip markdown blocks just in case)
            tripPlanContent = tripPlanContent.Trim();
            if (tripPlanContent.StartsWith("```"))
            {
                var startIdx = tripPlanContent.IndexOf('\n') + 1;
                var endIdx = tripPlanContent.LastIndexOf("```");
                if (endIdx > startIdx)
                {
                    tripPlanContent = tripPlanContent.Substring(startIdx, endIdx - startIdx).Trim();
                }
            }

            // Re-inject image URLs, place_id, category, latitude, longitude into the
            // itinerary from the local loaded places (in case the AI omitted them).
            try
            {
                var jObject = System.Text.Json.Nodes.JsonObject.Parse(tripPlanContent);
                var itinerary = jObject?["itinerary"]?.AsArray();
                if (itinerary != null)
                {
                    foreach (var day in itinerary)
                    {
                        var activities = day?["activities"]?.AsArray();
                        if (activities != null)
                        {
                            foreach (var act in activities)
                            {
                                var placeName = act?["place"]?.ToString();
                                var placeIdToken = act?["place_id"];
                                
                                int? parsedId = null;
                                if (placeIdToken != null && int.TryParse(placeIdToken.ToString(), out int id))
                                {
                                    parsedId = id;
                                }

                                FetchedPlaceDto match = null;
                                
                                // 1. Match by exact ID first (most reliable)
                                if (parsedId.HasValue && parsedId.Value > 0)
                                {
                                    match = finalPlaces.FirstOrDefault(p => p.DbPlaceId == parsedId.Value);
                                }
                                
                                // 2. Fallback to name matching
                                if (match == null && !string.IsNullOrEmpty(placeName))
                                {
                                    match = finalPlaces.FirstOrDefault(p =>
                                        p.Name.Equals(placeName, StringComparison.OrdinalIgnoreCase));
                                        
                                    // 3. Fuzzy name match if still not found
                                    if (match == null)
                                    {
                                        match = finalPlaces.FirstOrDefault(p => 
                                            p.Name.Contains(placeName, StringComparison.OrdinalIgnoreCase) || 
                                            placeName.Contains(p.Name, StringComparison.OrdinalIgnoreCase));
                                    }
                                }

                                if (match != null)
                                {
                                    // Override place name to ensure exact DB match
                                    act["place"] = match.Name;

                                    // Image URL: ImageUrl already holds the resolved best
                                    // picture (MainImageURL with Photo fallback) from the
                                    // candidate filtering stage, so just write it through.
                                    if (!string.IsNullOrWhiteSpace(match.ImageUrl))
                                    {
                                        act["image_url"] = match.ImageUrl;
                                    }
                                    
                                    // Inject Rating & Price
                                    if (match.Rating > 0) act["rating"] = match.Rating;
                                    if (!string.IsNullOrEmpty(match.PriceLevel)) act["price"] = match.PriceLevel;

                                    // Inject Top Review
                                    if (match.Reviews?.Count > 0)
                                    {
                                        var topReview = match.Reviews.OrderByDescending(r => r.Rating).FirstOrDefault();
                                        if (topReview != null)
                                            act["itinerary_review"] = $"\"{topReview.Text}\" - {topReview.AuthorName}";
                                    }
                                    
                                    // place_id — always inject from DB (authoritative)
                                    if (match.DbPlaceId.HasValue)
                                        act["place_id"] = match.DbPlaceId.Value;
                                        
                                    // category — from PlaceType.Category.Name
                                    if (string.IsNullOrEmpty(act["category"]?.ToString()) && match.Types?.Count > 0)
                                        act["category"] = match.Types.Last(); // last = category name
                                        
                                    // coordinates — always inject from DB
                                    act["latitude"] = match.Latitude;
                                    act["longitude"] = match.Longitude;
                                }
                                else
                                {
                                    // AI completely hallucinated a place not in our list
                                    _logger.LogWarning("[TripPlanner] AI hallucinated place: {PlaceName} (ID: {PlaceId})", placeName, parsedId);
                                }
                            }
                        }
                    }
                }
                tripPlanContent = jObject?.ToJsonString() ?? tripPlanContent;
            }
            catch { /* Ignore injection errors — the clean JSON is still valid */ }

            var response = new TripPlanResponseDto
            {
                TotalPlacesFound = finalPlaces.Count,
                Places = finalPlaces,
                TripPlan = tripPlanContent
            };

            // 5. Save the generated alternative to DB (Level 2)
            var newDbCache = new PrecomputedTripPlan
            {
                CacheKey = cacheKey,
                ItineraryJson = tripPlanContent,
                PlacesJson = System.Text.Json.JsonSerializer.Serialize(finalPlaces),
                CreatedAt = DateTime.UtcNow
            };
            await _unitOfWork.Repository<PrecomputedTripPlan>().AddAsync(newDbCache);
            await _unitOfWork.CommitAsync();

            // 6. Save the generated alternative in the in-memory cache (Level 1)
            _cache.Set(cacheKey, response, TimeSpan.FromHours(24));

            return response;
        }

        public async Task<string> SwapPlaceAsync(string currentPlaceName, string preferences)
        {
            var sysPrompt = @"You are a professional Egyptian travel assistant. 
Your task is to swap a specific place in a trip itinerary with a better alternative.
You MUST return valid JSON only, exactly matching this structure:
{
  ""newActivity"": {
    ""time"": ""HH:mm"",
    ""place"": ""New Place Name"",
    ""description"": ""Detailed description of why this is a good alternative.""
  }
}";
            var userPrompt = $@"The current place/activity is: '{currentPlaceName}'. 
User preferences/reason for swapping: '{preferences ?? "looking for something better"}'.
Please suggest a HIGH-QUALITY alternative in the same city/area that matches these preferences. 
Ensure the JSON is clean and valid.";
            
            var result = await _aiService.GenerateCompletionAsync(sysPrompt, userPrompt, jsonMode: true);
            
            // Basic fallback if AI fails or returns non-JSON
            if (string.IsNullOrEmpty(result) || result.StartsWith("AI Error:"))
            {
                return "{\"newActivity\": {\"time\": \"09:00\", \"place\": \"Alternative Suggestion\", \"description\": \"Sorry, I could not generate a specific alternative at this moment. Please try again or select another place manually.\"}}";
            }

            return result;
        }

        private static double HaversineKm(double lat1, double lng1, double lat2, double lng2)
        {
            const double R = 6371;
            var dLat = ToRad(lat2 - lat1);
            var dLng = ToRad(lng2 - lng1);
            var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                  + Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2))
                  * Math.Sin(dLng / 2) * Math.Sin(dLng / 2);
            return R * 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        }

        private static double ToRad(double deg) => deg * Math.PI / 180;
    }
}
