using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Trip planning: create trips, manage itinerary places, update, and delete.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class TripsController : ControllerBase
    {
        private readonly ITripService _tripService;
        private readonly IBadgeAwardService _badgeAwardService;

        public TripsController(ITripService tripService, IBadgeAwardService badgeAwardService)
        {
            _tripService = tripService;
            _badgeAwardService = badgeAwardService;
        }

        private string UserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        /// <summary>
        /// Create a new trip.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(TripDetailDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TripDetailDto>> Create([FromBody] CreateTripDto dto)
        {
            if (dto.EndDate <= dto.StartDate) return BadRequest("EndDate must be after StartDate.");

            var t = await _tripService.CreateAsync(UserId(), dto);
            return CreatedAtAction(nameof(Get), new { id = t.TripID }, t);
        }

        /// <summary>
        /// List the authenticated user's trips with pagination.
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(PagedResult<TripListDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<PagedResult<TripListDto>>> List([FromQuery] int page = 1, [FromQuery] int ps = 20)
        {
            return Ok(await _tripService.ListAsync(UserId(), page, ps));
        }

        /// <summary>
        /// Get a specific trip with its places.
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(TripDetailDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<TripDetailDto>> Get(int id)
        {
            var t = await _tripService.GetAsync(UserId(), id);
            if (t == null) return NotFound();
            return Ok(t);
        }

        /// <summary>
        /// Update a trip's details.
        /// </summary>
        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateTripDto dto)
        {
            if (dto.EndDate <= dto.StartDate) return BadRequest("EndDate must be after StartDate.");
            if (await _tripService.UpdateAsync(UserId(), id, dto)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Delete a trip.
        /// </summary>
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Delete(int id)
        {
            if (await _tripService.DeleteAsync(UserId(), id)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Add a place to a trip's itinerary.
        /// </summary>
        [HttpPost("{id}/places")]
        [ProducesResponseType(typeof(TripPlaceResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TripPlaceResponseDto>> AddPlace(int id, [FromBody] AddTripPlaceDto dto)
        {
            var p = await _tripService.AddPlaceAsync(UserId(), id, dto);
            if (p == null) return BadRequest("Trip or Place not found.");
            return Ok(p);
        }

        /// <summary>
        /// Update a place's order or notes in the trip itinerary.
        /// </summary>
        [HttpPut("{tripId}/places/{tpId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdatePlace(int tripId, int tpId, [FromBody] UpdateTripPlaceDto dto)
        {
            if (await _tripService.UpdatePlaceAsync(UserId(), tripId, tpId, dto)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Remove a place from the trip itinerary.
        /// </summary>
        [HttpDelete("{tripId}/places/{tpId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> RemovePlace(int tripId, int tpId)
        {
            if (await _tripService.RemovePlaceAsync(UserId(), tripId, tpId)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Save a complete AI-generated trip plan.
        /// </summary>
        [HttpPost("save-plan")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(TripDetailDto), StatusCodes.Status201Created)]
        public async Task<ActionResult<TripDetailDto>> SavePlan([FromBody] SaveAIPlanDto dto)
        {
            // Support both authenticated and guest users
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "guest";
            var t = await _tripService.SaveAIPlanAsync(userId, dto);
            // Award achievement badges non-blockingly
            _ = _badgeAwardService.TryAwardAiPioneerAsync(userId);
            _ = _badgeAwardService.TryAwardCityHopperAsync(userId);
            return CreatedAtAction(nameof(Get), new { id = t.TripID }, t);
        }
    }
}
