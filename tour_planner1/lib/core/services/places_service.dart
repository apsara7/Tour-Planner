import '../constants/api_constants.dart';
import '../models/place_model.dart';
import 'api_service.dart';

class PlacesService {
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService() => _instance;
  PlacesService._internal();

  final ApiService _apiService = ApiService();

  /// Fetch all places from the backend
  Future<List<Place>> getAllPlaces() async {
    try {
      final response = await _apiService.get(ApiConstants.places);

      // The backend returns a direct array for /viewPlaces endpoint
      // Since ApiService._handleResponse always returns Map<String, dynamic>
      // but the actual response might be an array, we need to check the raw response

      // If the JSON decode returns an array directly, it gets wrapped in a map
      // Let's handle both cases:
      if (response is Map<String, dynamic>) {
        // Check if it's the typical structure with a data field
        if (response.containsKey('data') && response['data'] is List) {
          final List<dynamic> placesData = response['data'] as List<dynamic>;
          return placesData
              .map((json) => Place.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // If the response is directly the places data
        else if (response.containsKey('places') && response['places'] is List) {
          final List<dynamic> placesData = response['places'] as List<dynamic>;
          return placesData
              .map((json) => Place.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // If somehow the response structure is different
        else {
          throw Exception('Unexpected response structure: $response');
        }
      } else {
        throw Exception('Invalid response format: Expected a Map with data');
      }
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }

  /// Fetch a specific place by ID
  Future<Place> getPlaceById(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.placeById}/$id');

      if (response['status'] == 'Success' && response['place'] != null) {
        return Place.fromJson(response['place']);
      } else {
        throw Exception('Place not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch place: $e');
    }
  }
}
