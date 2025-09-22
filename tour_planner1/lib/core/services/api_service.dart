import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearTokens() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    await _loadToken();
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Places API methods
  Future<List<dynamic>> getAllPlaces() async {
    try {
      final response = await get(ApiConstants.places);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }

  Future<Map<String, dynamic>> getPlaceById(String id) async {
    try {
      final response = await get('${ApiConstants.placeById}/$id');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch place details: $e');
    }
  }

  // Guides API methods
  Future<List<dynamic>> getAllGuides() async {
    try {
      final response = await get(ApiConstants.guides);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch guides: $e');
    }
  }

  Future<Map<String, dynamic>> getGuideById(String id) async {
    try {
      final response = await get('${ApiConstants.guideById}/$id');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch guide details: $e');
    }
  }

  // Hotels API methods
  Future<List<dynamic>> getAllHotels() async {
    try {
      final response = await get(ApiConstants.hotels);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch hotels: $e');
    }
  }

  Future<Map<String, dynamic>> getHotelById(String id) async {
    try {
      final response = await get('${ApiConstants.hotelById}/$id');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch hotel details: $e');
    }
  }

  Future<Map<String, dynamic>> addHotelToTrip(
      String tripId, String hotelId, String packageId, String userId,
      {Map<String, dynamic>? bookingDetails, String? notes}) async {
    try {
      final data = {
        'tripId': tripId,
        'hotelId': hotelId,
        'packageId': packageId,
        'userId': userId,
        if (bookingDetails != null) 'bookingDetails': bookingDetails,
        if (notes != null) 'notes': notes,
      };
      final response = await post(ApiConstants.addHotelToTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to add hotel to trip: $e');
    }
  }

  Future<Map<String, dynamic>> removeHotelFromTrip(
      String tripId, String hotelId, String userId) async {
    try {
      final data = {
        'tripId': tripId,
        'hotelId': hotelId,
        'userId': userId,
      };
      final response = await post(ApiConstants.removeHotelFromTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to remove hotel from trip: $e');
    }
  }

  Future<Map<String, dynamic>> updateHotelInTrip(
      String tripId, String hotelId, String userId,
      {Map<String, dynamic>? bookingDetails, String? notes}) async {
    try {
      final data = {
        'tripId': tripId,
        'hotelId': hotelId,
        'userId': userId,
        if (bookingDetails != null) 'bookingDetails': bookingDetails,
        if (notes != null) 'notes': notes,
      };
      final response = await put(ApiConstants.updateHotelInTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to update hotel in trip: $e');
    }
  }

  // Trips API methods
  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    try {
      final response = await post(ApiConstants.trips, tripData);
      return response;
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<Map<String, dynamic>> getUserTrips(String userId) async {
    try {
      final response = await get('${ApiConstants.userTrips}/$userId/trips');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user trips: $e');
    }
  }

  Future<Map<String, dynamic>> getTripById(String tripId, String userId) async {
    try {
      final response =
          await get('${ApiConstants.trips}/$tripId?userId=$userId');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch trip details: $e');
    }
  }

  Future<Map<String, dynamic>> addPlaceToTrip(
      String tripId, String placeId, String userId,
      {String? notes}) async {
    try {
      final data = {
        'tripId': tripId,
        'placeId': placeId,
        'userId': userId,
        if (notes != null) 'notes': notes,
      };
      final response = await post(ApiConstants.addPlaceToTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to add place to trip: $e');
    }
  }

  Future<Map<String, dynamic>> removePlaceFromTrip(
      String tripId, String placeId, String userId) async {
    try {
      final data = {
        'tripId': tripId,
        'placeId': placeId,
        'userId': userId,
      };
      final response = await post(ApiConstants.removePlaceFromTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to remove place from trip: $e');
    }
  }

  Future<Map<String, dynamic>> updateTrip(
      String tripId, Map<String, dynamic> updateData) async {
    try {
      final response = await put('${ApiConstants.trips}/$tripId', updateData);
      return response;
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  Future<Map<String, dynamic>> deleteTrip(String tripId, String userId) async {
    try {
      final data = {'userId': userId};
      final response = await post('${ApiConstants.trips}/$tripId', data);
      return response;
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  Future<Map<String, dynamic>> getOrCreateDefaultTrip(String userId) async {
    try {
      if (kDebugMode) {
        print('getOrCreateDefaultTrip called with userId: $userId');
      }

      final response =
          await get('${ApiConstants.defaultTrip}/$userId/default-trip');

      if (kDebugMode) {
        print('getOrCreateDefaultTrip response: $response');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getOrCreateDefaultTrip: $e');
      }
      throw Exception('Failed to get or create default trip: $e');
    }
  }

  Future<Map<String, dynamic>> addGuideToTrip(
      String tripId, String guideId, String userId,
      {String? notes, Map<String, dynamic>? workingHours}) async {
    try {
      final data = {
        'tripId': tripId,
        'guideId': guideId,
        'userId': userId,
        if (notes != null) 'notes': notes,
        if (workingHours != null) 'workingHours': workingHours,
      };

      if (kDebugMode) {
        print('Sending addGuideToTrip request with data: $data');
      }

      final response = await post(ApiConstants.addGuideToTrip, data);

      if (kDebugMode) {
        print('addGuideToTrip response: $response');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error in addGuideToTrip: $e');
      }
      throw Exception('Failed to add guide to trip: $e');
    }
  }

  Future<Map<String, dynamic>> removeGuideFromTrip(
      String tripId, String guideId, String userId) async {
    try {
      final data = {
        'tripId': tripId,
        'guideId': guideId,
        'userId': userId,
      };
      final response = await post(ApiConstants.removeGuideFromTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to remove guide from trip: $e');
    }
  }

  Future<Map<String, dynamic>> updateGuideInTrip(
      String tripId, String guideId, String userId,
      {Map<String, dynamic>? workingHours, String? notes}) async {
    try {
      final data = {
        'tripId': tripId,
        'guideId': guideId,
        'userId': userId,
        if (workingHours != null) 'workingHours': workingHours,
        if (notes != null) 'notes': notes,
      };
      final response = await put(ApiConstants.updateGuideInTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to update guide in trip: $e');
    }
  }

  // Vehicles API methods
  Future<List<dynamic>> getAllVehicles() async {
    try {
      final response = await get(ApiConstants.vehicles);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  Future<Map<String, dynamic>> getVehicleById(String id) async {
    try {
      final response = await get('${ApiConstants.vehicleById}/$id');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch vehicle details: $e');
    }
  }

  Future<Map<String, dynamic>> addVehicleToTrip(
      String tripId, String vehicleId, String userId,
      {int? travellersCount, String? notes, bool? withDriver}) async {
    try {
      final data = {
        'tripId': tripId,
        'vehicleId': vehicleId,
        'userId': userId,
        if (travellersCount != null) 'travellersCount': travellersCount,
        if (notes != null) 'notes': notes,
        if (withDriver != null) 'withDriver': withDriver,
      };
      final response = await post(ApiConstants.addVehicleToTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to add vehicle to trip: $e');
    }
  }

  Future<Map<String, dynamic>> removeVehicleFromTrip(
      String tripId, String vehicleId, String userId) async {
    try {
      final data = {
        'tripId': tripId,
        'vehicleId': vehicleId,
        'userId': userId,
      };
      final response = await post(ApiConstants.removeVehicleFromTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to remove vehicle from trip: $e');
    }
  }

  Future<Map<String, dynamic>> updateVehicleInTrip(
      String tripId, String vehicleId, String userId,
      {int? travellersCount, String? notes, bool? withDriver}) async {
    try {
      final data = {
        'tripId': tripId,
        'vehicleId': vehicleId,
        'userId': userId,
        if (travellersCount != null) 'travellersCount': travellersCount,
        if (notes != null) 'notes': notes,
        if (withDriver != null) 'withDriver': withDriver,
      };
      final response = await put(ApiConstants.updateVehicleInTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to update vehicle in trip: $e');
    }
  }

  // Hotel trip methods

  Future<Map<String, dynamic>> confirmTrip(String tripId, String userId) async {
    try {
      final data = {
        'tripId': tripId,
        'userId': userId,
      };
      final response = await post(ApiConstants.confirmTrip, data);
      return response;
    } catch (e) {
      throw Exception('Failed to confirm trip: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    // Try to parse the response body
    dynamic responseBody;
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      // If JSON parsing fails, create a generic response
      responseBody = {
        'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}'
      };
    }

    // For successful responses, just return the body
    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody;
    }

    // For error responses, extract the message from the response body
    final message = responseBody is Map && responseBody.containsKey('message')
        ? responseBody['message']
        : 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

    // Throw exception with the proper message
    switch (response.statusCode) {
      case 400:
        throw Exception(message);
      case 401:
        throw Exception(message);
      case 403:
        throw Exception(message);
      case 404:
        throw Exception(message);
      case 500:
        throw Exception(message);
      default:
        throw Exception(message);
    }
  }
}
