import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/hotel_model.dart';
import '../../core/services/api_service.dart';
import 'hotel_detail_view.dart';

class HotelsListView extends StatefulWidget {
  const HotelsListView({super.key});

  @override
  State<HotelsListView> createState() => _HotelsListViewState();
}

class _HotelsListViewState extends State<HotelsListView> {
  final ApiService _apiService = ApiService();
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'All Cities';
  List<String> _cities = ['All Cities'];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _apiService.getAllHotels();

      // Parse hotels from response
      final hotels =
          response.map<Hotel>((hotel) => Hotel.fromJson(hotel)).toList();

      // Extract unique cities
      final cities = hotels
          .map((hotel) => hotel.city)
          .where((city) => city.isNotEmpty)
          .toSet()
          .toList();
      cities.sort();

      if (mounted) {
        setState(() {
          _hotels = hotels;
          _filteredHotels = hotels;
          _cities = ['All Cities', ...cities];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading hotels: $e';
        });
      }
    }
  }

  void _filterHotels() {
    setState(() {
      _filteredHotels = _hotels.where((hotel) {
        final matchesSearch = hotel.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            hotel.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            hotel.city
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesCity =
            _selectedCity == 'All Cities' || hotel.city == _selectedCity;

        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search hotels...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => _filterHotels(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: 'Filter by City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            items: _cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value!;
              });
              _filterHotels();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    final activePackages =
        hotel.packages.where((p) => p.isValidForBooking).toList();
    final hasActivePackages = activePackages.isNotEmpty;
    final minPrice = hasActivePackages
        ? activePackages.map((p) => p.price).reduce((a, b) => a < b ? a : b)
        : 0.0;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasActivePackages
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HotelDetailView(hotelId: hotel.id, hotel: hotel),
                  ),
                );
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Image
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                image: hotel.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(hotel.images.first),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      )
                    : null,
                color: hotel.images.isEmpty ? Colors.grey[300] : null,
              ),
              child: hotel.images.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.hotel,
                        size: 36,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // City
                  Text(
                    hotel.city,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        hotel.ratings.overall.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        ' (${hotel.ratings.totalReviews})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Package Info
                  if (hasActivePackages) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'LKR ${minPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'No active packages',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHotels,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadHotels,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredHotels.isEmpty
                        ? const Center(
                            child: Text(
                              'No hotels found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 hotels per row
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  0.75, // Further reduced aspect ratio
                            ),
                            itemCount: _filteredHotels.length,
                            itemBuilder: (context, index) {
                              return _buildHotelCard(_filteredHotels[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
