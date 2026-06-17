import '../../domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.rating,
    super.type,
    super.address,
    super.governorateName,
    super.mainImageUrl,
    super.priceLevel,
    super.website,
    super.reviews,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    // Parse reviews if present
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawReviews
        .map((r) => ReviewSummary(
              authorName: r['authorName'] as String? ?? r['author_name'] as String? ?? 'Anonymous',
              text: r['text'] as String? ?? '',
              rating: (r['rating'] as num?)?.toInt() ?? 5,
            ))
        .toList();

    final mainImageUrl = json['mainImageURL'] as String? ?? json['mainImageUrl'] as String?;

    return PlaceModel(
      id: json['placeID']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Place',
      description: json['description'] as String? ?? 'No description available.',
      category: json['placeTypeName'] as String? ?? json['type'] as String? ?? 'Uncategorized',
      imageUrl: mainImageUrl ?? 'https://picsum.photos/400/300',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      type: json['placeTypeName'] as String? ?? json['type'] as String?,
      address: json['address'] as String?,
      governorateName: json['governorateName'] as String?,
      mainImageUrl: mainImageUrl,
      priceLevel: (json['priceLevel'] as num?)?.toInt(),
      website: json['website'] as String?,
      reviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
    };
  }
}

class GovernorateModel extends Governorate {
  const GovernorateModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.region,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: json['governorateID']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Governorate',
      imageUrl: json['imageURL'] as String?,
      region: json['region'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'region': region,
    };
  }
}
