using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Kemora.Domain.Interfaces;
using Kemora.Domain.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Kemora.Infrastructure.Services
{
    public class FoursquarePlacesService : IPlacesDataService
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly IConfiguration _config;
        private readonly ILogger<FoursquarePlacesService> _logger;

        public FoursquarePlacesService(
            IHttpClientFactory httpFactory,
            IConfiguration config,
            ILogger<FoursquarePlacesService> logger)
        {
            _httpFactory = httpFactory;
            _config = config;
            _logger = logger;
            
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey))
                _logger.LogWarning("[Foursquare] API key is NOT configured!");
            else
                _logger.LogInformation("[Foursquare] API key loaded (length={Len}).", apiKey.Length);
        }

        private string GetApiKey() => _config["Foursquare:ApiKey"] ?? string.Empty;

        public async Task<List<FetchedPlaceDto>> SearchPlacesAsync(
            string query, double latitude, double longitude, int radiusMeters = 20000, 
            int limit = 20, string[]? categories = null)
        {
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey)) return [];

            var client = _httpFactory.CreateClient("Foursquare");
            var catString = categories != null && categories.Length > 0 ? $"&categories={string.Join(",", categories)}" : "";
            var qString = !string.IsNullOrWhiteSpace(query) ? $"&query={Uri.EscapeDataString(query)}" : "";
            var url = $"https://places-api.foursquare.com/places/search?ll={latitude.ToString(System.Globalization.CultureInfo.InvariantCulture)},{longitude.ToString(System.Globalization.CultureInfo.InvariantCulture)}&radius={radiusMeters}{qString}{catString}&limit={Math.Min(limit, 50)}";

            var request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Headers.Add("Authorization", "Bearer " + apiKey.Trim());
            request.Headers.Add("Accept", "application/json");
            request.Headers.Add("X-Places-Api-Version", "2025-06-17");

            try
            {
                var httpResponse = await client.SendAsync(request);
                
                if (!httpResponse.IsSuccessStatusCode)
                {
                    var errorContent = await httpResponse.Content.ReadAsStringAsync();
                    _logger.LogError("[Foursquare] v3 Search Error {StatusCode}: {Content}", httpResponse.StatusCode, errorContent);
                    return [];
                }
                
                var response = await httpResponse.Content.ReadFromJsonAsync<FoursquareSearchResponse>();
                return MapResults(response?.Results);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to search Foursquare places");
                return [];
            }
        }

        public async Task<List<FetchedPlaceDto>> SearchPlacesByAreaAsync(
            string nearLocation, string[]? categories = null, int limit = 20, int page = 1,
            double latitude = 0, double longitude = 0)
        {
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey)) return [];

            var client = _httpFactory.CreateClient("Foursquare");
            var catString = categories != null && categories.Length > 0 ? $"&categories={string.Join(",", categories)}" : "";
            var offset = (page - 1) * 20;
            
            var url = latitude != 0 && longitude != 0
                ? $"https://places-api.foursquare.com/places/search?ll={latitude.ToString(System.Globalization.CultureInfo.InvariantCulture)},{longitude.ToString(System.Globalization.CultureInfo.InvariantCulture)}&radius=30000{catString}&limit=20&offset={offset}"
                : $"https://places-api.foursquare.com/places/search?near={Uri.EscapeDataString(nearLocation)}{catString}&limit=20&offset={offset}";

            var request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Headers.Add("Authorization", "Bearer " + apiKey.Trim());
            request.Headers.Add("Accept", "application/json");
            request.Headers.Add("X-Places-Api-Version", "2025-06-17");

            try
            {
                var httpResponse = await client.SendAsync(request);
                
                if (!httpResponse.IsSuccessStatusCode)
                {
                    var errorContent = await httpResponse.Content.ReadAsStringAsync();
                    _logger.LogError("[Foursquare] v3 Area Search Error {StatusCode}: {Content}", httpResponse.StatusCode, errorContent);
                    return [];
                }
                
                var response = await httpResponse.Content.ReadFromJsonAsync<FoursquareSearchResponse>();
                var results = MapResults(response?.Results);
                _logger.LogInformation("[Foursquare] {Count} places fetched for '{Area}' (page {Page})", results.Count, nearLocation, page);
                return results;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to search Foursquare places by area");
                return [];
            }
        }

        public async Task<FetchedPlaceDto?> GetPlaceDetailsAsync(string foursquareId)
        {
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey)) return null;

            var client = _httpFactory.CreateClient("Foursquare");
            var url = $"https://places-api.foursquare.com/places/{foursquareId}";

            var request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Headers.Add("Authorization", "Bearer " + apiKey.Trim());
            request.Headers.Add("Accept", "application/json");
            request.Headers.Add("X-Places-Api-Version", "2025-06-17");

            try
            {
                var httpResponse = await client.SendAsync(request);
                
                if (!httpResponse.IsSuccessStatusCode)
                {
                    var errorContent = await httpResponse.Content.ReadAsStringAsync();
                    _logger.LogError("[Foursquare] v3 Details Error {StatusCode}: {Content}", httpResponse.StatusCode, errorContent);
                    return null;
                }
                
                var response = await httpResponse.Content.ReadFromJsonAsync<FoursquarePlaceResult>();
                if (response == null) return null;
                return MapResult(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get Foursquare place details");
                return null;
            }
        }

        public async Task<List<FetchedPlaceDto>> FetchNearbyPlacesAsync(
            double latitude, double longitude, double minRadiusKm = 0, double maxRadiusKm = 20)
        {
            // 19000 = Hotels & Lodging, 13000 = Dining, 13032 = Cafés & Coffee,
            // 16000 = Landmarks & Outdoors, 10000 = Arts & Entertainment, 12000 = Museums
            var categories = new[] { "19000", "13000", "13032", "16000", "10000", "12000" };
            return await SearchPlacesAsync(string.Empty, latitude, longitude, (int)(maxRadiusKm * 1000), 50, categories);
        }

        private List<FetchedPlaceDto> MapResults(List<FoursquarePlaceResult>? results)
        {
            if (results == null) return [];
            return results.Select(MapResult).ToList();
        }

        private FetchedPlaceDto MapResult(FoursquarePlaceResult p)
        {
            // Photos are a premium Foursquare feature — we use SerpApi for photos instead
            return new FetchedPlaceDto
            {
                ExternalId = p.FsqId,
                Source = "foursquare",
                Name = p.Name ?? "Unknown Place",
                Address = p.Location?.FormattedAddress ?? string.Empty,
                Description = p.Description,
                Categories = p.Categories?.Select(c => c.Name).Where(c => c != null).ToList()! ?? [],
                Types = p.Categories?.Select(c => c.Name).Where(c => c != null).ToList()! ?? [],
                Rating = p.Rating,
                PriceLevel = p.Price?.ToString(),
                Latitude = p.Location?.Geocode?.Main?.Latitude ?? p.Location?.Geocode?.DropOff?.Latitude ?? 0,
                Longitude = p.Location?.Geocode?.Main?.Longitude ?? p.Location?.Geocode?.DropOff?.Longitude ?? 0,
                Phone = p.Tel,
                Website = p.Website,
                OpeningHours = p.Hours?.Display != null ? new List<string> { p.Hours.Display } : null,
                Popularity = (int?)p.Popularity
            };
        }

        // --- DTOs for JSON deserialization ---
        private class FoursquareSearchResponse { [JsonPropertyName("results")] public List<FoursquarePlaceResult>? Results { get; set; } }
        private class FoursquarePlaceResult
        {
            [JsonPropertyName("fsq_id")] public string? FsqId { get; set; }
            [JsonPropertyName("name")] public string? Name { get; set; }
            [JsonPropertyName("location")] public FoursquareLocation? Location { get; set; }
            [JsonPropertyName("categories")] public List<FoursquareCategory>? Categories { get; set; }
            [JsonPropertyName("rating")] public double? Rating { get; set; }
            [JsonPropertyName("price")] public int? Price { get; set; }
            [JsonPropertyName("hours")] public FoursquareHours? Hours { get; set; }
            [JsonPropertyName("tel")] public string? Tel { get; set; }
            [JsonPropertyName("website")] public string? Website { get; set; }
            [JsonPropertyName("description")] public string? Description { get; set; }
            [JsonPropertyName("popularity")] public double? Popularity { get; set; }
            [JsonPropertyName("photos")] public List<FoursquarePhoto>? Photos { get; set; }
        }
        private class FoursquareLocation 
        { 
            [JsonPropertyName("formatted_address")] public string? FormattedAddress { get; set; }
            [JsonPropertyName("geocodes")] public FoursquareGeocodes? Geocode { get; set; }
        }
        private class FoursquareGeocodes { [JsonPropertyName("main")] public FoursquareLatLng? Main { get; set; } [JsonPropertyName("drop_off")] public FoursquareLatLng? DropOff { get; set; } }
        private class FoursquareLatLng { [JsonPropertyName("latitude")] public double Latitude { get; set; } [JsonPropertyName("longitude")] public double Longitude { get; set; } }
        private class FoursquareCategory { [JsonPropertyName("name")] public string? Name { get; set; } }
        private class FoursquareHours { [JsonPropertyName("display")] public string? Display { get; set; } }
        private class FoursquarePhoto { [JsonPropertyName("prefix")] public string? Prefix { get; set; } [JsonPropertyName("suffix")] public string? Suffix { get; set; } }
    }
}
