import 'dart:convert';
import '../../domain/entities/ai_itinerary.dart';

class AIItineraryModel extends AIItinerary {
  const AIItineraryModel({
    required super.title,
    required super.duration,
    required super.days,
  });

  factory AIItineraryModel.fromJson(Map<String, dynamic> json) {
    return AIItineraryModel(
      title: json['trip_title'] as String? ?? 'AI Trip Plan',
      duration: json['trip_duration'] as String? ?? '',
      days: (json['itinerary'] as List<dynamic>?)
              ?.map((d) => TripDayModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory AIItineraryModel.fromString(String jsonString) {
    final Map<String, dynamic> decoded = json.decode(jsonString);
    return AIItineraryModel.fromJson(decoded);
  }
}

class TripDayModel extends TripDay {
  const TripDayModel({
    required super.dayNumber,
    required super.activities,
    super.dailySummary,
    super.transportTips,
  });

  factory TripDayModel.fromJson(Map<String, dynamic> json) {
    return TripDayModel(
      dayNumber: json['day'] as int? ?? 1,
      dailySummary: json['daily_summary'] as String?,
      transportTips: json['transport_tips'] as String?,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => ItineraryItemModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ItineraryItemModel extends ItineraryItem {
  const ItineraryItemModel({
    required super.name,
    required super.description,
    required super.timeOfDay,
    super.suggestedHours,
    super.imageUrl,
    super.rating,
    super.price,
    super.itineraryReview,
    super.latitude,
    super.longitude,
    super.category,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    // Strip any type labels like [HOTEL], [RESTAURANT] etc from place names
    String rawName = json['place'] as String? ?? (json['name'] as String? ?? 'Unknown Place');
    final labelRegex = RegExp(r'^\[(HOTEL|RESTAURANT|CAFÉ|CAFE|ATTRACTION)\]\s*', caseSensitive: false);
    final cleanName = rawName.replaceFirst(labelRegex, '').trim();

    // Determine time slot: prefer explicit time_slot, fall back to deriving from time
    String timeSlot = json['time_slot'] as String? ?? json['time_of_day'] as String? ?? '';
    if (timeSlot.isEmpty) {
      final timeStr = json['time'] as String? ?? '';
      final hour = int.tryParse(timeStr.split(':').first) ?? 12;
      if (hour < 12) timeSlot = 'Morning';
      else if (hour < 18) timeSlot = 'Afternoon';
      else timeSlot = 'Evening';
    }

    return ItineraryItemModel(
      name: cleanName,
      description: json['description'] as String? ?? '',
      timeOfDay: timeSlot,
      suggestedHours: json['suggested_hours'] as String?,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      price: json['price'] as String?,
      itineraryReview: json['itinerary_review'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] as String?,
    );
  }
}
