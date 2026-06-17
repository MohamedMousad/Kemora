import 'package:equatable/equatable.dart';

class ReviewSummary extends Equatable {
  final String authorName;
  final String text;
  final int rating;

  const ReviewSummary({
    required this.authorName,
    required this.text,
    required this.rating,
  });

  @override
  List<Object?> get props => [authorName, text, rating];
}

class Place extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double rating;

  // Extended fields from API
  final String? type;
  final String? address;
  final String? governorateName;
  final String? mainImageUrl;
  final int? priceLevel;
  final String? website;
  final List<ReviewSummary> reviews;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.type,
    this.address,
    this.governorateName,
    this.mainImageUrl,
    this.priceLevel,
    this.website,
    this.reviews = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        imageUrl,
        latitude,
        longitude,
        rating,
        type,
        address,
        governorateName,
        mainImageUrl,
        priceLevel,
        website,
        reviews,
      ];
}

class Governorate extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? region;

  const Governorate({
    required this.id,
    required this.name,
    this.imageUrl,
    this.region,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, region];
}
