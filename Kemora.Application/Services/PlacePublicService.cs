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

        public async Task<PagedResult<PlacePublicDto>> GetPlacesAsync(int? governorateId, int? categoryId, string? categoryName, string? searchQuery, string? sortBy, int page, int pageSize)
        {
            var places = await _placeRepo.GetFilteredAsync(searchQuery, governorateId, categoryId, categoryName, sortBy, page, pageSize);
            var count = await _placeRepo.GetFilteredCountAsync(searchQuery, governorateId, categoryId, categoryName);


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

                    if (!string.IsNullOrEmpty(place.Name) && (string.IsNullOrEmpty(place.MainImageURL) || place.MainImageURL.Contains("placeholder")))
                    {
                        var photos = await _serpApiService.GetPlacePhotosAsync("img_" + place.Name, 5);
                        if (photos != null && photos.Count > 0)
                        {
                            place.MainImageURL = photos.First();
                            if (photos.Count > 1) 
                            {
                                place.AdditionalPhotoUrlsJSON = System.Text.Json.JsonSerializer.Serialize(photos.Skip(1).ToList());
                            }
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
