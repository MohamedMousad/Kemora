namespace Kemora.Domain.Models
{
    /// <summary>
    /// Represents a place returned from the Google Places API.
    /// Lives in Domain so Infrastructure and API can share this model without coupling.
    /// </summary>
    public class FetchedPlaceDto
    {
        public string? ExternalId { get; set; } // fsq_id
        public string? Source { get; set; } // "foursquare" or "db"
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<string> Types { get; set; } = [];
        public List<string> Categories { get; set; } = []; 
        public double? Rating { get; set; }
        public string? PriceLevel { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        public List<string>? OpeningHours { get; set; }
        public double DistanceKm { get; set; }
        public string? ImageUrl { get; set; }
        public List<string> PhotoUrls { get; set; } = [];
        public int? Popularity { get; set; }
    }
}
