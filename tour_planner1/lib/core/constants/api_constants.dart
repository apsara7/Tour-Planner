class ApiConstants {
  // 👇 For emulator
  // static const String baseUrl = "http://10.0.2.2:4066";
  // static const String baseUrl = "http://localhost:4066";
  // static const String baseUrl = "http://10.173.106.212:4066"; //pc's ipv4
  // If testing on real device, replace with your PC's LAN IP
  // static const String baseUrl = "http://192.168.1.100:4066";
  static const String baseUrl = "http://10.173.106.212:4066";

  static const String login = '/api/login_user';
  static const String register = '/api/register';
  static const String verifyEmail = '/api/verify-email';
  static const String logout = '/api/logout';
  static const String profile = '/api/user/profile';
  static const String updateProfile = '/api/user/profile';

  // Places endpoints
  static const String places = '/api/viewPlaces';
  static const String placeById = '/api/viewPlaceByID';

  // Guides endpoints
  static const String guides = '/api/viewGuides';
  static const String guideById = '/api/viewGuideByID';

  // Hotels endpoints
  static const String hotels = '/api/viewHotels';
  static const String hotelById = '/api/viewHotelByID';

  // Vehicles endpoints
  static const String vehicles = '/api/vehicles';
  static const String vehicleById = '/api/vehicles';

  // Trips endpoints
  static const String trips = '/api/trips';
  static const String userTrips = '/api/user';
  static const String addPlaceToTrip = '/api/trips/add-place';
  static const String removePlaceFromTrip = '/api/trips/remove-place';
  static const String addGuideToTrip = '/api/trips/add-guide';
  static const String removeGuideFromTrip = '/api/trips/remove-guide';
  static const String updateGuideInTrip = '/api/trips/update-guide';
  static const String addHotelToTrip = '/api/trips/add-hotel';
  static const String removeHotelFromTrip = '/api/trips/remove-hotel';
  static const String updateHotelInTrip = '/api/trips/update-hotel';
  static const String addVehicleToTrip = '/api/trips/add-vehicle';
  static const String removeVehicleFromTrip = '/api/trips/remove-vehicle';
  static const String updateVehicleInTrip = '/api/trips/update-vehicle';
  static const String defaultTrip = '/api/user';
}
