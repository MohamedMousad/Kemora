import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.endDate,
    super.plannedPlaces,
  });

  // [KEMORA-MIGRATION] Fixed field names to match backend TripDetailDto / TripListDto:
  // Backend uses tripID (not id), name (not title), places[] (not placeIds).
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      // Backend TripDetailDto / TripListDto → tripID, name
      id: (json['tripID'] ?? json['id'])?.toString() ?? '',
      title: json['name'] as String? ?? json['title'] as String? ?? 'Unnamed Trip',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'].toString()) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'].toString()) : DateTime.now().add(const Duration(days: 1)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'placeIds': plannedPlaces.map((p) => p.id).toList(),
    };
  }
}
