import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/trip_model.dart';
import '../models/place_model.dart';
import '../models/guide_model.dart';
import '../providers/user_provider.dart';

class TripsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Trip> _trips = [];
  Trip? _currentTrip;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  bool _hasAddedPlaceToTrip = false;
  bool _hasAddedGuideToTrip = false; // Add flag for guides
  bool _hasAddedHotelToTrip = false; // Add flag for hotels
  BuildContext? _context;

  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAddedPlaceToTrip => _hasAddedPlaceToTrip;
  bool get hasAddedGuideToTrip => _hasAddedGuideToTrip; // Add getter for guides
  bool get hasAddedHotelToTrip => _hasAddedHotelToTrip; // Add getter for hotels

  void setContext(BuildContext context) {
    _context = context;
  }

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  String get currentUserId {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      if (kDebugMode) {
        print('currentUserId: Using _currentUserId: $_currentUserId');
      }
      return _currentUserId!;
    }

    // Try to get user ID from UserProvider if context is available
    if (_context != null) {
      try {
        // Check if the context is still active before using it
        if (_context!.mounted) {
          final userProvider =
              Provider.of<UserProvider>(_context!, listen: false);
          final userData = userProvider.userData;
          if (userData != null) {
            final userId = userData['id'] ?? userData['_id'];
            if (userId != null && userId.toString().isNotEmpty) {
              if (kDebugMode) {
                print('currentUserId: Using UserProvider userId: $userId');
              }
              return userId.toString();
            }
          }
        } else {
          if (kDebugMode) {
            print('currentUserId: Context is not mounted');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('currentUserId: Error getting user ID from UserProvider: $e');
        }
        // If we can't get user ID from UserProvider, continue to throw exception
      }
    }

    if (kDebugMode) {
      print('currentUserId: No valid user ID found, throwing exception');
      print('_currentUserId: $_currentUserId');
      print('_context is null: ${_context == null}');
      if (_context != null) {
        print('_context is mounted: ${_context!.mounted}');
      }
    }

    throw Exception(
        'User ID not set. Please call setUserId() with a valid user ID or ensure UserProvider has user data.');
  }

  // Get or create default trip
  Future<Trip> getOrCreateDefaultTrip() async {
    try {
      _error = null;

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.getOrCreateDefaultTrip(userId);
      if (response['status'] == 'Success') {
        final tripData = response['trip'];
        if (kDebugMode) {
          print('=== DEBUG getOrCreateDefaultTrip ===');
          print('Raw response keys: ${response.keys.toList()}');
          print('Trip data keys: ${tripData.keys.toList()}');
          print('Places field type: ${tripData['places']?.runtimeType}');
          if (tripData['places'] is List) {
            final places = tripData['places'] as List;
            print('Places array length: ${places.length}');
            for (int i = 0; i < places.length; i++) {
              print(
                  'Place $i keys: ${places[i] is Map ? (places[i] as Map).keys.toList() : 'not a map'}');
              if (places[i] is Map && places[i]['placeId'] != null) {
                print(
                    'Place $i placeId type: ${places[i]['placeId'].runtimeType}');
                if (places[i]['placeId'] is Map) {
                  print(
                      'Place $i placeId keys: ${(places[i]['placeId'] as Map).keys.toList()}');
                  print('Place $i placeId._id: ${places[i]['placeId']['_id']}');
                }
              }
            }
          }
          print('===============================');
        }
        _currentTrip = Trip.fromJson(tripData);
        if (kDebugMode) {
          print('getOrCreateDefaultTrip - Parsed trip: ${_currentTrip!.name}');
          print(
              'getOrCreateDefaultTrip - Parsed place IDs: ${_currentTrip!.placeIds}');
        }

        // Add to trips list if not already there
        final existingIndex =
            _trips.indexWhere((t) => t.id == _currentTrip!.id);
        if (existingIndex >= 0) {
          _trips[existingIndex] = _currentTrip!;
        } else {
          _trips.insert(0, _currentTrip!);
        }

        notifyListeners();
        return _currentTrip!;
      } else {
        throw Exception('Failed to get or create default trip');
      }
    } catch (e) {
      _error = 'Failed to get or create default trip: $e';
      if (kDebugMode) {
        print('Error getting default trip: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  // Add place to trip
  Future<bool> addPlaceToTrip(String placeId,
      {String? tripId, String? notes}) async {
    try {
      _error = null;

      // Use provided tripId or get/create default trip
      final targetTripId = tripId ?? (await getOrCreateDefaultTrip()).id;
      if (targetTripId == null) {
        throw Exception('Failed to get trip ID');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.addPlaceToTrip(
        targetTripId,
        placeId,
        userId, // Use the captured user ID instead of accessing currentUserId again
        notes: notes,
      );

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        _hasAddedPlaceToTrip = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to add place to trip: $errorMessage';
      if (kDebugMode) {
        print('Error adding place to trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Remove place from trip
  Future<bool> removePlaceFromTrip(String placeId, {String? tripId}) async {
    try {
      _error = null;

      // Use provided tripId or current trip
      final targetTripId = tripId ?? _currentTrip?.id;
      if (targetTripId == null) {
        throw Exception('No trip selected');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.removePlaceFromTrip(
        targetTripId,
        placeId,
        userId, // Use the captured user ID instead of accessing currentUserId again
      );

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        _hasAddedPlaceToTrip = false; // Reset flag when removing
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to remove place from trip: $errorMessage';
      if (kDebugMode) {
        print('Error removing place from trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Check if place is in trip
  bool isPlaceInTrip(String placeId, {String? tripId}) {
    final trip = tripId != null
        ? _trips.firstWhere((t) => t.id == tripId,
            orElse: () => Trip(
                  name: '',
                  userId: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
        : _currentTrip;

    if (trip == null) return false;
    return trip.placeIds.contains(placeId);
  }

  // Add guide to trip
  Future<bool> addGuideToTrip(String guideId,
      {String? tripId,
      String? notes,
      Map<String, dynamic>? workingHours}) async {
    try {
      _error = null;

      if (kDebugMode) {
        print(
            'addGuideToTrip called with guideId: $guideId, tripId: $tripId, notes: $notes');
        print('Current user ID: $currentUserId');
      }

      // Use provided tripId or get/create default trip
      final targetTripId = tripId ?? (await getOrCreateDefaultTrip()).id;
      if (targetTripId == null) {
        throw Exception('Failed to get trip ID');
      }

      if (kDebugMode) {
        print('Target trip ID: $targetTripId');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.addGuideToTrip(
        targetTripId,
        guideId,
        userId, // Use the captured user ID instead of accessing currentUserId again
        notes: notes,
        workingHours: workingHours,
      );

      if (kDebugMode) {
        print('addGuideToTrip response: $response');
      }

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        _hasAddedGuideToTrip = true; // Set the flag
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to add guide to trip: $errorMessage';
      if (kDebugMode) {
        print('Error adding guide to trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Remove guide from trip
  Future<bool> removeGuideFromTrip(String guideId, {String? tripId}) async {
    try {
      _error = null;

      if (kDebugMode) {
        print(
            'removeGuideFromTrip called with guideId: $guideId, tripId: $tripId');
        print('Current user ID: $currentUserId');
      }

      // Use provided tripId or current trip
      final targetTripId = tripId ?? _currentTrip?.id;
      if (targetTripId == null) {
        throw Exception('No trip selected');
      }

      if (kDebugMode) {
        print('Target trip ID: $targetTripId');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.removeGuideFromTrip(
        targetTripId,
        guideId,
        userId, // Use the captured user ID instead of accessing currentUserId again
      );

      if (kDebugMode) {
        print('removeGuideFromTrip response: $response');
      }

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        _hasAddedGuideToTrip = false; // Reset the flag
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to remove guide from trip: $errorMessage';
      if (kDebugMode) {
        print('Error removing guide from trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Check if guide is in trip
  bool isGuideInTrip(String guideId, {String? tripId}) {
    final trip = tripId != null
        ? _trips.firstWhere((t) => t.id == tripId,
            orElse: () => Trip(
                  name: '',
                  userId: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
        : _currentTrip;

    if (trip == null) {
      if (kDebugMode) {
        print('isGuideInTrip: No trip found for guideId: $guideId');
      }
      return false;
    }

    final result = trip.guideIds.contains(guideId);
    if (kDebugMode) {
      print(
          'isGuideInTrip: guideId: $guideId, tripId: ${trip.id}, guideIds: ${trip.guideIds}, result: $result');
    }
    return result;
  }

  // Add hotel to trip
  Future<bool> addHotelToTrip(String hotelId, String packageId,
      {String? tripId,
      Map<String, dynamic>? bookingDetails,
      String? notes}) async {
    try {
      _error = null;

      if (kDebugMode) {
        print(
            'addHotelToTrip called with hotelId: $hotelId, packageId: $packageId, tripId: $tripId');
        print('Current user ID: $currentUserId');
      }

      // Use provided tripId or get/create default trip
      final targetTripId = tripId ?? (await getOrCreateDefaultTrip()).id;
      if (targetTripId == null) {
        throw Exception('Failed to get trip ID');
      }

      if (kDebugMode) {
        print('Target trip ID: $targetTripId');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.addHotelToTrip(
        targetTripId,
        hotelId,
        packageId,
        userId, // Use the captured user ID instead of accessing currentUserId again
        bookingDetails: bookingDetails,
        notes: notes,
      );

      if (kDebugMode) {
        print('addHotelToTrip response: $response');
      }

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        _hasAddedHotelToTrip = true; // Set the flag
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to add hotel to trip: $errorMessage';
      if (kDebugMode) {
        print('Error adding hotel to trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Remove hotel from trip
  Future<bool> removeHotelFromTrip(String hotelId, {String? tripId}) async {
    try {
      _error = null;

      if (kDebugMode) {
        print(
            'removeHotelFromTrip called with hotelId: $hotelId, tripId: $tripId');
        print('Current user ID: $currentUserId');
      }

      // Use provided tripId or current trip
      final targetTripId = tripId ?? _currentTrip?.id;
      if (targetTripId == null) {
        throw Exception('No trip selected');
      }

      if (kDebugMode) {
        print('Target trip ID: $targetTripId');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.removeHotelFromTrip(
        targetTripId,
        hotelId,
        userId, // Use the captured user ID instead of accessing currentUserId again
      );

      if (kDebugMode) {
        print('removeHotelFromTrip response: $response');
      }

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        _hasAddedHotelToTrip = false; // Reset the flag
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to remove hotel from trip: $errorMessage';
      if (kDebugMode) {
        print('Error removing hotel from trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Check if hotel is in trip
  bool isHotelInTrip(String hotelId, {String? tripId}) {
    final trip = tripId != null
        ? _trips.firstWhere((t) => t.id == tripId,
            orElse: () => Trip(
                  name: '',
                  userId: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
        : _currentTrip;

    if (trip == null) return false;
    return trip.hotelIds.contains(hotelId);
  }

  // Get places for a specific trip
  Future<List<Place>> getTripPlaces({String? tripId}) async {
    try {
      final trip = tripId != null
          ? _trips.firstWhere((t) => t.id == tripId,
              orElse: () => Trip(
                    name: '',
                    userId: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ))
          : await getOrCreateDefaultTrip();

      if (kDebugMode) {
        print('getTripPlaces - Trip ID: ${trip.id}');
        print('getTripPlaces - Trip name: ${trip.name}');
        print('getTripPlaces - Place IDs: ${trip.placeIds}');
        print('getTripPlaces - Number of place IDs: ${trip.placeIds.length}');
      }

      final List<Place> places = [];

      for (String placeId in trip.placeIds) {
        try {
          if (kDebugMode) {
            print('Fetching place details for ID: $placeId');
          }
          final response = await _apiService.getPlaceById(placeId);
          if (response['status'] == 'Success') {
            places.add(Place.fromJson(response['place']));
            if (kDebugMode) {
              print('Successfully loaded place: ${response['place']['name']}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching place $placeId: $e');
          }
        }
      }

      if (kDebugMode) {
        print('getTripPlaces - Total places loaded: ${places.length}');
      }

      return places;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trip places: $e');
      }
      return [];
    }
  }

  // Get guides for a specific trip
  Future<List<Guide>> getTripGuides({String? tripId}) async {
    try {
      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final trip = tripId != null
          ? _trips.firstWhere((t) => t.id == tripId,
              orElse: () => Trip(
                    name: '',
                    userId: userId, // Use the captured user ID
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ))
          : await getOrCreateDefaultTrip();

      if (kDebugMode) {
        print('getTripGuides - Trip ID: ${trip.id}');
        print('getTripGuides - Trip name: ${trip.name}');
        print('getTripGuides - Guide IDs: ${trip.guideIds}');
        print('getTripGuides - Number of guide IDs: ${trip.guideIds.length}');
      }

      final List<Guide> guides = [];

      for (String guideId in trip.guideIds) {
        try {
          if (kDebugMode) {
            print('Fetching guide details for ID: $guideId');
          }
          final response = await _apiService.getGuideById(guideId);
          if (response['status'] == 'Success') {
            guides.add(Guide.fromJson(response['guide']));
            if (kDebugMode) {
              print(
                  'Successfully loaded guide: ${response['guide']['guideName']}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching guide $guideId: $e');
          }
        }
      }

      if (kDebugMode) {
        print('getTripGuides - Total guides loaded: ${guides.length}');
      }

      return guides;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trip guides: $e');
      }
      return [];
    }
  }

  // Get hotels for a specific trip
  Future<List<dynamic>> getTripHotels({String? tripId}) async {
    try {
      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final trip = tripId != null
          ? _trips.firstWhere((t) => t.id == tripId,
              orElse: () => Trip(
                    name: '',
                    userId: userId, // Use the captured user ID
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ))
          : await getOrCreateDefaultTrip();

      if (kDebugMode) {
        print('getTripHotels - Trip ID: ${trip.id}');
        print('getTripHotels - Trip name: ${trip.name}');
        print('getTripHotels - Hotel IDs: ${trip.hotelIds}');
        print('getTripHotels - Number of hotel IDs: ${trip.hotelIds.length}');
      }

      final List<dynamic> hotels = [];

      for (String hotelId in trip.hotelIds) {
        try {
          if (kDebugMode) {
            print('Fetching hotel details for ID: $hotelId');
          }
          final response = await _apiService.getHotelById(hotelId);
          if (response['status'] == 'Success') {
            hotels.add(response['hotel']);
            if (kDebugMode) {
              print('Successfully loaded hotel: ${response['hotel']['name']}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching hotel $hotelId: $e');
          }
        }
      }

      if (kDebugMode) {
        print('getTripHotels - Total hotels loaded: ${hotels.length}');
      }

      return hotels;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trip hotels: $e');
      }
      return [];
    }
  }

  // Add vehicle to trip
  Future<bool> addVehicleToTrip(String vehicleId,
      {String? tripId,
      int? travellersCount,
      String? notes,
      bool? withDriver}) async {
    try {
      _error = null;

      if (kDebugMode) {
        print(
            'addVehicleToTrip called with vehicleId: $vehicleId, tripId: $tripId, travellersCount: $travellersCount, notes: $notes, withDriver: $withDriver');
        print('Current user ID: $currentUserId');
      }

      // Use provided tripId or get/create default trip
      final targetTripId = tripId ?? (await getOrCreateDefaultTrip()).id;
      if (targetTripId == null) {
        throw Exception('Failed to get trip ID');
      }

      if (kDebugMode) {
        print('Target trip ID: $targetTripId');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.addVehicleToTrip(
        targetTripId,
        vehicleId,
        userId, // Use the captured user ID instead of accessing currentUserId again
        travellersCount: travellersCount,
        notes: notes,
        withDriver: withDriver,
      );

      if (kDebugMode) {
        print('addVehicleToTrip response: $response');
      }

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to add vehicle to trip: $errorMessage';
      if (kDebugMode) {
        print('Error adding vehicle to trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Remove vehicle from trip
  Future<bool> removeVehicleFromTrip(String vehicleId, {String? tripId}) async {
    try {
      _error = null;

      if (kDebugMode) {
        print(
            'removeVehicleFromTrip called with vehicleId: $vehicleId, tripId: $tripId');
        print('Current user ID: $currentUserId');
      }

      // Use provided tripId or current trip
      final targetTripId = tripId ?? _currentTrip?.id;
      if (targetTripId == null) {
        throw Exception('No trip selected');
      }

      if (kDebugMode) {
        print('Target trip ID: $targetTripId');
      }

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final response = await _apiService.removeVehicleFromTrip(
        targetTripId,
        vehicleId,
        userId, // Use the captured user ID instead of accessing currentUserId again
      );

      if (kDebugMode) {
        print('removeVehicleFromTrip response: $response');
      }

      if (response['status'] == 'Success') {
        // Update the trip in our local state
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == targetTripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        // Update current trip if it's the same trip
        if (_currentTrip?.id == targetTripId) {
          _currentTrip = updatedTrip;
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to remove vehicle from trip: $errorMessage';
      if (kDebugMode) {
        print('Error removing vehicle from trip: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Check if vehicle is in trip
  bool isVehicleInTrip(String vehicleId, {String? tripId}) {
    final trip = tripId != null
        ? _trips.firstWhere((t) => t.id == tripId,
            orElse: () => Trip(
                  name: '',
                  userId: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
        : _currentTrip;

    if (trip == null) return false;
    return trip.vehicleIds.contains(vehicleId);
  }

  // Get vehicles for a specific trip
  Future<List<dynamic>> getTripVehicles({String? tripId}) async {
    try {
      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final trip = tripId != null
          ? _trips.firstWhere((t) => t.id == tripId,
              orElse: () => Trip(
                    name: '',
                    userId: userId, // Use the captured user ID
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ))
          : await getOrCreateDefaultTrip();

      if (kDebugMode) {
        print('getTripVehicles - Trip ID: ${trip.id}');
        print('getTripVehicles - Trip name: ${trip.name}');
        print('getTripVehicles - Vehicle IDs: ${trip.vehicleIds}');
        print(
            'getTripVehicles - Number of vehicle IDs: ${trip.vehicleIds.length}');
        print('getTripVehicles - Vehicles data: ${trip.vehicles}');
        print('getTripVehicles - Number of vehicles: ${trip.vehicles.length}');
      }

      // Return the vehicles data that's already embedded in the trip
      return trip.vehicles;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trip vehicles: $e');
      }
      return [];
    }
  }

  void resetAddedPlaceFlag() {
    _hasAddedPlaceToTrip = false;
    notifyListeners();
  }

  void resetAddedGuideFlag() {
    _hasAddedGuideToTrip = false;
    notifyListeners();
  }

  void resetAddedHotelFlag() {
    _hasAddedHotelToTrip = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update trip dates
  Future<bool> updateTripDates(String tripId,
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      _error = null;

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final updateData = {
        'userId': userId, // Use the captured user ID
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _apiService.updateTrip(tripId, updateData);
      if (response['status'] == 'Success') {
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == tripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        if (_currentTrip?.id == tripId) {
          _currentTrip = updatedTrip;
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to update trip dates: $errorMessage';
      if (kDebugMode) {
        print('Error updating trip dates: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Update trip details (travellers count, other expenses, etc.)
  Future<bool> updateTripDetails(String tripId,
      {int? travellersCount, double? otherExpenses}) async {
    try {
      _error = null;

      // Set the user ID explicitly to avoid context issues
      final userId = currentUserId;

      final updateData = {
        'userId': userId, // Use the captured user ID
        if (travellersCount != null) 'travellersCount': travellersCount,
        if (otherExpenses != null) 'otherExpenses': otherExpenses,
      };

      final response = await _apiService.updateTrip(tripId, updateData);
      if (response['status'] == 'Success') {
        final updatedTrip = Trip.fromJson(response['trip']);
        final tripIndex = _trips.indexWhere((t) => t.id == tripId);
        if (tripIndex >= 0) {
          _trips[tripIndex] = updatedTrip;
        }

        if (_currentTrip?.id == tripId) {
          _currentTrip = updatedTrip;
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to update trip details: $errorMessage';
      if (kDebugMode) {
        print('Error updating trip details: $e');
      }
      notifyListeners();
    }
    return false;
  }

  Future<void> fetchTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      await getOrCreateDefaultTrip();
    } catch (e) {
      // Extract just the error message without the "Exception:" prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring(11); // Remove "Exception: " prefix
      }
      _error = 'Failed to fetch trips: $errorMessage';
      if (kDebugMode) {
        print('Error fetching trips: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
