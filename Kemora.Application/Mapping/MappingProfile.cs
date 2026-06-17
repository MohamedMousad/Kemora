using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using System.Linq;

namespace Kemora.Application.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<ApplicationUser, AuthResponseDto>()
                .ForMember(d => d.UserId, o => o.MapFrom(s => s.Id));
            CreateMap<ApplicationUser, ProfileDto>()
                .ForMember(d => d.Id, o => o.MapFrom(s => s.Id));
            CreateMap<ApplicationUser, PublicProfileDto>()
                .ForMember(d => d.UserId, o => o.MapFrom(s => s.Id));

            // Gamification
            CreateMap<Badge, BadgeResponseDto>();
            CreateMap<UserBadge, UserBadgeResponseDto>()
                .ForMember(d => d.BadgeName, o => o.MapFrom(s => s.Badge.Name))
                .ForMember(d => d.BadgeDescription, o => o.MapFrom(s => s.Badge.Description))
                .ForMember(d => d.IconUrl, o => o.MapFrom(s => s.Badge.IconUrl))
                .ForMember(d => d.Criteria, o => o.MapFrom(s => s.Badge.Criteria))
                .ForMember(d => d.PointsReward, o => o.MapFrom(s => s.Badge.PointsReward));
            CreateMap<UserPoint, PointHistoryDto>()
                .ForMember(d => d.SourcePlaceName, o => o.MapFrom(s => s.SourcePlace.Name));
            CreateMap<ApplicationUser, LeaderboardEntryDto>()
                .ForMember(d => d.UserId, o => o.MapFrom(s => s.Id))
                .ForMember(d => d.Rank, o => o.Ignore());
            
            // Favorites
            CreateMap<UserFavorite, FavoriteResponseDto>()
                .ForMember(d => d.PlaceName, o => o.MapFrom(s => s.Place.Name))
                .ForMember(d => d.PlaceAddress, o => o.MapFrom(s => s.Place.Address))
                .ForMember(d => d.MainImageURL, o => o.MapFrom(s => s.Place.MainImageURL));

            // Trips
            CreateMap<TripPlace, TripPlaceResponseDto>()
                .ForMember(d => d.PlaceName, o => o.MapFrom(s => s.Place.Name));
            CreateMap<Trip, TripListDto>()
                .ForMember(d => d.PlaceCount, o => o.MapFrom(s => s.TripPlaces.Count));
            CreateMap<Trip, TripDetailDto>()
                .ForMember(d => d.Places, o => o.MapFrom(s => s.TripPlaces.OrderBy(tp => tp.VisitDate)));

            // Social/Posts
            CreateMap<PostMedia, PostMediaResponseDto>();
            CreateMap<CommentMedia, CommentMediaResponseDto>();

            CreateMap<Post, PostListResponseDto>()
                .ForMember(d => d.AuthorId, o => o.MapFrom(s => s.UserID))
                .ForMember(d => d.AuthorName, o => o.MapFrom(s => s.User.FullName))
                .ForMember(d => d.AuthorProfilePicture, o => o.MapFrom(s => s.User.ProfilePictureUrl))
                .ForMember(d => d.ReactionCount, o => o.MapFrom(s => s.Reactions.Count))
                .ForMember(d => d.CommentCount, o => o.MapFrom(s => s.Comments.Count))
                .ForMember(d => d.IsLikedByMe, o => o.Ignore())
                .ForMember(d => d.LocationName, o => o.MapFrom(s => s.Location != null ? s.Location.Name : null));
            
            CreateMap<Post, PostDetailResponseDto>()
                .ForMember(d => d.AuthorId, o => o.MapFrom(s => s.UserID))
                .ForMember(d => d.AuthorName, o => o.MapFrom(s => s.User.FullName))
                .ForMember(d => d.AuthorProfilePicture, o => o.MapFrom(s => s.User.ProfilePictureUrl))
                .ForMember(d => d.ReactionCount, o => o.MapFrom(s => s.Reactions.Count))
                .ForMember(d => d.CommentCount, o => o.MapFrom(s => s.Comments.Count))
                .ForMember(d => d.IsLikedByMe, o => o.Ignore())
                .ForMember(d => d.LocationName, o => o.MapFrom(s => s.Location != null ? s.Location.Name : null))
                .ForMember(d => d.Comments, o => o.MapFrom(s => s.Comments.Where(c => c.ParentCommentId == null).OrderByDescending(c => c.CreatedAt)));

            CreateMap<Comment, CommentResponseDto>()
                .ForMember(d => d.AuthorId, o => o.MapFrom(s => s.UserID))
                .ForMember(d => d.AuthorName, o => o.MapFrom(s => s.User.FullName))
                .ForMember(d => d.AuthorProfilePicture, o => o.MapFrom(s => s.User.ProfilePictureUrl))
                .ForMember(d => d.Replies, o => o.MapFrom(s => s.Replies.OrderByDescending(r => r.CreatedAt)));

            // Reviews
            CreateMap<Review, ReviewResponseDto>();

            // Notifications
            CreateMap<Notification, NotificationDto>();

            // Photos
            CreateMap<Photo, PhotoResponseDto>();

            // Messages
            CreateMap<Message, MessageDto>()
                .ForMember(d => d.SenderName, o => o.MapFrom(s => s.Sender.FullName))
                .ForMember(d => d.SenderProfilePicture, o => o.MapFrom(s => s.Sender.ProfilePictureUrl))
                .ForMember(d => d.ReceiverName, o => o.MapFrom(s => s.Receiver.FullName))
                .ForMember(d => d.ReceiverProfilePicture, o => o.MapFrom(s => s.Receiver.ProfilePictureUrl));

            // Events
            CreateMap<Event, EventResponseDto>();

            // Places / Management
            CreateMap<Governorate, GovernorateDto>();
            CreateMap<Category, CategoryDto>();
            CreateMap<PlaceType, PlaceTypeDto>()
                .ForMember(d => d.CategoryName, o => o.MapFrom(s => s.Category.Name));
            
            CreateMap<Place, PlaceAdminDto>()
                .ForMember(d => d.GovernorateName, o => o.MapFrom(s => s.Governorate.Name))
                .ForMember(d => d.PlaceTypeName, o => o.MapFrom(s => string.IsNullOrEmpty(s.PlaceType.DisplayName) ? s.PlaceType.Category.Name : s.PlaceType.DisplayName));
            CreateMap<Place, PlacePublicDto>()
                .ForMember(d => d.PlaceTypeName, o => o.MapFrom(s => string.IsNullOrEmpty(s.PlaceType.DisplayName) ? s.PlaceType.Category.Name : s.PlaceType.DisplayName));
            CreateMap<Place, PlaceDetailPublicDto>()
                .ForMember(d => d.PlaceTypeName, o => o.MapFrom(s => string.IsNullOrEmpty(s.PlaceType.DisplayName) ? s.PlaceType.Category.Name : s.PlaceType.DisplayName));
        }
    }
}
