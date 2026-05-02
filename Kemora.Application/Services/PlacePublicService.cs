using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Domain.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Kemora.Application.Services
{
    public class PlacePublicService : IPlacePublicService
    {
        private readonly IPlaceRepository _placeRepo;
        private readonly IMapper _mapper;
        private readonly ICacheService _cacheService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IPlacesDataService _placesDataService;
        private readonly ISerpApiService _serpApiService;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<PlacePublicService> _logger;

        public PlacePublicService(
            IPlaceRepository placeRepo, 
            IMapper mapper, 
            ICacheService cacheService, 
            IUnitOfWork unitOfWork, 
            IPlacesDataService placesDataService, 
            ISerpApiService serpApiService,
            IServiceScopeFactory scopeFactory,
            ILogger<PlacePublicService> logger)
        {
            _placeRepo = placeRepo;
            _mapper = mapper;
            _cacheService = cacheService;
            _unitOfWork = unitOfWork;
            _placesDataService = placesDataService;
            _serpApiService = serpApiService;
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        public async Task<PagedResult<PlacePublicDto>> GetPlacesAsync(int? governorateId, int? categoryId, string? categoryName, string? searchQuery, int page, int pageSize)
        {
            var places = await _placeRepo.GetFilteredAsync(searchQuery, governorateId, categoryId, categoryName, page, pageSize);
            var count = await _placeRepo.GetFilteredCountAsync(searchQuery, governorateId, categoryId, categoryName);
            
            // If no places found for this page/query, or not enough to fill the page, 
            // trigger hydration to satisfy the requested page size.
            if (places.Count() < pageSize && governorateId.HasValue && string.IsNullOrEmpty(searchQuery))
            {
                int currentTotal = (int)count;
                int googlePage = (currentTotal / 20) + 1;
                
                _logger.LogInformation("[Hydration] DB has {Count} places. Filling page {Page} from API...", places.Count(), page);
                
                // For a better UX, we hydrate synchronously if the DB is very empty for this governorate
                // or in background if we already have some data.
                if (currentTotal < page * pageSize)
                {
                    await HydrateGovernoratePlacesAsync(governorateId.Value, categoryName, googlePage);
                    // Re-fetch after hydration to include new results
                    places = await _placeRepo.GetFilteredAsync(searchQuery, governorateId, categoryId, categoryName, page, pageSize);
                    count = await _placeRepo.GetFilteredCountAsync(searchQuery, governorateId, categoryId, categoryName);
                }
                else
                {
                    // Trigger background hydration for next pages
                    _ = Task.Run(async () => {
                        try 
                        {
                            using var scope = _scopeFactory.CreateScope();
                            var scopedService = scope.ServiceProvider.GetRequiredService<IPlacePublicService>();
                            var implementation = scopedService as PlacePublicService;
                            if (implementation != null)
                            {
                                await implementation.HydrateGovernoratePlacesAsync(governorateId.Value, categoryName, googlePage);
                            }
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "[BackgroundHydration] Error");
                        }
                    });
                }
            }

            await EnrichPlacesWithImagesAsync(places);
            return new PagedResult<PlacePublicDto>
            {
                Items = _mapper.Map<List<PlacePublicDto>>(places),
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<PlaceDetailPublicDto?> GetPlaceDetailAsync(int id)
        {
            var cacheKey = $"place_detail_{id}";
            var cached = _cacheService.Get<PlaceDetailPublicDto>(cacheKey);

            if (cached != null)
                return cached;

            var place = await _placeRepo.GetWithDetailsAsync(id);
            if (place == null) return null;

            await EnrichPlacesWithImagesAsync(new[] { place });

            var dto = _mapper.Map<PlaceDetailPublicDto>(place);
            var activeEvents = place.Events;
            dto.ActiveEvents = _mapper.Map<List<EventResponseDto>>(activeEvents);

            _cacheService.Set(cacheKey, dto, System.TimeSpan.FromMinutes(10));
            return dto;
        }

        public async Task<List<GovernorateDto>> GetGovernoratesAsync()
        {
            var cacheKey = "all_governorates";
            var cached = _cacheService.Get<List<GovernorateDto>>(cacheKey);
            if (cached != null) return cached;

            var governorates = await _unitOfWork.Repository<Governorate>().GetAllAsync();
            var dtos = _mapper.Map<List<GovernorateDto>>(governorates);

            _cacheService.Set(cacheKey, dtos, System.TimeSpan.FromHours(1));
            return dtos;
        }

        public async Task<List<PlacePublicDto>> GetTopPlacesAsync()
        {
            var cacheKey = "top_places";
            var cached = _cacheService.Get<List<PlacePublicDto>>(cacheKey);
            if (cached != null) return cached;

            var places = await _placeRepo.GetTopPlacesAsync(20);
            await EnrichPlacesWithImagesAsync(places);
            var dtos = _mapper.Map<List<PlacePublicDto>>(places);

            _cacheService.Set(cacheKey, dtos, System.TimeSpan.FromMinutes(30));
            return dtos;
        }

        public async Task HydrateGovernoratePlacesAsync(int governorateId, string? categoryName, int page)
        {
            try 
            {
                var governorate = await _unitOfWork.Repository<Governorate>().GetByIdAsync(governorateId);
                if (governorate == null || governorate.Latitude == 0) 
                {
                    _logger.LogWarning("[Hydration] Governorate {Id} not found or has no coordinates.", governorateId);
                    return;
                }

                _logger.LogInformation("[Hydration] Fetching places for {GovName} (Category: {Cat}, Page: {Page})", governorate.Name, categoryName ?? "Any", page);

                var categories = string.IsNullOrEmpty(categoryName) ? null : new[] { categoryName };
                // By requesting page * 20 limit, GooglePlacesService will use nextPageToken to fetch deeper results.
                var results = await _placesDataService.SearchPlacesByAreaAsync(
                    $"{governorate.Name}, Egypt", categories, 20, page,
                    (double)governorate.Latitude, (double)governorate.Longitude);
                
                _logger.LogInformation("[Hydration] Places API returned {Count} results.", results.Count);

                var existingPlaces = await _placeRepo.GetFilteredAsync(null, governorateId, null, null, 1, 1000);
                var existingIds = existingPlaces.Select(p => p.GoogleDataId).Where(id => id != null).ToHashSet();
                
                int newAddsCount = 0;
                
                foreach (var basicPlace in results.Where(r => !existingIds.Contains(r.ExternalId)).Take(20))
                {
                    if (string.IsNullOrEmpty(basicPlace.ExternalId)) continue;
                    
                    if (!string.IsNullOrEmpty(basicPlace.Name))
                    {
                        var newPlace = new Place
                        {
                            GoogleDataId = basicPlace.ExternalId,
                            Name = basicPlace.Name,
                            Description = basicPlace.Description,
                            Address = basicPlace.Address,
                            Latitude = (decimal)basicPlace.Latitude,
                            Longitude = (decimal)basicPlace.Longitude,
                            Rating = (decimal)(basicPlace.Rating ?? 0),
                            PriceLevel = int.TryParse(basicPlace.PriceLevel, out int pl) ? pl : 0,
                            MainImageURL = basicPlace.ImageUrl, 
                            Phone = basicPlace.Phone,
                            Website = basicPlace.Website,
                            GovernorateID = governorateId,
                            Source = basicPlace.Source,
                            LastEnrichedAt = System.DateTime.UtcNow
                        };
                        await _unitOfWork.Repository<Place>().AddAsync(newPlace);
                        existingIds.Add(basicPlace.ExternalId); 
                        newAddsCount++;
                    }
                }
                
                if (newAddsCount > 0)
                {
                    await _unitOfWork.CommitAsync();
                    _logger.LogInformation("[Hydration] Successfully added {Count} new places to {GovName}.", newAddsCount, governorate.Name);
                }
                else 
                {
                    _logger.LogInformation("[Hydration] No new unique places found to add.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Hydration] Error during hydration for governorate {Id}", governorateId);
            }
        }

        private async Task EnrichPlacesWithImagesAsync(IEnumerable<Place> places)
        {
            bool hasUpdates = false;
            foreach (var place in places)
            {
                // Clear stale mock IDs from old seeding — they don't work with SerpApi
                if (place.GoogleDataId != null && place.GoogleDataId.StartsWith("mock_"))
                {
                    place.GoogleDataId = null;
                    _unitOfWork.Repository<Place>().Update(place);
                    hasUpdates = true;
                }

                // Try to enrich via SerpApi first if rating is 0 or image is missing
                if (place.Rating == 0 || string.IsNullOrEmpty(place.MainImageURL) || place.MainImageURL.Contains("placeholder"))
                {
                    // If we haven't resolved the local DB to the true Google Maps ID yet
                    if (string.IsNullOrEmpty(place.GoogleDataId))
                    {
                        var match = await _serpApiService.SearchPlaceAsync(place.Name, (double)place.Latitude, (double)place.Longitude);
                        if (match != null && !string.IsNullOrEmpty(match.DataId))
                        {
                            place.GoogleDataId = match.DataId;
                            if (place.Rating == 0 && match.Rating.HasValue) place.Rating = (decimal)match.Rating.Value;
                            if (string.IsNullOrEmpty(place.Address) && !string.IsNullOrEmpty(match.Address)) place.Address = match.Address;
                            
                            // Immediately harvest the thumbnail if available
                            if (string.IsNullOrEmpty(place.MainImageURL) && !string.IsNullOrEmpty(match.Thumbnail))
                                place.MainImageURL = match.Thumbnail;

                            _unitOfWork.Repository<Place>().Update(place);
                            hasUpdates = true;
                        }
                    }

                    // Then upgrade to maximum quality Photos if we have a valid GoogleDataId
                    if (!string.IsNullOrEmpty(place.GoogleDataId) && (string.IsNullOrEmpty(place.MainImageURL) || place.MainImageURL.Contains("placeholder")))
                    {
                        var photos = await _serpApiService.GetPlacePhotosAsync(place.GoogleDataId, 1);
                        if (photos != null && photos.Count > 0)
                        {
                            place.MainImageURL = photos.First();
                            _unitOfWork.Repository<Place>().Update(place);
                            hasUpdates = true;
                        }
                    }
                }
            }
            if (hasUpdates)
            {
                await _unitOfWork.CommitAsync();
            }
        }
    }
}
