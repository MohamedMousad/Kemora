using Kemora.Domain.Interfaces;
using Kemora.Domain.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Services
{
    public class SerpApiPlacesService : IPlacesDataService
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly IConfiguration _config;
        private readonly ILogger<SerpApiPlacesService> _logger;

        public SerpApiPlacesService(IHttpClientFactory httpFactory, IConfiguration config, ILogger<SerpApiPlacesService> logger)
        {
            _httpFactory = httpFactory;
            _config = config;
            _logger = logger;
        }

        private string GetApiKey() => _config["SerpApi:ApiKey"] ?? string.Empty;

        public async Task<List<FetchedPlaceDto>> SearchPlacesByAreaAsync(string nearLocation, string[]? categories = null, int limit = 20, int page = 1, double latitude = 0, double longitude = 0)
        {
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey)) return [];

            var categoryQuery = categories != null && categories.Length > 0 ? string.Join(" ", categories) : "tourist attractions";
            var query = $"{categoryQuery} in {nearLocation}";
            var offset = (page - 1) * 20;

            var client = _httpFactory.CreateClient("SerpApi");
            var url = $"?engine=google_local&q={Uri.EscapeDataString(query)}&api_key={apiKey}&start={offset}&num=20";

            if (latitude != 0 && longitude != 0)
            {
                url += $"&location={latitude.ToString(System.Globalization.CultureInfo.InvariantCulture)},{longitude.ToString(System.Globalization.CultureInfo.InvariantCulture)}";
            }

            try
            {
                var response = await client.GetAsync(url);
                if (!response.IsSuccessStatusCode)
                {
                    var error = await response.Content.ReadAsStringAsync();
                    _logger.LogError("SerpApi Places Error {StatusCode}: {Error}", response.StatusCode, error);
                    return [];
                }

                var doc = await response.Content.ReadFromJsonAsync<JsonDocument>();
                var results = new List<FetchedPlaceDto>();

                if (doc != null && doc.RootElement.TryGetProperty("local_results", out var localResults) && localResults.ValueKind == JsonValueKind.Array)
                {
                    foreach (var result in localResults.EnumerateArray())
                    {
                        var place = new FetchedPlaceDto
                        {
                            ExternalId = result.TryGetProperty("data_id", out var id) ? id.GetString() : Guid.NewGuid().ToString(),
                            Name = result.TryGetProperty("title", out var title) ? title.GetString()! : "Unknown",
                            Address = result.TryGetProperty("address", out var addr) ? addr.GetString() : string.Empty,
                            Rating = result.TryGetProperty("rating", out var rating) ? rating.GetDouble() : 0,
                            Source = "serpapi_local",
                            Description = result.TryGetProperty("description", out var desc) ? desc.GetString() : string.Empty
                        };

                        if (result.TryGetProperty("gps_coordinates", out var gps))
                        {
                            if (gps.TryGetProperty("latitude", out var lat)) place.Latitude = lat.GetDouble();
                            if (gps.TryGetProperty("longitude", out var lng)) place.Longitude = lng.GetDouble();
                        }

                        if (string.IsNullOrEmpty(place.Name) || place.Name == "Unknown") continue;
                        results.Add(place);
                    }
                }

                _logger.LogInformation("SerpApi fetched {Count} places for {Query}", results.Count, query);
                return results;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to search places via SerpApi");
                return [];
            }
        }

        public async Task<List<FetchedPlaceDto>> SearchPlacesAsync(string query, double latitude, double longitude, int radiusMeters = 20000, int limit = 20, string[]? categories = null)
        {
            // Similar implementation using google_local
            return await SearchPlacesByAreaAsync($"{latitude},{longitude}", categories, limit, 1, latitude, longitude);
        }

        public async Task<FetchedPlaceDto?> GetPlaceDetailsAsync(string externalId)
        {
            // SerpApi doesn't have a direct "get by ID" for local results in a simple way without searching again
            // but we can search for the title if we have it. For now, return null or implement search.
            return null;
        }

        public async Task<List<FetchedPlaceDto>> FetchNearbyPlacesAsync(double latitude, double longitude, double minRadiusKm = 0, double maxRadiusKm = 20)
        {
            return await SearchPlacesAsync("tourist attractions", latitude, longitude, (int)(maxRadiusKm * 1000), 20);
        }
    }
}
