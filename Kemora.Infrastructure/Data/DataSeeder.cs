using Kemora.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Data
{
    public static class DataSeeder
    {
        public static async Task SeedAsync(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();

            await SeedGovernoratesAsync(context);
            await SeedCategoriesAsync(context);
            await SeedPlaceTypesAsync(context);
            
            await SeedUsersAsync(userManager, context);
            await SeedBadgesAsync(context);

            await SeedSocialPostsAsync(context);
            await AwardInitialBadgesAsync(context);
        }

        private static async Task SeedGovernoratesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Governorates...");
            if (await context.Governorates.AnyAsync()) {
                System.Console.WriteLine("SEED: Governorates already exist. Skipping.");
                return;
            }

            var governorates = new List<Governorate>
            {
                new() { Name = "Cairo", Region = "Greater Cairo", Latitude = 30.0444m, Longitude = 31.2357m, ImageURL = "https://images.unsplash.com/photo-1572252009286-268acec5ca0a?auto=format&fit=crop&w=1200" },
                new() { Name = "Giza", Region = "Greater Cairo", Latitude = 29.9792m, Longitude = 31.1342m, ImageURL = "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?auto=format&fit=crop&w=1200" },
                new() { Name = "Alexandria", Region = "Northern Coast", Latitude = 31.2001m, Longitude = 29.9187m, ImageURL = "https://images.unsplash.com/photo-1621251817478-f685c7bb74e6?auto=format&fit=crop&w=1200" },
                new() { Name = "Luxor", Region = "Upper Egypt", Latitude = 25.6872m, Longitude = 32.6396m, ImageURL = "https://images.unsplash.com/photo-1594916301297-a7eb443a9926?auto=format&fit=crop&w=1200" },
                new() { Name = "Aswan", Region = "Upper Egypt", Latitude = 24.0889m, Longitude = 32.8998m, ImageURL = "https://images.unsplash.com/photo-1610486828590-edc9372e617d?auto=format&fit=crop&w=1200" },
                new() { Name = "Red Sea", Region = "Eastern Coast", Latitude = 27.2579m, Longitude = 33.8116m, ImageURL = "https://images.unsplash.com/photo-1584025000781-9f935fcc2dbe?auto=format&fit=crop&w=1200" },
                new() { Name = "South Sinai", Region = "Sinai Peninsula", Latitude = 27.9158m, Longitude = 34.3299m, ImageURL = "https://images.unsplash.com/photo-1622350720516-ec7fdf41a100?auto=format&fit=crop&w=1200" },
                new() { Name = "Matrouh", Region = "Northern Coast", Latitude = 31.3543m, Longitude = 27.2373m, ImageURL = "https://images.unsplash.com/photo-1616790809516-92895f11181f?auto=format&fit=crop&w=1200" },
                new() { Name = "Fayoum", Region = "Central Egypt", Latitude = 29.3090m, Longitude = 30.8418m, ImageURL = "https://images.unsplash.com/photo-1601058268499-e52658b8ebf8?auto=format&fit=crop&w=1200" },
                new() { Name = "Dakahlia", Region = "Nile Delta", Latitude = 31.0413m, Longitude = 31.3785m },
                new() { Name = "Sharqia", Region = "Nile Delta", Latitude = 30.6234m, Longitude = 31.6375m },
                new() { Name = "Qalyubia", Region = "Greater Cairo", Latitude = 30.3308m, Longitude = 31.2241m },
                new() { Name = "Kafr El Sheikh", Region = "Nile Delta", Latitude = 31.2137m, Longitude = 30.6872m },
                new() { Name = "Gharbia", Region = "Nile Delta", Latitude = 30.7303m, Longitude = 30.9996m },
                new() { Name = "Monufia", Region = "Nile Delta", Latitude = 30.4682m, Longitude = 30.9859m },
                new() { Name = "Beheira", Region = "Nile Delta", Latitude = 31.0364m, Longitude = 30.4699m },
                new() { Name = "Beni Suef", Region = "Central Egypt", Latitude = 29.0661m, Longitude = 31.0994m },
                new() { Name = "Minya", Region = "Upper Egypt", Latitude = 28.1096m, Longitude = 30.7516m },
                new() { Name = "Asyut", Region = "Upper Egypt", Latitude = 27.1802m, Longitude = 31.1837m },
                new() { Name = "Sohag", Region = "Upper Egypt", Latitude = 26.5591m, Longitude = 31.6957m },
                new() { Name = "Qena", Region = "Upper Egypt", Latitude = 26.1551m, Longitude = 32.7160m },
                new() { Name = "Damietta", Region = "Nile Delta", Latitude = 31.4175m, Longitude = 31.8144m },
                new() { Name = "Port Said", Region = "Canal Zone", Latitude = 31.2653m, Longitude = 32.3020m },
                new() { Name = "Suez", Region = "Canal Zone", Latitude = 29.9668m, Longitude = 32.5498m },
                new() { Name = "Ismailia", Region = "Canal Zone", Latitude = 30.5965m, Longitude = 32.2715m },
                new() { Name = "North Sinai", Region = "Sinai Peninsula", Latitude = 30.5903m, Longitude = 33.7052m },
                new() { Name = "New Valley", Region = "Western Desert", Latitude = 25.4390m, Longitude = 30.5586m },
            };

            context.Governorates.AddRange(governorates);
            await context.SaveChangesAsync();
        }

        private static async Task SeedCategoriesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Categories...");
            if (await context.Categories.AnyAsync()) {
                System.Console.WriteLine("SEED: Categories already exist. Skipping.");
                return;
            }
            var categories = new List<Category>
            {
                new() { Name = "Historical" },
                new() { Name = "Beach" },
                new() { Name = "Cultural" },
                new() { Name = "Adventure" },
                new() { Name = "Religious" },
                new() { Name = "Nature" },
                new() { Name = "Shopping" },
                new() { Name = "Food & Dining" }
            };
            context.Categories.AddRange(categories);
            await context.SaveChangesAsync();
        }

        private static async Task SeedPlaceTypesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Place Types...");
            if (await context.PlaceTypes.AnyAsync()) {
                System.Console.WriteLine("SEED: Place Types already exist. Skipping.");
                return;
            }
            var historical = await context.Categories.FirstAsync(c => c.Name == "Historical");
            var beach = await context.Categories.FirstAsync(c => c.Name == "Beach");
            var cultural = await context.Categories.FirstAsync(c => c.Name == "Cultural");
            var adventure = await context.Categories.FirstAsync(c => c.Name == "Adventure");
            var religious = await context.Categories.FirstAsync(c => c.Name == "Religious");
            var nature = await context.Categories.FirstAsync(c => c.Name == "Nature");
            var shopping = await context.Categories.FirstAsync(c => c.Name == "Shopping");
            var food = await context.Categories.FirstAsync(c => c.Name == "Food & Dining");

            var types = new List<PlaceType>
            {
                new() { GoogleType = "temple", DisplayName = "Temple", CategoryID = historical.CategoryID },
                new() { GoogleType = "pyramid", DisplayName = "Pyramid", CategoryID = historical.CategoryID },
                new() { GoogleType = "museum", DisplayName = "Museum", CategoryID = cultural.CategoryID },
                new() { GoogleType = "beach_resort", DisplayName = "Beach Resort", CategoryID = beach.CategoryID },
                new() { GoogleType = "national_park", DisplayName = "National Park", CategoryID = nature.CategoryID },
                new() { GoogleType = "mosque", DisplayName = "Mosque", CategoryID = religious.CategoryID },
                new() { GoogleType = "church", DisplayName = "Church", CategoryID = religious.CategoryID },
                new() { GoogleType = "restaurant", DisplayName = "Restaurant", CategoryID = food.CategoryID },
                new() { GoogleType = "market", DisplayName = "Market/Bazaar", CategoryID = shopping.CategoryID },
                new() { GoogleType = "hotel", DisplayName = "Hotel", CategoryID = beach.CategoryID },
                new() { GoogleType = "oasis", DisplayName = "Oasis", CategoryID = nature.CategoryID },
                new() { GoogleType = "diving_spot", DisplayName = "Diving Spot", CategoryID = adventure.CategoryID },
                new() { GoogleType = "safari", DisplayName = "Desert Safari", CategoryID = adventure.CategoryID },
                new() { GoogleType = "citadel", DisplayName = "Citadel/Fort", CategoryID = historical.CategoryID }
            };

            context.PlaceTypes.AddRange(types);
            await context.SaveChangesAsync();
        }

        private static async Task SeedUsersAsync(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            var users = new List<ApplicationUser>
            {
                new ApplicationUser { UserName = "john_doe", Email = "john@example.com", FullName = "John Doe", Country = "USA", ProfilePictureUrl = "https://i.pravatar.cc/150?u=john", UserPreferencesJSON = "{\"Budget\": \"Mid-Range\", \"Vibe\": \"Historical\"}" },
                new ApplicationUser { UserName = "sarah_smith", Email = "sarah@example.com", FullName = "Sarah Smith", Country = "UK", ProfilePictureUrl = "https://i.pravatar.cc/150?u=sarah", UserPreferencesJSON = "{\"Budget\": \"Luxury\", \"Vibe\": \"Relaxed\"}" },
                new ApplicationUser { UserName = "ahmed_ali", Email = "ahmed@example.com", FullName = "Ahmed Ali", Country = "Egypt", ProfilePictureUrl = "https://i.pravatar.cc/150?u=ahmed", UserPreferencesJSON = "{\"Budget\": \"Budget\", \"Vibe\": \"Adventure\"}" },
                new ApplicationUser { Id = "guest", UserName = "guest", Email = "guest@kemora.com", FullName = "Guest User", Country = "Egypt" }
            };

            foreach (var user in users)
            {
                if (await userManager.FindByNameAsync(user.UserName!) == null)
                {
                    if (user.Id == "guest") System.Console.WriteLine("SEED: Creating fallback 'guest' user...");
                    await userManager.CreateAsync(user, "Password123!");
                }
            }
        }



        private static async Task SeedSocialPostsAsync(ApplicationDbContext context)
        {
            if (await context.Posts.AnyAsync()) return;

            var user1 = await context.Users.FirstOrDefaultAsync(u => u.UserName == "john_doe");
            var user2 = await context.Users.FirstOrDefaultAsync(u => u.UserName == "sarah_smith");
            if (user1 == null || user2 == null) return;

            var post1 = new Post
            {
                Content = "Just visited the Pyramids and they were absolutely magnificent! ☀️🐫 #Egypt #Travel",
                UserID = user1.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                Media = new List<PostMedia> {
                    new PostMedia { MediaURL = "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368", MediaType = "Image" }
                }
            };

            var post2 = new Post
            {
                Content = "I've planned out my entire itinerary for Luxor next week using Kemora's AI Planner! Who has recommendations?",
                UserID = user2.Id,
                CreatedAt = DateTime.UtcNow.AddHours(-12)
            };

            context.Posts.AddRange(new[] { post1, post2 });
            await context.SaveChangesAsync();
            
            var comment1 = new Comment
            {
                PostID = post1.PostID,
                UserID = user2.Id,
                Content = "Amazing photo! Did you take a camel ride?",
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            };

            context.Comments.Add(comment1);
            await context.SaveChangesAsync();
        }

        private static async Task SeedBadgesAsync(ApplicationDbContext context)
        {
            if (await context.Badges.AnyAsync()) return;

            var badges = new List<Badge>
            {
                new() { Name = "First Steps", Description = "Complete your profile and join the community!", Criteria = "Profile Completion", PointsReward = 50, IconUrl = "👣" },
                new() { Name = "Explorer", Description = "Visit and review 5 different places.", Criteria = "5 Place Reviews", PointsReward = 100, IconUrl = "🧭" },
                new() { Name = "Adventurer", Description = "Visit 10 different places across Egypt.", Criteria = "10 Places Visited", PointsReward = 200, IconUrl = "⛰️" },
                new() { Name = "Pharaoh's Path", Description = "Visit 3 different historical sites.", Criteria = "3 Historical Sites", PointsReward = 150, IconUrl = "🏛️" },
                new() { Name = "Beach Lover", Description = "Visit 3 different beach destinations.", Criteria = "3 Beach Visits", PointsReward = 150, IconUrl = "🏖️" },
                new() { Name = "Social Butterfly", Description = "Create 5 social posts for your followers.", Criteria = "5 Social Posts", PointsReward = 100, IconUrl = "🦋" },
                new() { Name = "Navigator", Description = "Plan 3 successful trips using the AI Planner.", Criteria = "3 AI Trips", PointsReward = 150, IconUrl = "🗺️" },
                new() { Name = "Foodie", Description = "Visit and review 5 different restaurants.", Criteria = "5 Restaurant Reviews", PointsReward = 100, IconUrl = "🍽️" },
                new() { Name = "Egypt Master", Description = "Visit a place in all 27 governorates.", Criteria = "27 Governorates", PointsReward = 500, IconUrl = "👑" },
                new() { Name = "Globe Trotter", Description = "Complete 10 total trip itineraries.", Criteria = "10 Itineraries", PointsReward = 300, IconUrl = "🌍" }
            };

            context.Badges.AddRange(badges);
            await context.SaveChangesAsync();
        }

        private static async Task AwardInitialBadgesAsync(ApplicationDbContext context)
        {
            var firstStepsBadge = await context.Badges.FirstOrDefaultAsync(b => b.Name == "First Steps");
            if (firstStepsBadge == null) return;

            var users = await context.Users.ToListAsync();
            foreach (var user in users)
            {
                var alreadyHas = await context.UserBadges.AnyAsync(ub => ub.UserID == user.Id && ub.BadgeID == firstStepsBadge.BadgeID);
                if (!alreadyHas)
                {
                    context.UserBadges.Add(new UserBadge { UserID = user.Id, BadgeID = firstStepsBadge.BadgeID, EarnedAt = DateTime.UtcNow });
                }
            }
            await context.SaveChangesAsync();
        }
        private static int religiousType_OrDefault(ApplicationDbContext context, string type)
        {
            return context.PlaceTypes.Where(pt => pt.GoogleType == type).Select(pt => pt.TypeID).FirstOrDefault();
        }
    }
}
