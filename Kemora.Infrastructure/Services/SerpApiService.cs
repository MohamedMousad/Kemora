using Kemora.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Services
{
    public class SerpApiService : ISerpApiService
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly IConfiguration _config;
        private readonly ILogger<SerpApiService> _logger;

        public SerpApiService(IHttpClientFactory httpFactory, IConfiguration config, ILogger<SerpApiService> logger)
        {
            _httpFactory = httpFactory;
            _config = config;
            _logger = logger;
        }

        private string GetApiKey() => _config["SerpApi:ApiKey"] ?? string.Empty;

        public async Task<SerpPlaceResult?> SearchPlaceAsync(string query, double latitude, double longitude)
        {
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey)) return null;

            try
            {
                var client = _httpFactory.CreateClient("SerpApi");
                var llString = Uri.EscapeDataString($"@{latitude},{longitude},14z");
                var qString = Uri.EscapeDataString(query);
                var url = $"?engine=google_maps&q={qString}&ll={llString}&type=search&api_key={apiKey}";

                var response = await client.GetAsync(url);
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("SerpApi Search failed for {Query}: {Status}", query, response.StatusCode);
                    return null;
                }

                var jsonStr = await response.Content.ReadAsStringAsync();
                var doc = JsonDocument.Parse(jsonStr);

                if (doc.RootElement.TryGetProperty("error", out var err))
                {
                    _logger.LogError("SerpApi Error: {Error}", err.GetString());
                    return null;
                }

                // Try local_results first (most common for place searches)
                if (doc.RootElement.TryGetProperty("local_results", out var results)
                    && results.ValueKind == JsonValueKind.Array
                    && results.GetArrayLength() > 0)
                {
                    var firstResult = results[0];
                    var serpPlace = new SerpPlaceResult();

                    if (firstResult.TryGetProperty("data_id", out var dataIdVal)) serpPlace.DataId = dataIdVal.GetString() ?? "";
                    if (firstResult.TryGetProperty("title", out var titleVal)) serpPlace.Title = titleVal.GetString() ?? "";
                    if (firstResult.TryGetProperty("address", out var addrVal)) serpPlace.Address = addrVal.GetString();
                    if (firstResult.TryGetProperty("thumbnail", out var thumbVal)) serpPlace.Thumbnail = thumbVal.GetString();
                    if (firstResult.TryGetProperty("rating", out var ratingVal)) serpPlace.Rating = ratingVal.GetDouble();
                    if (firstResult.TryGetProperty("type", out var typeVal)) serpPlace.Type = typeVal.GetString();

                    if (firstResult.TryGetProperty("gps_coordinates", out var gps))
                    {
                        if (gps.TryGetProperty("latitude", out var latVal)) serpPlace.Latitude = latVal.GetDouble();
                        if (gps.TryGetProperty("longitude", out var lngVal)) serpPlace.Longitude = lngVal.GetDouble();
                    }

                    return serpPlace;
                }

                // Fallback: knowledge_graph for well-known landmarks
                if (doc.RootElement.TryGetProperty("knowledge_graph", out var kg))
                {
                    var serpPlace = new SerpPlaceResult();
                    if (kg.TryGetProperty("title", out var t)) serpPlace.Title = t.GetString() ?? query;
                    if (kg.TryGetProperty("thumbnail", out var thumb)) serpPlace.Thumbnail = thumb.GetString();
                    if (kg.TryGetProperty("rating", out var r)) serpPlace.Rating = r.GetDouble();
                    // Encode place name as synthetic ID so GetPlacePhotosAsync can do a google_images search
                    serpPlace.DataId = "img_" + Uri.EscapeDataString(query);
                    return serpPlace;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to search place on SerpApi: {Query}", query);
            }
            return null;
        }

        public async Task<List<string>> GetPlacePhotosAsync(string dataId, int limit = 5)
        {
            var apiKey = GetApiKey();
            var photos = new List<string>();
            if (string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(dataId)) return photos;

            // For real Google Maps data_ids, try the google_maps_photos engine first
            if (!dataId.StartsWith("img_"))
            {
                try
                {
                    var client = _httpFactory.CreateClient("SerpApi");
                    var url = $"?engine=google_maps_photos&data_id={Uri.EscapeDataString(dataId)}&api_key={apiKey}";
                    var response = await client.GetAsync(url);

                    if (response.IsSuccessStatusCode)
                    {
                        var jsonStr = await response.Content.ReadAsStringAsync();
                        var doc = JsonDocument.Parse(jsonStr);

                        if (!doc.RootElement.TryGetProperty("error", out _) &&
                            doc.RootElement.TryGetProperty("photos", out var photosArr) &&
                            photosArr.ValueKind == JsonValueKind.Array &&
                            photosArr.GetArrayLength() > 0)
                        {
                            foreach (var photo in photosArr.EnumerateArray())
                            {
                                if (photos.Count >= limit) break;
                                if (photo.TryGetProperty("image", out var img)) photos.Add(img.GetString()!);
                                else if (photo.TryGetProperty("thumbnail", out var th)) photos.Add(th.GetString()!);
                            }
                            if (photos.Count > 0) return photos;
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "google_maps_photos failed for dataId: {DataId}, falling back to google_images", dataId);
                }
            }

            // Fallback: google_images search by place name — works for all places
            var searchTerm = dataId.StartsWith("img_")
                ? Uri.UnescapeDataString(dataId.Substring(4))
                : dataId; // Use data_id itself as a last-resort search term

            try
            {
                var client = _httpFactory.CreateClient("SerpApi");
                var encodedQ = Uri.EscapeDataString($"{searchTerm} Egypt tourist attraction");
                var url = $"?engine=google_images&q={encodedQ}&api_key={apiKey}&num=5&safe=active&gl=eg";

                var response = await client.GetAsync(url);
                if (response.IsSuccessStatusCode)
                {
                    var jsonStr = await response.Content.ReadAsStringAsync();
                    var doc = JsonDocument.Parse(jsonStr);

                    if (doc.RootElement.TryGetProperty("images_results", out var imgResults) &&
                        imgResults.ValueKind == JsonValueKind.Array)
                    {
                        foreach (var img in imgResults.EnumerateArray())
                        {
                            if (photos.Count >= limit) break;
                            if (img.TryGetProperty("original", out var orig) && orig.GetString() is string s && s.StartsWith("http"))
                                photos.Add(s);
                            else if (img.TryGetProperty("thumbnail", out var thumb) && thumb.GetString() is string t && t.StartsWith("http"))
                                photos.Add(t);
                        }
                    }
                }
                else
                {
                    _logger.LogWarning("google_images fallback returned {Status} for: {Query}", response.StatusCode, searchTerm);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "google_images fallback failed for: {Query}", searchTerm);
            }

            return photos;
        }
    }
}
