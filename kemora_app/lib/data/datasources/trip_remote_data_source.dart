import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/trip_model.dart';
import '../../domain/entities/trip_plan_request.dart';
import '../models/ai_itinerary_model.dart';
import '../../domain/entities/ai_itinerary.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> createTripPlan(String title, DateTime startDate, DateTime endDate, List<String> placeIds);
  Future<List<TripModel>> getUserTrips();
  Future<AIItinerary> generateItinerary(TripPlanRequest request);
  Future<ItineraryItem> swapPlace(String currentPlaceName, String preferences);
  Future<TripModel> saveAIPlan(AIItinerary itinerary, DateTime startDate, DateTime endDate);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<TripModel> saveAIPlan(AIItinerary itinerary, DateTime startDate, DateTime endDate) async {
    try {
      final List<Map<String, dynamic>> activities = [];
      
      for (var day in itinerary.days) {
        final DateTime visitDate = startDate.add(Duration(days: day.dayNumber - 1));
        for (var act in day.activities) {
          activities.add({
            'name': act.name,
            'description': act.description,
            'latitude': act.latitude,
            'longitude': act.longitude,
            'category': act.category,
            'imageUrl': act.imageUrl,
            'visitDate': visitDate.toIso8601String(),
            'notes': act.itineraryReview,
          });
        }
      }

      final response = await dio.post(
        '/api/v1/trips/save-plan',
        data: {
          'title': itinerary.title,
          'description': 'AI generated trip for ${itinerary.duration}',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'activities': activities,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to save AI plan');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?['message'] ?? 'Server Error saving plan');
    }
  }

  @override
  Future<ItineraryItem> swapPlace(String currentPlaceName, String preferences) async {
    try {
      final response = await dio.get(
        '/api/v1/places/swap',
        queryParameters: {
          'currentPlaceName': currentPlaceName,
          'preferences': preferences,
        },
      );
      
      if (response.statusCode == 200) {
        // Backend returns the new place as JSON string or object
        // Assuming it's a JSON string representing the activity
        if (response.data is String) {
          return ItineraryItemModel.fromJson(json.decode(response.data));
        }
        return ItineraryItemModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to swap place');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = data is String ? data : (data?['message'] ?? 'Server Error');
      throw ServerFailure(errorMessage);
    }
  }

  @override
  Future<AIItinerary> generateItinerary(TripPlanRequest request) async {
    try {
      final response = await dio.post(
        '/api/v1/places/trip-plan',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final String? tripPlanJson = response.data['tripPlan'];
        if (tripPlanJson != null && tripPlanJson.isNotEmpty) {
          try {
            return AIItineraryModel.fromString(tripPlanJson);
          } catch (e) {
            throw const ServerFailure('AI generated an incomplete plan. Please try again.');
          }
        }
        return const AIItinerary(title: 'Empty Plan', duration: '0 days', days: []);
      } else {
        throw const ServerFailure('Failed to generate AI itinerary');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = data is String ? data : (data?['message'] ?? 'Server Error');
      throw ServerFailure(errorMessage);
    }
  }

  @override
  Future<TripModel> createTripPlan(String title, DateTime startDate, DateTime endDate, List<String> placeIds) async {
    try {
      final response = await dio.post(
        '/api/v1/trips',
        data: {
          'name': title,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'placeIds': placeIds,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create trip');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  // [KEMORA-MIGRATION] Backend GET /api/v1/trips returns PagedResult<TripListDto> { items: [...], totalCount, page, pageSize }
  // Fixed to unwrap the 'items' array. Falls back to direct list if server returns flat array.
  Future<List<TripModel>> getUserTrips() async {
    try {
      final response = await dio.get('/api/v1/trips');
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = (data is Map && data.containsKey('items'))
            ? data['items'] as List<dynamic>
            : data as List<dynamic>;
        return items.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch trips');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?['message'] ?? 'Server Error');
    }
  }
}
