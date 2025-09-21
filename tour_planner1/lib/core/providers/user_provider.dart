import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.profile);
      if (response['success'] == true) {
        _userData = response['data'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch user data';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      _errorMessage = 'Network error: Unable to fetch user data';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.put(ApiConstants.updateProfile, updatedData);
      if (response['success'] == true) {
        _userData = response['data'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      _errorMessage = 'Network error: Unable to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearUserData() {
    _userData = null;
    _errorMessage = null;
    notifyListeners();
  }
}