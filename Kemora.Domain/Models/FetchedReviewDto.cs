namespace Kemora.Domain.Models
{
    public class FetchedReviewDto
    {
        public string AuthorName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Text { get; set; } = string.Empty;
    }
}
