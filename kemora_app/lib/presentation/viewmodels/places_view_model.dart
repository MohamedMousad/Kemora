import 'package:flutter/material.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/explore_usecases.dart';
import '../../domain/usecases/get_places_usecase.dart';
import '../../domain/usecases/get_places_by_category_usecase.dart';

enum PlacesState { initial, loading, loaded, error }

class PlacesViewModel extends ChangeNotifier {
  final GetPlacesUseCase getPlacesUseCase;
  final GetPlacesByCategoryUseCase getPlacesByCategoryUseCase;
  final GetTopPlacesUseCase getTopPlacesUseCase;
  final GetGovernoratesUseCase getGovernoratesUseCase;
  final GetPlacesByGovernorateUseCase getPlacesByGovernorateUseCase;

  PlacesViewModel({
    required this.getPlacesUseCase,
    required this.getPlacesByCategoryUseCase,
    required this.getTopPlacesUseCase,
    required this.getGovernoratesUseCase,
    required this.getPlacesByGovernorateUseCase,
  });

  PlacesState _state = PlacesState.initial;
  PlacesState get state => _state;

  List<Place> _places = [];
  List<Place> get places => _places;

  List<Place> _topPlaces = [];
  List<Place> get topPlaces => _topPlaces;

  List<Governorate> _governorates = [];
  List<Governorate> get governorates => _governorates;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentCategory = 'All';
  String get currentCategory => _currentCategory;

  Future<void> loadPlaces([String category = 'All']) async {
    _state = PlacesState.loading;
    _currentCategory = category;
    _errorMessage = null;
    notifyListeners();

    final result = category == 'All'
        ? await getPlacesUseCase()
        : await getPlacesByCategoryUseCase(category);

    result.fold(
      (failure) {
        _state = PlacesState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (placesList) {
        _places = placesList;
        _state = PlacesState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadTopPlaces() async {
    final result = await getTopPlacesUseCase();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _topPlaces = list,
    );
    notifyListeners();
  }

  Future<void> loadGovernorates() async {
    final result = await getGovernoratesUseCase();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _governorates = list,
    );
    notifyListeners();
  }

  Future<void> loadPlacesByGovernorate(String governorateId) async {
    _state = PlacesState.loading;
    notifyListeners();
    
    final result = await getPlacesByGovernorateUseCase(governorateId);
    result.fold(
      (failure) {
        _state = PlacesState.error;
        _errorMessage = failure.message;
      },
      (list) {
        _places = list;
        _state = PlacesState.loaded;
      },
    );
    notifyListeners();
  }

  /// Looks up a place by ID from local caches first, then fetches from API.
  Future<Place?> getPlaceById(String id) async {
    // Check in-memory caches first
    try {
      return _topPlaces.firstWhere((p) => p.id == id);
    } catch (_) {}
    try {
      return _places.firstWhere((p) => p.id == id);
    } catch (_) {}
    // Not cached — load all places and search again
    await loadTopPlaces();
    try {
      return _topPlaces.firstWhere((p) => p.id == id);
    } catch (_) {}
    return null;
  }
}
