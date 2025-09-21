import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart'; // 👈 Add this import

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;

  bool get isAuthenticated => _isAuthenticated;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // 🔹 LOGIN
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(ApiConstants.login, {
        "username": username,
        "password": password,
      });

      if (response["success"] == true) {
        final data = response["data"];
        _user = UserModel.fromJson(data["user"]);
        await _apiService.setToken(data["token"]); // Save JWT
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 🔹 REGISTER
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(ApiConstants.register, userData);

      if (response["success"] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 🔹 CHECK AUTH STATUS (for splash)
  Future<void> checkAuthStatus() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      if (response["success"] == true) {
        _user = UserModel.fromJson(response["data"]);
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    await _apiService.clearTokens();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}
