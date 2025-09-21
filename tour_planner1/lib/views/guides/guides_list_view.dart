import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import 'guide_detail_view.dart';

class GuidesListView extends StatefulWidget {
  const GuidesListView({super.key});

  @override
  State<GuidesListView> createState() => _GuidesListViewState();
}

class _GuidesListViewState extends State<GuidesListView> {
  List<Map<String, dynamic>> guides = [];
  List<Map<String, dynamic>> filteredGuides = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGuides();
  }

  Future<void> fetchGuides() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final apiService = ApiService();
      final guidesData = await apiService.getAllGuides();

      setState(() {
        guides = List<Map<String, dynamic>>.from(guidesData);
        filteredGuides = guides;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterGuides(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGuides = guides;
      } else {
        filteredGuides = guides.where((guide) {
          final name = (guide['guideName'] ?? '').toString().toLowerCase();
          final province =
              (guide['address']?['province'] ?? '').toString().toLowerCase();
          final city =
              (guide['address']?['city'] ?? '').toString().toLowerCase();
          final specializations =
              (guide['experience']?['specializations'] ?? [])
                  .join(' ')
                  .toLowerCase();
          final languages =
              (guide['experience']?['languages'] ?? []).join(' ').toLowerCase();
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) ||
              province.contains(searchQuery) ||
              city.contains(searchQuery) ||
              specializations.contains(searchQuery) ||
              languages.contains(searchQuery);
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
        title: const Text('Tour Guides'),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterGuides,
        decoration: InputDecoration(
          hintText: 'Search guides, locations, specializations...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _filterGuides('');
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
            Text("Loading guides...", style: TextStyle(fontSize: 16)),
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
              "Failed to load guides",
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
              onPressed: fetchGuides,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (filteredGuides.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No guides found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Try adjusting your search criteria",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredGuides.length,
      itemBuilder: (context, index) {
        final guide = filteredGuides[index];
        return _buildGuideCard(guide);
      },
    );
  }

  Widget _buildGuideCard(Map<String, dynamic> guide) {
    final String name = guide['guideName'] ?? 'Unknown Guide';
    final String province = guide['address']?['province'] ?? '';
    final String city = guide['address']?['city'] ?? '';
    final double rating =
        (guide['ratings']?['averageRating'] ?? 0.0).toDouble();
    final int totalRatings = guide['ratings']?['totalRatings'] ?? 0;
    final double hourlyRate =
        (guide['pricing']?['hourlyRate'] ?? 0.0).toDouble();
    final String currency = guide['pricing']?['currency'] ?? 'LKR';
    final List<dynamic> images = guide['images'] ?? [];
    final List<dynamic> specializations =
        guide['experience']?['specializations'] ?? [];

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
        onTap: () => _navigateToGuideDetail(guide),
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
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.person,
                                    size: 40, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person,
                                size: 40, color: Colors.grey),
                          ),
                  ),
                  // Rating badge
                  if (rating > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ],
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (city.isNotEmpty || province.isNotEmpty)
                      Text(
                        [city, province].where((s) => s.isNotEmpty).join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (specializations.isNotEmpty)
                      Text(
                        specializations.take(2).join(', '),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$currency ${hourlyRate.toStringAsFixed(0)}/hr',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),
                        ),
                        if (totalRatings > 0)
                          Text(
                            '($totalRatings)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGuideDetail(Map<String, dynamic> guide) {
    final guideId = guide['_id'];
    if (guideId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuideDetailView(guideId: guideId),
        ),
      );
    }
  }
}
