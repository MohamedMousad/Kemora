import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/place_model.dart';

abstract class PlacesRemoteDataSource {
  Future<List<PlaceModel>> getPlaces();
  Future<List<PlaceModel>> getPlacesByCategory(String category);
  Future<List<PlaceModel>> getTopPlaces();
  Future<List<GovernorateModel>> getGovernorates();
  Future<List<PlaceModel>> getPlacesByGovernorate(String governorateId);
  Future<PlaceModel> getPlaceDetails(String id);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final Dio dio;

  PlacesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final response = await dio.get('/api/v1/places', queryParameters: {'sortBy': 'rating'});
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load places');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getPlacesByCategory(String category) async {
    try {
      final response = await dio.get('/api/v1/places', queryParameters: {'categoryName': category});
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load places by category');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getTopPlaces() async {
    try {
      final response = await dio.get('/api/v1/places/top');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to load top places');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<GovernorateModel>> getGovernorates() async {
    try {
      final response = await dio.get('/api/v1/places/governorates');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GovernorateModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to load governorates');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getPlacesByGovernorate(String governorateId) async {
    try {
      final response = await dio.get('/api/v1/places', queryParameters: {'governorateId': governorateId});
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load places by governorate');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<PlaceModel> getPlaceDetails(String id) async {
    try {
      final response = await dio.get('/api/v1/places/$id');
      if (response.statusCode == 200) {
        return PlaceModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to load place details');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
