using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    /// <summary>
    /// Checks if a user qualifies for a specific achievement badge
    /// and awards it (idempotent — safe to call multiple times).
    /// </summary>
    public interface IBadgeAwardService
    {
        /// <summary>Awards "Community Starter" badge on a user's first post.</summary>
        Task TryAwardCommunityStarterAsync(string userId);

        /// <summary>Awards "AI Pioneer" badge on a user's first saved AI trip.</summary>
        Task TryAwardAiPioneerAsync(string userId);

        /// <summary>Awards "City Hopper" badge when user has trips spanning 5 governorates.</summary>
        Task TryAwardCityHopperAsync(string userId);
    }
}
