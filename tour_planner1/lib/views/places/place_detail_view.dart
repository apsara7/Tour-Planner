import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/trips_provider.dart';

class PlaceDetailView extends StatefulWidget {
  final String placeId;

  const PlaceDetailView({super.key, required this.placeId});

  @override
  State<PlaceDetailView> createState() => _PlaceDetailViewState();
}

class _PlaceDetailViewState extends State<PlaceDetailView> {
  Map<String, dynamic>? place;
  bool isLoading = true;
  String errorMessage = '';
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchPlaceDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await _apiService.getPlaceById(widget.placeId);

      if (response['status'] == 'Success') {
        setState(() {
          place = response['place'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: place != null ? _buildAddToTripButton() : null,
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
            Text("Loading place details...", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Place Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                "Failed to load place details",
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
                onPressed: fetchPlaceDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (place == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Place Details'),
        ),
        body: const Center(
          child: Text(
            "Place not found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    final List<dynamic> images = place!['images'] ?? [];
    final String name = place!['name'] ?? 'Unknown Place';

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/places'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background:
            images.isNotEmpty ? _buildImageSlider() : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildImageSlider() {
    final List<dynamic> images = place!['images'] ?? [];

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.network(
              images[index].toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 50, color: Colors.grey),
                  ),
                );
              },
            );
          },
        ),

        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),

        // Navigation arrows
        if (images.length > 1) ...[
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _currentImageIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _currentImageIndex < images.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.place, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildContent() {
    final String description = place!['description'] ?? '';
    final String province = place!['province'] ?? '';
    final String district = place!['district'] ?? '';
    final String location = place!['location'] ?? '';
    final String visitingHours = place!['visitingHours'] ?? '';
    final String entryFee = place!['entryFee'] ?? '';
    final String bestTimeToVisit = place!['bestTimeToVisit'] ?? '';
    final String transportation = place!['transportation'] ?? '';

    // Handle highlights - can be either string or array depending on API endpoint
    List<dynamic> highlights = [];
    final highlightsData = place!['highlights'];
    if (highlightsData is String && highlightsData.isNotEmpty) {
      // Convert comma-separated string to list
      highlights = highlightsData
          .split(',')
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .toList();
    } else if (highlightsData is List) {
      highlights = highlightsData;
    }

    final String mapUrl = place!['mapUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            const Text(
              'About',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Location Section
          _buildInfoSection(
            'Location',
            Icons.location_on,
            Colors.green,
            [
              if (province.isNotEmpty) 'Province: $province',
              if (district.isNotEmpty) 'District: $district',
              if (location.isNotEmpty) 'Address: $location',
            ],
          ),

          // Visit Information
          if (visitingHours.isNotEmpty ||
              entryFee.isNotEmpty ||
              bestTimeToVisit.isNotEmpty)
            _buildInfoSection(
              'Visit Information',
              Icons.access_time,
              Colors.blue,
              [
                if (visitingHours.isNotEmpty) 'Hours: $visitingHours',
                if (entryFee.isNotEmpty) 'Entry Fee: $entryFee',
                if (bestTimeToVisit.isNotEmpty) 'Best Time: $bestTimeToVisit',
              ],
            ),

          // Transportation
          if (transportation.isNotEmpty)
            _buildInfoSection(
              'Transportation',
              Icons.directions_bus,
              Colors.orange,
              [transportation],
            ),

          // Highlights
          if (highlights.isNotEmpty) _buildHighlightsSection(highlights),

          // Map Link
          if (mapUrl.isNotEmpty) _buildMapSection(mapUrl),

          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      String title, IconData icon, Color color, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHighlightsSection(List<dynamic> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text(
              'Highlights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: highlights.map((highlight) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                highlight.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMapSection(String mapUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.map, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Location on Map',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: InkWell(
            onTap: () {
              // TODO: Open map URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening map...')),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.open_in_new, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'View on Map',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAddToTripButton() {
    return Consumer<TripsProvider>(
      builder: (context, tripsProvider, child) {
        tripsProvider
            .setContext(context); // Set the context for user ID retrieval
        // Ensure we have the current trip loaded
        if (tripsProvider.currentTrip == null) {
          tripsProvider.getOrCreateDefaultTrip();
        }

        final isInTrip = tripsProvider.isPlaceInTrip(widget.placeId);
        final hasAddedToTrip = tripsProvider.hasAddedPlaceToTrip;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: hasAddedToTrip && isInTrip
                  ? ElevatedButton.icon(
                      onPressed: () => context.go('/trips'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.travel_explore),
                      label: const Text(
                        'Go to Your Trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () =>
                          _togglePlaceInTrip(tripsProvider, isInTrip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isInTrip ? Colors.red[600] : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      icon: Icon(isInTrip
                          ? Icons.location_off
                          : Icons.add_location_alt),
                      label: Text(
                        isInTrip ? 'Remove from Trip' : 'Add to Your Trip',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePlaceInTrip(
      TripsProvider tripsProvider, bool isInTrip) async {
    tripsProvider.setContext(context); // Set the context for user ID retrieval
    final placeName = place!['name'] ?? 'this place';

    try {
      bool success = false;

      if (isInTrip) {
        success = await tripsProvider.removePlaceFromTrip(widget.placeId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$placeName removed from your trip!'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      } else {
        // Ensure we have a trip before adding
        await tripsProvider.getOrCreateDefaultTrip();
        success = await tripsProvider.addPlaceToTrip(widget.placeId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$placeName added to your trip!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tripsProvider.error ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
