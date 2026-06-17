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
            await SeedAdminRolesAsync(userManager);
            await SeedBadgesAsync(context);
            await SeedPlacesAsync(context);

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

            // Seed the admin developer account
            const string adminEmail = "zyadkhaled151@gmail.com";
            const string adminPassword = "123456789@Zz";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null)
            {
                System.Console.WriteLine("SEED: Creating admin user zyadkhaled151@gmail.com...");
                adminUser = new ApplicationUser
                {
                    UserName = "zyad_admin",
                    Email = adminEmail,
                    FullName = "Zyad Khaled",
                    Country = "Egypt",
                    EmailConfirmed = true,
                };
                await userManager.CreateAsync(adminUser, adminPassword);
            }
        }

        private static async Task SeedAdminRolesAsync(UserManager<ApplicationUser> userManager)
        {
            const string adminEmail = "zyadkhaled151@gmail.com";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null) return;

            var roles = await userManager.GetRolesAsync(adminUser);
            if (!roles.Contains("Admin"))
            {
                System.Console.WriteLine("SEED: Assigning Admin role to zyadkhaled151@gmail.com...");
                await userManager.AddToRoleAsync(adminUser, "Admin");
            }
        }

        private static async Task SeedPlacesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Places...");
            if (await context.Places.AnyAsync()) {
                System.Console.WriteLine("SEED: Places already exist. Skipping.");
                return;
            }

            var templeType   = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "temple");
            var pyramidType  = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "pyramid");
            var museumType   = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "museum");
            var marketType   = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "market");
            var hotelType    = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "hotel");
            var beachType    = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "beach_resort");
            var parkType     = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "national_park");
            var oasisType    = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "oasis");
            var citadelType  = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "citadel");
            var restaurantType = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "restaurant");
            var divingType   = await context.PlaceTypes.FirstOrDefaultAsync(t => t.GoogleType == "diving_spot");

            var govs = await context.Governorates.ToDictionaryAsync(g => g.Name, g => g.GovernorateID);

            int? GovId(string name) => govs.TryGetValue(name, out var id) ? id : null;

            var places = new List<Place>
            {
                // ── CAIRO ──────────────────────────────────────────────────────────
                new() {
                    Name = "Egyptian Museum", Description = "Home to the world's largest collection of ancient Egyptian antiquities — over 120,000 items including Tutankhamun's treasures.",
                    Address = "Tahrir Square, Cairo", Latitude = 30.0476m, Longitude = 31.2336m,
                    Website = "https://maps.app.goo.gl/Rb3xd3bPuDzZqBJJ6", Rating = 4.7m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Cairo"), PlaceTypeID = museumType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Ahmed Hassan", Rating = 5, Text = "Absolutely mind-blowing collection. Tutankhamun's mask alone is worth the trip." },
                        new() { AuthorName = "Sophie Miller", Rating = 4, Text = "Incredible history, but the building itself is quite old. Worth visiting before the Grand Museum opens fully." },
                        new() { AuthorName = "Omar Farouq", Rating = 5, Text = "You need at least 4 hours here. Every single room is full of wonders." }
                    }
                },
                new() {
                    Name = "Khan el-Khalili", Description = "Cairo's most famous bazaar in the heart of Islamic Cairo, dating back to 1382. Shop for spices, gold, textiles and souvenirs.",
                    Address = "El-Hussein Square, Al-Azhar, Cairo", Latitude = 30.0477m, Longitude = 31.2623m,
                    Website = "https://maps.app.goo.gl/6pUZq7jzSrZWRPBh7", Rating = 4.6m, PriceLevel = 1,
                    MainImageURL = "https://images.unsplash.com/photo-1553913861-c0fddf2619ee?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Cairo"), PlaceTypeID = marketType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Layla Nasser", Rating = 5, Text = "The atmosphere at night is magical. The tea at El Fishawi cafe is a must." },
                        new() { AuthorName = "Carlos Ruiz", Rating = 4, Text = "Vibrant and chaotic in the best way. Bargaining is expected — don't pay the first price." },
                        new() { AuthorName = "Yasmine Ali", Rating = 5, Text = "The spice market lane is incredible. Perfect souvenirs for everyone." }
                    }
                },
                new() {
                    Name = "Cairo Tower", Description = "A 187-metre concrete tower on Gezira Island offering panoramic 360° views of Cairo and the Nile.",
                    Address = "Gezira Island, Cairo", Latitude = 30.0459m, Longitude = 31.2242m,
                    Website = "https://maps.app.goo.gl/VE3oujk9Bj3bTHVCA", Rating = 4.5m, PriceLevel = 1,
                    MainImageURL = "https://images.unsplash.com/photo-1572252009286-268acec5ca0a?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Cairo"), PlaceTypeID = museumType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Fatima Saad", Rating = 5, Text = "Stunning sunset views of Cairo from the top. The revolving restaurant is great." },
                        new() { AuthorName = "James White", Rating = 4, Text = "Great panorama. Best at golden hour. Queue can be long on weekends." }
                    }
                },
                new() {
                    Name = "Al-Azhar Park", Description = "A beautiful 30-hectare park on a reclaimed hilltop offering lush gardens and panoramic views of Islamic Cairo.",
                    Address = "Salah Salem St, Cairo", Latitude = 30.0456m, Longitude = 31.2686m,
                    Website = "https://maps.app.goo.gl/kNBMGpqXAJxiJKXR7", Rating = 4.7m, PriceLevel = 0,
                    MainImageURL = "https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Cairo"), PlaceTypeID = parkType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Rania Mostafa", Rating = 5, Text = "The best escape from Cairo's chaos. The views of the minarets are gorgeous." },
                        new() { AuthorName = "Khalid Ibrahim", Rating = 5, Text = "Beautifully maintained with a great cafe. Visit in spring for perfect weather." }
                    }
                },

                // ── GIZA ───────────────────────────────────────────────────────────
                new() {
                    Name = "Great Pyramid of Giza", Description = "The last of the Seven Wonders of the Ancient World. Built for Pharaoh Khufu around 2560 BC, it stands 138 metres tall.",
                    Address = "Al Haram, Giza", Latitude = 29.9792m, Longitude = 31.1342m,
                    Website = "https://maps.app.goo.gl/iWBK9B6ZaJcKUgLx5", Rating = 4.9m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Giza"), PlaceTypeID = pyramidType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Sara Mahmoud", Rating = 5, Text = "Words cannot describe standing at the base of this structure. Truly humbling." },
                        new() { AuthorName = "Thomas Brown", Rating = 5, Text = "A bucket list experience. Arrive very early to avoid the crowds and heat." },
                        new() { AuthorName = "Nour Abdel", Rating = 5, Text = "The solar boat museum next to it is also fascinating. Don't miss it!" }
                    }
                },
                new() {
                    Name = "Great Sphinx of Giza", Description = "A limestone statue of a reclining sphinx with a human head, guarding the pyramids. It's the largest monolith statue in the world.",
                    Address = "Nazlet El-Semman, Al Haram, Giza", Latitude = 29.9753m, Longitude = 31.1376m,
                    Website = "https://maps.app.goo.gl/RoMpFCspmLuFhPXaA", Rating = 4.8m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1539768942893-daf525e3b71b?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Giza"), PlaceTypeID = pyramidType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Monica Costa", Rating = 5, Text = "Even more impressive in person. The restoration work is interesting to see." },
                        new() { AuthorName = "Ali Karim", Rating = 4, Text = "Viewing area is restricted — you can't get too close but the sight is still incredible." }
                    }
                },
                new() {
                    Name = "Marriott Mena House", Description = "Historic 5-star luxury hotel built in 1869 at the foot of the Pyramids, with direct views of Khufu's pyramid from its rooms and pool.",
                    Address = "6 Pyramids Rd, Giza", Latitude = 29.9866m, Longitude = 31.1283m,
                    Website = "https://maps.app.goo.gl/hPQGW8XTLkexLt3eA", Rating = 4.7m, PriceLevel = 4,
                    MainImageURL = "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Giza"), PlaceTypeID = hotelType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Elena Fischer", Rating = 5, Text = "Waking up to Pyramid views is an unmatched experience. The pool area is beautiful." },
                        new() { AuthorName = "Karim Waheed", Rating = 5, Text = "Historic, luxurious and the best location in Giza. Worth every penny." }
                    }
                },

                // ── LUXOR ──────────────────────────────────────────────────────────
                new() {
                    Name = "Karnak Temple", Description = "The largest ancient religious site in the world — a vast complex of temples, chapels and pylons dedicated to Amun, Mut and Khonsu.",
                    Address = "Karnak, Luxor", Latitude = 25.7188m, Longitude = 32.6573m,
                    Website = "https://maps.app.goo.gl/8eJ3r7bV6mNTcnFD7", Rating = 4.9m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1594916301297-a7eb443a9926?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Luxor"), PlaceTypeID = templeType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Pierre Dupont", Rating = 5, Text = "The Avenue of Sphinxes alone makes this worth visiting. Staggering scale." },
                        new() { AuthorName = "Hend Salem", Rating = 5, Text = "Visit the sound and light show at night — a magical experience." },
                        new() { AuthorName = "Mark Johnson", Rating = 5, Text = "Bigger than you can imagine from photos. Give yourself at least 3 hours." }
                    }
                },
                new() {
                    Name = "Luxor Temple", Description = "A large ancient Egyptian temple complex on the east bank of the Nile, built mainly by Amenhotep III and Ramesses II.",
                    Address = "Al-Karnak, Luxor City", Latitude = 25.6994m, Longitude = 32.6392m,
                    Website = "https://maps.app.goo.gl/mZQR97wE3GaXBj1HA", Rating = 4.8m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1571843439991-dd2b8e051966?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Luxor"), PlaceTypeID = templeType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Amina Youssef", Rating = 5, Text = "Night visit is absolutely breathtaking with illuminations. Don't miss it." },
                        new() { AuthorName = "Roberto Mancini", Rating = 4, Text = "Stunning temple right on the Nile. The colossi of Ramesses II are incredible." }
                    }
                },
                new() {
                    Name = "Valley of the Kings", Description = "The burial ground for pharaohs of the New Kingdom (1539–1075 BC), containing over 60 elaborately decorated tombs.",
                    Address = "West Bank, Luxor", Latitude = 25.7403m, Longitude = 32.6014m,
                    Website = "https://maps.app.goo.gl/oHpRQXU4CL2PH3w46", Rating = 4.9m, PriceLevel = 3,
                    MainImageURL = "https://images.unsplash.com/photo-1563292769-0c69c07af2de?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Luxor"), PlaceTypeID = templeType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Nadia Khalil", Rating = 5, Text = "Tutankhamun's tomb is smaller than expected but still awe-inspiring. Seti I's tomb has the best paintings." },
                        new() { AuthorName = "David Clarke", Rating = 5, Text = "The colours on the tomb walls after 3000 years are still vivid. Unreal." },
                        new() { AuthorName = "Sarah Petrov", Rating = 4, Text = "Go early to beat the heat and crowds. The audio guide is very informative." }
                    }
                },
                new() {
                    Name = "Sofra Restaurant", Description = "A beautifully restored 1930s traditional Egyptian home serving authentic Upper Egyptian cuisine with a stunning courtyard ambiance.",
                    Address = "90 Mohammed Farid St, Luxor", Latitude = 25.7003m, Longitude = 32.6420m,
                    Website = "https://maps.app.goo.gl/HnXm1E7GsqK9XMKZ8", Rating = 4.6m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Luxor"), PlaceTypeID = restaurantType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Hannah Smith", Rating = 5, Text = "Best meal of our entire Egypt trip. The kofta and stuffed pigeon are extraordinary." },
                        new() { AuthorName = "Tariq Elmasry", Rating = 5, Text = "The rooftop terrace has views of the Nile. A perfect dinner setting." }
                    }
                },

                // ── ASWAN ──────────────────────────────────────────────────────────
                new() {
                    Name = "Philae Temple", Description = "A stunning ancient Egyptian temple complex relocated to Agilkia Island after the construction of the Aswan Dam. Dedicated to the goddess Isis.",
                    Address = "Agilkia Island, Aswan", Latitude = 24.0276m, Longitude = 32.8839m,
                    Website = "https://maps.app.goo.gl/kFN8SWDJqWrJn3TS6", Rating = 4.8m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1610486828590-edc9372e617d?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Aswan"), PlaceTypeID = templeType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Lena Schmidt", Rating = 5, Text = "The boat ride to the island is part of the experience. The temple at sunset is magical." },
                        new() { AuthorName = "Youssef Badr", Rating = 5, Text = "Sound and light show at night is well worth doing. The reflections on the Nile are incredible." }
                    }
                },
                new() {
                    Name = "Abu Simbel Temples", Description = "Two massive rock-cut temples built by Ramesses II. They were relocated in the 1960s to save them from the rising Nile — a UNESCO engineering marvel.",
                    Address = "Abu Simbel, Aswan Governorate", Latitude = 22.3372m, Longitude = 31.6258m,
                    Website = "https://maps.app.goo.gl/cxUc1N3F9BVQFZ9u5", Rating = 4.9m, PriceLevel = 3,
                    MainImageURL = "https://images.unsplash.com/photo-1598256741842-a9cf6e51bf24?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Aswan"), PlaceTypeID = templeType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Claire Bonnet", Rating = 5, Text = "The most impressive ancient monument I've ever seen. The colossal Ramesses statues are breathtaking." },
                        new() { AuthorName = "Hassan Salam", Rating = 5, Text = "Worth the 3-hour drive from Aswan. Visit during the solar alignment event (Feb 22 / Oct 22) if you can." },
                        new() { AuthorName = "Stefan Novak", Rating = 5, Text = "The engineering feat of moving these temples is almost as impressive as their age." }
                    }
                },
                new() {
                    Name = "Old Cataract Hotel Aswan", Description = "A legendary 5-star resort built in 1899 on a granite outcrop overlooking the Nile — Agatha Christie wrote 'Death on the Nile' here.",
                    Address = "Abtal El Tahrir St, Aswan", Latitude = 24.0855m, Longitude = 32.8967m,
                    Website = "https://maps.app.goo.gl/R7Eq8rU6MgxdSH4U9", Rating = 4.9m, PriceLevel = 4,
                    MainImageURL = "https://images.unsplash.com/photo-1614089756453-a72a5b35e3f4?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Aswan"), PlaceTypeID = hotelType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Isabella Rossi", Rating = 5, Text = "The terrace over the Nile with Elephantine Island view is out of this world. Pure elegance." },
                        new() { AuthorName = "Fady Morcos", Rating = 5, Text = "History, luxury and the Nile all in one. The afternoon tea is a tradition you must try." }
                    }
                },

                // ── ALEXANDRIA ─────────────────────────────────────────────────────
                new() {
                    Name = "Qaitbay Citadel", Description = "A 15th-century fortress built on the exact site of the legendary Lighthouse of Alexandria, one of the Seven Wonders. Now a naval museum.",
                    Address = "Corniche Road, Alexandria", Latitude = 31.2138m, Longitude = 29.8854m,
                    Website = "https://maps.app.goo.gl/cJqMHJzWxPdaWZ4Q8", Rating = 4.7m, PriceLevel = 1,
                    MainImageURL = "https://images.unsplash.com/photo-1621251817478-f685c7bb74e6?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Alexandria"), PlaceTypeID = citadelType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "George Christodoulou", Rating = 5, Text = "The waves crashing against the base are dramatic. The sea views are spectacular." },
                        new() { AuthorName = "Menna Fouad", Rating = 4, Text = "Great location, stunning exterior. The naval museum inside is an added bonus." }
                    }
                },
                new() {
                    Name = "Bibliotheca Alexandrina", Description = "A major library and cultural center built to revive the spirit of the ancient Library of Alexandria, holding over 8 million books.",
                    Address = "Chatby, Alexandria", Latitude = 31.2089m, Longitude = 29.9090m,
                    Website = "https://maps.app.goo.gl/uy2cCWBqHWFJhgqn6", Rating = 4.8m, PriceLevel = 1,
                    MainImageURL = "https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Alexandria"), PlaceTypeID = museumType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Ana Lima", Rating = 5, Text = "The architecture is stunning and the planetarium inside is world-class." },
                        new() { AuthorName = "Dina Amer", Rating = 5, Text = "Five museums under one roof. The antiquities museum is particularly impressive." }
                    }
                },
                new() {
                    Name = "Stanley Bridge", Description = "An iconic suspension bridge in the Stanley district of Alexandria, popular for its Mediterranean sea views and vibrant promenade atmosphere.",
                    Address = "Stanley, Alexandria", Latitude = 31.2417m, Longitude = 29.9546m,
                    Website = "https://maps.app.goo.gl/dGDMhqGMzCqhwTLX6", Rating = 4.4m, PriceLevel = 0,
                    MainImageURL = "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Alexandria"), PlaceTypeID = parkType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Salma Tarek", Rating = 4, Text = "Perfect for an evening stroll. The seafood restaurants nearby are excellent." },
                        new() { AuthorName = "Miriam Zaki", Rating = 5, Text = "Beautiful at sunset. The Mediterranean breeze and views are refreshing." }
                    }
                },

                // ── RED SEA ────────────────────────────────────────────────────────
                new() {
                    Name = "Hurghada Marina", Description = "A vibrant waterfront complex in Hurghada with restaurants, cafés, boutiques and boat trips. The social hub of the Red Sea Riviera.",
                    Address = "Hurghada Marina, Red Sea", Latitude = 27.2164m, Longitude = 33.8327m,
                    Website = "https://maps.app.goo.gl/AkFZkmTwE8HhnHN48", Rating = 4.5m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1584025000781-9f935fcc2dbe?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Red Sea"), PlaceTypeID = beachType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Peter Hansen", Rating = 4, Text = "Great atmosphere at night with live music. Boat trips to the reef are superb." },
                        new() { AuthorName = "Noha Ismail", Rating = 5, Text = "The yacht club is beautiful. Restaurant options are varied and the food is fresh." }
                    }
                },
                new() {
                    Name = "Giftun Island", Description = "A protected national park island near Hurghada with pristine beaches and extraordinary coral reefs, ideal for snorkelling and diving.",
                    Address = "Giftun Island, Red Sea", Latitude = 27.1719m, Longitude = 33.9222m,
                    Website = "https://maps.app.goo.gl/kBB8mhF3JeLbmVbq8", Rating = 4.8m, PriceLevel = 2,
                    MainImageURL = "https://images.unsplash.com/photo-1583212292454-1fe6229603b7?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Red Sea"), PlaceTypeID = divingType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Julia Weber", Rating = 5, Text = "The clearest water I've ever snorkelled in. The coral is pristine and the fish life is incredible." },
                        new() { AuthorName = "Amr Samy", Rating = 5, Text = "Best day trip from Hurghada. The island has a Robinson Crusoe feel." }
                    }
                },

                // ── SOUTH SINAI ────────────────────────────────────────────────────
                new() {
                    Name = "Ras Mohammed National Park", Description = "Egypt's premier national park at the tip of the Sinai Peninsula, world-famous for its stunning coral walls, sharks and pristine marine life.",
                    Address = "Ras Mohammed, South Sinai", Latitude = 27.7397m, Longitude = 34.2416m,
                    Website = "https://maps.app.goo.gl/C3VUymP3U3m5Z9yC7", Rating = 4.9m, PriceLevel = 1,
                    MainImageURL = "https://images.unsplash.com/photo-1622350720516-ec7fdf41a100?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("South Sinai"), PlaceTypeID = divingType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Michael Scott", Rating = 5, Text = "The best diving in Egypt, possibly the world. The Shark Reef wall is extraordinary." },
                        new() { AuthorName = "Dalia Refaat", Rating = 5, Text = "Even just snorkelling here blows every other location out of the water (pun intended)." }
                    }
                },
                new() {
                    Name = "St. Catherine Monastery", Description = "One of the world's oldest working Christian monasteries, built at the foot of Mount Sinai in the 6th century. A UNESCO World Heritage Site.",
                    Address = "Saint Catherine, South Sinai", Latitude = 28.5560m, Longitude = 33.9760m,
                    Website = "https://maps.app.goo.gl/jSWYtVSf8bLRHzLm8", Rating = 4.8m, PriceLevel = 0,
                    MainImageURL = "https://images.unsplash.com/photo-1548786811-dd6e453ccca7?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("South Sinai"), PlaceTypeID = citadelType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Father Andreas", Rating = 5, Text = "A deeply moving spiritual place. The burning bush in the courtyard is humbling." },
                        new() { AuthorName = "Lars Eriksson", Rating = 5, Text = "Climb Mount Sinai for sunrise then visit the monastery. A perfect combination." }
                    }
                },

                // ── MATROUH ────────────────────────────────────────────────────────
                new() {
                    Name = "Siwa Oasis", Description = "An idyllic oasis city in the Western Desert, known for its ancient ruins, therapeutic salt lakes, and the Oracle Temple consulted by Alexander the Great.",
                    Address = "Siwa, Matrouh", Latitude = 29.2035m, Longitude = 25.5195m,
                    Website = "https://maps.app.goo.gl/xdBVaruivjKnFoqXA", Rating = 4.8m, PriceLevel = 1,
                    MainImageURL = "https://images.unsplash.com/photo-1616790809516-92895f11181f?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Matrouh"), PlaceTypeID = oasisType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Emma van Dijk", Rating = 5, Text = "One of the most special places I've been. The stargazing here is beyond anything I've experienced." },
                        new() { AuthorName = "Bassem Nabil", Rating = 5, Text = "Floated in the salt lake at sunset — pure bliss. The eco-lodges are charming." }
                    }
                },

                // ── FAYOUM ────────────────────────────────────────────────────────
                new() {
                    Name = "Wadi El Rayan", Description = "A nature reserve containing Egypt's only naturally occurring waterfalls and a chain of beautiful desert lakes. A popular day trip from Cairo.",
                    Address = "Faiyum Governorate", Latitude = 29.2022m, Longitude = 30.3506m,
                    Website = "https://maps.app.goo.gl/b8NMQ5KxrPLMGpYy9", Rating = 4.7m, PriceLevel = 0,
                    MainImageURL = "https://images.unsplash.com/photo-1601058268499-e52658b8ebf8?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("Fayoum"), PlaceTypeID = parkType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Shereen Hamed", Rating = 5, Text = "The waterfall between the two lakes is truly unique in Egypt. Perfect picnic spot." },
                        new() { AuthorName = "Michael Liu", Rating = 4, Text = "Incredible combination of desert and water. The sand dunes near the lake are surreal." }
                    }
                },

                // ── NEW VALLEY ────────────────────────────────────────────────────
                new() {
                    Name = "White Desert National Park", Description = "A stunning national park in Egypt's Western Desert with surreal white chalk rock formations shaped by wind erosion over millennia.",
                    Address = "Farafra, New Valley", Latitude = 27.2819m, Longitude = 27.9928m,
                    Website = "https://maps.app.goo.gl/dShsmD86ceFmU99cA", Rating = 4.9m, PriceLevel = 0,
                    MainImageURL = "https://images.unsplash.com/photo-1539768942893-daf525e3b71b?auto=format&fit=crop&w=1200",
                    GovernorateID = GovId("New Valley"), PlaceTypeID = parkType?.TypeID, Source = "seed",
                    Reviews = new List<Review> {
                        new() { AuthorName = "Ingrid Strand", Rating = 5, Text = "Like camping on the moon. The chalk formations by moonlight are ethereal." },
                        new() { AuthorName = "Karim Bassiony", Rating = 5, Text = "The most otherworldly landscape in Egypt. Camping here overnight is unforgettable." }
                    }
                },
            };

            context.Places.AddRange(places);
            await context.SaveChangesAsync();
            System.Console.WriteLine($"SEED: Seeded {places.Count} places.");
        }

        private static async Task SeedSocialPostsAsync(ApplicationDbContext context)
        {
            if (await context.Posts.AnyAsync()) return;

            var user1 = await context.Users.FirstOrDefaultAsync(u => u.UserName == "john_doe");
            var user2 = await context.Users.FirstOrDefaultAsync(u => u.UserName == "sarah_smith");
            if (user1 == null || user2 == null) return;

            // Attach to real places
            var pyramidPlace = await context.Places.FirstOrDefaultAsync(p => p.Name.Contains("Great Pyramid"));
            var luxorPlace   = await context.Places.FirstOrDefaultAsync(p => p.Name.Contains("Luxor Temple"));

            var post1 = new Post
            {
                Content = "Just visited the Pyramids and they were absolutely magnificent! ☀️🐫 #Egypt #Travel",
                UserID = user1.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                LocationId = pyramidPlace?.PlaceID,
                Media = new List<PostMedia> {
                    new PostMedia { MediaURL = "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368", MediaType = "Image" }
                }
            };

            var post2 = new Post
            {
                Content = "I've planned out my entire itinerary for Luxor next week using Kemora's AI Planner! The temples are calling. Who has recommendations? 🏛️",
                UserID = user2.Id,
                CreatedAt = DateTime.UtcNow.AddHours(-12),
                LocationId = luxorPlace?.PlaceID,
            };

            var post3 = new Post
            {
                Content = "Siwa Oasis is completely off the beaten path but absolutely magical. The salt lake at sunset is a dream. 🌅✨ #Siwa #Egypt",
                UserID = user1.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-5),
                Media = new List<PostMedia> {
                    new PostMedia { MediaURL = "https://images.unsplash.com/photo-1616790809516-92895f11181f", MediaType = "Image" }
                }
            };

            context.Posts.AddRange(new[] { post1, post2, post3 });
            await context.SaveChangesAsync();
            
            var comment1 = new Comment
            {
                PostID = post1.PostID,
                UserID = user2.Id,
                Content = "Amazing photo! Did you take a camel ride? 🐫",
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            };

            var comment2 = new Comment
            {
                PostID = post2.PostID,
                UserID = user1.Id,
                Content = "Go to the Valley of the Kings first thing in the morning before the tour buses arrive!",
                CreatedAt = DateTime.UtcNow.AddHours(-8)
            };

            context.Comments.AddRange(comment1, comment2);
            await context.SaveChangesAsync();
        }

        private static async Task SeedBadgesAsync(ApplicationDbContext context)
        {
            if (await context.Badges.AnyAsync()) return;

            var badges = new List<Badge>
            {
                // Existing badges
                new() { Name = "First Steps", Description = "Complete your profile and join the Kemora community!", Criteria = "Profile Completion", PointsReward = 50, IconUrl = "👣" },
                new() { Name = "Explorer", Description = "Visit and review 5 different places across Egypt.", Criteria = "5 Place Reviews", PointsReward = 100, IconUrl = "🧭" },
                new() { Name = "Adventurer", Description = "Visit 10 different places across Egypt.", Criteria = "10 Places Visited", PointsReward = 200, IconUrl = "⛰️" },
                new() { Name = "Pharaoh's Path", Description = "Visit 3 different historical sites.", Criteria = "3 Historical Sites", PointsReward = 150, IconUrl = "🏛️" },
                new() { Name = "Beach Lover", Description = "Visit 3 different beach destinations.", Criteria = "3 Beach Visits", PointsReward = 150, IconUrl = "🏖️" },
                new() { Name = "Social Butterfly", Description = "Create 5 social posts for your followers.", Criteria = "5 Social Posts", PointsReward = 100, IconUrl = "🦋" },
                new() { Name = "Navigator", Description = "Plan 3 successful trips using the AI Planner.", Criteria = "3 AI Trips", PointsReward = 150, IconUrl = "🗺️" },
                new() { Name = "Foodie", Description = "Visit and review 5 different restaurants.", Criteria = "5 Restaurant Reviews", PointsReward = 100, IconUrl = "🍽️" },
                new() { Name = "Egypt Master", Description = "Visit a place in all 27 governorates of Egypt.", Criteria = "27 Governorates", PointsReward = 500, IconUrl = "👑" },
                new() { Name = "Globe Trotter", Description = "Complete 10 total trip itineraries.", Criteria = "10 Itineraries", PointsReward = 300, IconUrl = "🌍" },
                // New achievement-based badges
                new() { Name = "Community Starter", Description = "Share your first post with the Kemora community.", Criteria = "First Post", PointsReward = 75, IconUrl = "📸" },
                new() { Name = "AI Pioneer", Description = "Generate and save your first AI-planned trip.", Criteria = "First AI Trip", PointsReward = 100, IconUrl = "🤖" },
                new() { Name = "City Hopper", Description = "Save trips visiting places in 5 different governorates.", Criteria = "5 Governorates in Trips", PointsReward = 200, IconUrl = "🏙️" },
                new() { Name = "Daily Devotee", Description = "Log in for 7 days in a row.", Criteria = "7-Day Login Streak", PointsReward = 125, IconUrl = "🔥" },
                new() { Name = "Cairo Explorer", Description = "Visit a place in Cairo governorate.", Criteria = "Visit Cairo", PointsReward = 50, IconUrl = "🌆" },
                new() { Name = "Luxor Legend", Description = "Visit a place in Luxor governorate.", Criteria = "Visit Luxor", PointsReward = 50, IconUrl = "🏺" },
                new() { Name = "Nile Wanderer", Description = "Visit places along the Nile in 3 different governorates.", Criteria = "3 Nile Governorates", PointsReward = 175, IconUrl = "🚢" },
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
