class PlaceInfo {
  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final int reviewsCount;
  final String price;
  final String distance;
  final String description;
  final String governorateId;
  final List<String> tags;
  final String? imageAsset;

  const PlaceInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.distance,
    required this.description,
    required this.governorateId,
    this.tags = const [],
    this.imageAsset,
  });
}

final List<PlaceInfo> placesData = [];
