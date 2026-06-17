using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Services
{
    /// <summary>
    /// Awards gamification badges automatically when specific events occur.
    /// All methods are idempotent — safe to call repeatedly without double-awarding.
    /// </summary>
    public class BadgeAwardService : IBadgeAwardService
    {
        private readonly ApplicationDbContext _context;

        public BadgeAwardService(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>Awards "Community Starter" on the user's first post.</summary>
        public async Task TryAwardCommunityStarterAsync(string userId)
        {
            await TryAwardAsync(userId, "Community Starter");
        }

        /// <summary>Awards "AI Pioneer" on the user's first saved AI trip.</summary>
        public async Task TryAwardAiPioneerAsync(string userId)
        {
            await TryAwardAsync(userId, "AI Pioneer");
        }

        /// <summary>Awards "City Hopper" when the user's saved trips span 5 or more unique governorates.</summary>
        public async Task TryAwardCityHopperAsync(string userId)
        {
            // Count distinct governorates from all places in the user's saved trips
            var distinctGovCount = await _context.TripPlaces
                .Where(tp => tp.Trip.UserID == userId)
                .Select(tp => tp.Place!.GovernorateID)
                .Where(gid => gid != null)
                .Distinct()
                .CountAsync();

            if (distinctGovCount >= 5)
            {
                await TryAwardAsync(userId, "City Hopper");
            }
        }

        // ── Helpers ────────────────────────────────────────────────────────────────

        private async Task TryAwardAsync(string userId, string badgeName)
        {
            try
            {
                var badge = await _context.Badges
                    .FirstOrDefaultAsync(b => b.Name == badgeName);

                if (badge == null) return;

                var alreadyHas = await _context.UserBadges
                    .AnyAsync(ub => ub.UserID == userId && ub.BadgeID == badge.BadgeID);

                if (!alreadyHas)
                {
                    _context.UserBadges.Add(new UserBadge
                    {
                        UserID = userId,
                        BadgeID = badge.BadgeID,
                        EarnedAt = DateTime.UtcNow
                    });
                    await _context.SaveChangesAsync();
                }
            }
            catch
            {
                // Badge award is non-critical — never block the main request if this fails
            }
        }
    }
}
