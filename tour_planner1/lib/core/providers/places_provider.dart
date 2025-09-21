import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PlacesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get places => _places;
  bool get isLoading => _isLoading;

  Future<void> fetchPlaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/viewPlaces');
      // For now, set some default places data to avoid API issues
      _places = [
        {
          'name': 'Sigiriya',
          'description': 'Ancient Rock Fortress',
          'images': ['https://example.com/sigiriya.jpg']
        },
        {
          'name': 'Ella',
          'description': 'Scenic Hill Country',
          'images': ['https://example.com/ella.jpg']
        },
        {
          'name': 'Kandy',
          'description': 'Cultural Capital',
          'images': ['https://example.com/kandy.jpg']
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching places: $e');
      }
      _places = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
