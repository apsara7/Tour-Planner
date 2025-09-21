import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import 'place_detail_view.dart';

class PlacesListView extends StatefulWidget {
  const PlacesListView({super.key});

  @override
  State<PlacesListView> createState() => _PlacesListViewState();
}

class _PlacesListViewState extends State<PlacesListView> {
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> filteredPlaces = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await _apiService.getAllPlaces();
      setState(() {
        places = data.cast<Map<String, dynamic>>();
        filteredPlaces = places;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching places: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterPlaces(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPlaces = places;
      } else {
        filteredPlaces = places.where((place) {
          final name = (place['name'] ?? '').toString().toLowerCase();
          final province = (place['province'] ?? '').toString().toLowerCase();
          final district = (place['district'] ?? '').toString().toLowerCase();
          final location = (place['location'] ?? '').toString().toLowerCase();
          final description =
              (place['description'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) ||
              province.contains(searchQuery) ||
              district.contains(searchQuery) ||
              location.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places in Sri Lanka'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add place screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Place feature coming soon!')),
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_location),
        label: const Text('Add Place'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterPlaces,
        decoration: InputDecoration(
          hintText: 'Search places, provinces, districts...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _filterPlaces('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text("Loading places...", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Failed to load places",
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchPlaces,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (filteredPlaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isEmpty
                  ? Icons.place_outlined
                  : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? "No places found"
                  : "No places match your search",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterPlaces('');
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchPlaces,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = filteredPlaces[index];
          return _buildPlaceCard(place);
        },
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final String name = place['name'] ?? 'Unknown Place';
    final String description = place['description'] ?? '';
    final String province = place['province'] ?? '';
    final String district = place['district'] ?? '';
    final String entryFee = place['entryFee'] ?? '';
    final List<dynamic> images = place['images'] ?? [];

    // Get the first image for the card
    String imageUrl = '';
    if (images.isNotEmpty) {
      imageUrl = images[0].toString();
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToPlaceDetail(place),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.place,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    if (description.isNotEmpty)
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Location info
                    if (province.isNotEmpty || district.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [province, district]
                                  .where((s) => s.isNotEmpty)
                                  .join(', '),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    if (entryFee.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.monetization_on,
                              size: 14, color: Colors.orange[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entryFee,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPlaceDetail(Map<String, dynamic> place) {
    context.go('/places/${place['_id']}');
  }
}
