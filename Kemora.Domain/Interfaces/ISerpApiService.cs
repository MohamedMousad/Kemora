using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Domain.Interfaces
{
    public interface ISerpApiService
    {
        Task<SerpPlaceResult?> SearchPlaceAsync(string query, double latitude, double longitude);
        Task<List<string>> GetPlacePhotosAsync(string dataId, int limit = 5);
    }

    public class SerpPlaceResult
    {
        public string DataId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Address { get; set; }
        public string? Thumbnail { get; set; }
        public double? Rating { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string? Type { get; set; }
    }
}
