import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../../core/services/api_service.dart';
import '../../core/models/guide_model.dart';
import '../../core/providers/trips_provider.dart';

class GuideDetailView extends StatefulWidget {
  final String guideId;

  const GuideDetailView({super.key, required this.guideId});

  @override
  State<GuideDetailView> createState() => _GuideDetailViewState();
}

class _GuideDetailViewState extends State<GuideDetailView> {
  Map<String, dynamic>? guide;
  bool isLoading = true;
  String errorMessage = '';
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchGuideDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchGuideDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final apiService = ApiService();
      final response = await apiService.getGuideById(widget.guideId);

      if (response['status'] == 'Success') {
        setState(() {
          guide = response['guide'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load guide details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Guide Details'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text('Loading guide details...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Guide Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                "Failed to load guide details",
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
                onPressed: fetchGuideDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (guide == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Guide Details'),
        ),
        body: const Center(
          child: Text(
            "Guide not found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _buildAddToTripButton(),
    );
  }

  Widget _buildSliverAppBar() {
    final List<dynamic> images = guide!['images'] ?? [];
    final String name = guide!['guideName'] ?? 'Guide';

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(name),
        background:
            images.isNotEmpty ? _buildImageSlider(images) : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildImageSlider(List<dynamic> images) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              images[index].toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            );
          },
        ),
        if (images.length > 1) ...[
          // Page indicator
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 12 : 8,
                  height: _currentImageIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          // Navigation arrows
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
        child: Icon(Icons.person, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildContent() {
    final String description = guide!['description'] ?? '';
    final String bio = guide!['bio'] ?? '';
    final Map<String, dynamic> experience = guide!['experience'] ?? {};
    final Map<String, dynamic> pricing = guide!['pricing'] ?? {};
    final Map<String, dynamic> ratings = guide!['ratings'] ?? {};
    final Map<String, dynamic> availability = guide!['availability'] ?? {};
    final Map<String, dynamic> address = guide!['address'] ?? {};

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSection(ratings),
          const SizedBox(height: 20),
          _buildPricingSection(pricing),
          const SizedBox(height: 20),
          _buildExperienceSection(experience),
          const SizedBox(height: 20),
          _buildLocationSection(address),
          const SizedBox(height: 20),
          _buildAvailabilitySection(availability),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildDescriptionSection(description),
          ],
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildBioSection(bio),
          ],
          const SizedBox(height: 100), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildRatingSection(Map<String, dynamic> ratings) {
    final double averageRating = (ratings['averageRating'] ?? 0.0).toDouble();
    final int totalRatings = ratings['totalRatings'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalRatings reviews',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            _buildStarRating(averageRating),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
                  ? Icons.star_half
                  : Icons.star_outline,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildPricingSection(Map<String, dynamic> pricing) {
    final double hourlyRate = (pricing['hourlyRate'] ?? 0.0).toDouble();
    final double dailyRate = (pricing['dailyRate'] ?? 0.0).toDouble();
    final String currency = pricing['currency'] ?? 'LKR';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$currency ${hourlyRate.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'per hour',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$currency ${dailyRate.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'per day',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection(Map<String, dynamic> experience) {
    final int yearsOfExperience = experience['yearsOfExperience'] ?? 0;
    final List<dynamic> specializations = experience['specializations'] ?? [];
    final List<dynamic> languages = experience['languages'] ?? [];
    final List<dynamic> certifications = experience['certifications'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experience & Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.work, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text('$yearsOfExperience years of experience'),
              ],
            ),
            if (specializations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.star, color: Colors.purple[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Specializations:'),
                        Wrap(
                          spacing: 8,
                          children: specializations.map<Widget>((spec) {
                            return Chip(
                              label: Text(spec.toString()),
                              backgroundColor: Colors.purple[50],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (languages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.language, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Languages:'),
                        Wrap(
                          spacing: 8,
                          children: languages.map<Widget>((lang) {
                            return Chip(
                              label: Text(lang.toString()),
                              backgroundColor: Colors.blue[50],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> address) {
    final String city = address['city'] ?? '';
    final String province = address['province'] ?? '';
    final String street = address['street'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('$street, $city, $province'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(Map<String, dynamic> availability) {
    final bool isAvailable = availability['isAvailable'] ?? true;
    final List<dynamic> workingDays = availability['workingDays'] ?? [];
    final Map<String, dynamic> workingHours =
        availability['workingHours'] ?? {};
    final String startTime = workingHours['start'] ?? '09:00';
    final String endTime = workingHours['end'] ?? '18:00';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isAvailable ? 'Available' : 'Not Available',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (workingDays.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Working Days: ${workingDays.join(', ')}'),
            ],
            const SizedBox(height: 8),
            Text('Working Hours: $startTime - $endTime'),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(description),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About the Guide',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(bio),
          ],
        ),
      ),
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

        final isAdded = tripsProvider.isGuideInTrip(widget.guideId);
        final hasAddedToTrip = tripsProvider.hasAddedGuideToTrip;

        return FloatingActionButton.extended(
          onPressed: () => _handleAddToTrip(tripsProvider, isAdded),
          backgroundColor: isAdded ? Colors.red : Colors.green,
          foregroundColor: Colors.white,
          icon: Icon(isAdded ? Icons.remove : Icons.add),
          label: Text(isAdded ? 'Remove from Trip' : 'Add to Trip'),
        );
      },
    );
  }

  Future<void> _handleAddToTrip(
      TripsProvider tripsProvider, bool isAdded) async {
    tripsProvider.setContext(context); // Set the context for user ID retrieval
    if (kDebugMode) {
      print(
          '_handleAddToTrip called with isAdded: $isAdded, guideId: ${widget.guideId}');
    }

    if (isAdded) {
      // Remove guide from trip
      if (kDebugMode) {
        print('Removing guide from trip');
      }
      final success = await tripsProvider.removeGuideFromTrip(widget.guideId);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guide removed from trip'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tripsProvider.error ?? 'Failed to remove guide'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Show dialog to configure working hours before adding
      if (kDebugMode) {
        print('Showing add guide dialog');
      }
      if (context.mounted) {
        _showAddGuideDialog(tripsProvider);
      }
    }
  }

  void _showAddGuideDialog(TripsProvider tripsProvider) {
    final Map<String, dynamic> pricing = guide!['pricing'] ?? {};
    final Map<String, dynamic> availability = guide!['availability'] ?? {};
    final Map<String, dynamic> workingHours =
        availability['workingHours'] ?? {};

    final double hourlyRate = (pricing['hourlyRate'] ?? 0.0).toDouble();
    final double dailyRate = (pricing['dailyRate'] ?? 0.0).toDouble();

    // Use guide's default working hours
    final String startTime = workingHours['start'] ?? '09:00';
    final String endTime = workingHours['end'] ?? '18:00';
    // Don't calculate hours - not used in cost calculation

    String notes = '';

    // Store the original context to use for trips provider
    final originalContext = context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get trip duration
            final currentTrip = tripsProvider.currentTrip;
            int tripDays = 1;
            String tripDurationText = 'Trip dates not set';

            if (currentTrip?.startDate != null &&
                currentTrip?.endDate != null) {
              tripDays = currentTrip!.endDate!
                      .difference(currentTrip.startDate!)
                      .inDays +
                  1;
              tripDurationText =
                  '${currentTrip.startDate!.day}/${currentTrip.startDate!.month} - ${currentTrip.endDate!.day}/${currentTrip.endDate!.month} ($tripDays days)';
            }

            // Calculate costs using guide's daily rate (not calculated from hours)
            final dailyCost = dailyRate; // Use the guide's daily rate directly
            final totalTripCost = dailyCost * tripDays;

            return AlertDialog(
              title: const Text('Add Guide to Trip'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip duration info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trip Duration:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(tripDurationText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Guide's working hours info (read-only)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Guide\'s Working Hours:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('$startTime - $endTime'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Notes input
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Any special requirements...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        notes = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Cost breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Daily Amount:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'LKR ${dailyCost.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Trip Cost ($tripDays days):',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'LKR ${totalTripCost.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Additional hours will be charged at LKR ${hourlyRate.toStringAsFixed(0)}/hour',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Use the original context instead of dialog context
                    tripsProvider.setContext(originalContext);

                    final workingHoursData = {
                      'start': startTime,
                      'end': endTime,
                      // Don't send hoursPerDay - backend will ignore it anyway
                    };

                    if (kDebugMode) {
                      print('Add to trip button pressed');
                      print('Guide ID: ${widget.guideId}');
                      print('Notes: $notes');
                      print('Working hours: $workingHoursData');
                    }

                    // Set the context again right before calling addGuideToTrip
                    tripsProvider.setContext(originalContext);
                    final success = await tripsProvider.addGuideToTrip(
                      widget.guideId,
                      notes: notes.isNotEmpty ? notes : null,
                      workingHours: workingHoursData,
                    );

                    if (kDebugMode) {
                      print('addGuideToTrip result: $success');
                    }

                    if (success) {
                      if (originalContext.mounted) {
                        ScaffoldMessenger.of(originalContext).showSnackBar(
                          const SnackBar(
                            content: Text('Guide added to trip successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (originalContext.mounted) {
                        ScaffoldMessenger.of(originalContext).showSnackBar(
                          SnackBar(
                            content: Text(tripsProvider.error ??
                                'Failed to add guide to trip'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Trip'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
