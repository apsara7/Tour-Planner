import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/trips_provider.dart';
import '../../core/models/place_model.dart';
import '../../core/models/guide_model.dart';
import '../../core/models/trip_model.dart';
import '../../core/models/vehicle_model.dart';
import '../../core/services/api_service.dart';

class MyTripsView extends StatefulWidget {
  const MyTripsView({super.key});

  @override
  State<MyTripsView> createState() => _MyTripsViewState();
}

class _MyTripsViewState extends State<MyTripsView> {
  List<Place>? tripPlaces;
  List<Guide>? tripGuides;
  List<dynamic>? tripHotels;
  List<dynamic>? tripVehicles;
  bool isLoadingPlaces = false;
  bool isLoadingGuides = false;
  bool isLoadingHotels = false;
  bool isLoadingVehicles = false;

  @override
  void initState() {
    super.initState();
    tripVehicles = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTripData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTripData() async {
    await Future.wait([
      _loadTripPlaces(),
      _loadTripGuides(),
      _loadTripHotels(),
      _loadTripVehicles(),
    ]);
  }

  Future<void> _refreshAllTripData() async {
    await Future.wait([
      _loadTripPlaces(),
      _loadTripGuides(),
      _loadTripHotels(),
      _loadTripVehicles(),
    ]);
  }

  Future<void> _loadTripGuides() async {
    if (mounted) {
      setState(() {
        isLoadingGuides = true;
      });
    }

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.setContext(context);

    // Ensure we have a current trip first
    if (tripsProvider.currentTrip == null) {
      try {
        await tripsProvider.getOrCreateDefaultTrip();
      } catch (e) {
        // Handle error silently
      }
    }

    final guides = await tripsProvider.getTripGuides();

    if (mounted) {
      setState(() {
        tripGuides = guides;
        isLoadingGuides = false;
      });
    }
  }

  Future<void> _loadTripHotels() async {
    if (mounted) {
      setState(() {
        isLoadingHotels = true;
      });
    }

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.setContext(context);

    // Ensure we have a current trip first
    if (tripsProvider.currentTrip == null) {
      try {
        await tripsProvider.getOrCreateDefaultTrip();
      } catch (e) {
        // Handle error silently
      }
    }

    final hotels = await tripsProvider.getTripHotels();

    if (mounted) {
      setState(() {
        tripHotels = hotels;
        isLoadingHotels = false;
      });
    }
  }

  Future<void> _loadTripPlaces() async {
    if (mounted) {
      setState(() {
        isLoadingPlaces = true;
      });
    }

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.setContext(context);

    // Ensure we have a current trip first
    if (tripsProvider.currentTrip == null) {
      try {
        await tripsProvider.getOrCreateDefaultTrip();
      } catch (e) {
        // Handle error silently
      }
    }

    final places = await tripsProvider.getTripPlaces();

    if (mounted) {
      setState(() {
        tripPlaces = places;
        isLoadingPlaces = false;
      });
    }
  }

  Future<void> _loadTripVehicles() async {
    if (mounted) {
      setState(() {
        isLoadingVehicles = true;
      });
    }

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.setContext(context);

    // Ensure we have a current trip first
    if (tripsProvider.currentTrip == null) {
      try {
        await tripsProvider.getOrCreateDefaultTrip();
      } catch (e) {
        // Handle error silently
      }
    }

    // Use the vehicles data that's already embedded in the trip object
    final currentTrip = tripsProvider.currentTrip;
    List<dynamic> vehicles = [];

    if (currentTrip != null) {
      vehicles = currentTrip.vehicles;
    }

    if (mounted) {
      setState(() {
        tripVehicles = vehicles;
        isLoadingVehicles = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sri Lanka Trip'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/plan-trip'),
        ),
        actions: [
          IconButton(
            onPressed: _loadTripData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<TripsProvider>(
        builder: (context, tripsProvider, child) {
          if (isLoadingPlaces ||
              isLoadingGuides ||
              isLoadingHotels ||
              isLoadingVehicles) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Loading your trip data...'),
                ],
              ),
            );
          }

          if ((tripPlaces == null || tripPlaces!.isEmpty) &&
              (tripGuides == null || tripGuides!.isEmpty) &&
              (tripHotels == null || tripHotels!.isEmpty) &&
              (tripVehicles == null || tripVehicles!.isEmpty)) {
            return _buildEmptyState();
          }

          return _buildTripContent(tripsProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.luggage_outlined,
              size: 80,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your trip is empty',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start planning your Sri Lanka adventure!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/places'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            icon: const Icon(Icons.place, size: 20),
            label: const Text(
              'Explore Places',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripContent(TripsProvider tripsProvider) {
    final currentTrip = tripsProvider.currentTrip;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip summary card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flight_takeoff,
                            color: Colors.green.shade700, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          currentTrip?.name ?? 'My Sri Lanka Trip',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (currentTrip?.description?.isNotEmpty == true)
                    Text(
                      currentTrip!.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Stats grid
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.place,
                            '${tripPlaces?.length ?? 0}',
                            'Places',
                            Colors.green.shade700,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.person,
                            '${tripGuides?.length ?? 0}',
                            'Guides',
                            Colors.blue.shade700,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.hotel,
                            '${tripHotels?.length ?? 0}',
                            'Hotels',
                            Colors.purple.shade700,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.directions_car,
                            '${tripVehicles?.length ?? 0}',
                            'Vehicles',
                            Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Trip dates section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.blue.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trip Dates',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentTrip?.getDateRange() ?? 'Dates not set',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              _showDatePicker(currentTrip!, tripsProvider),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                                color: Colors.blue.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Travellers count section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people,
                            color: Colors.orange.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Travellers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currentTrip?.travellersCount ?? 1} traveller${(currentTrip?.travellersCount ?? 1) != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _showTravellersCountPicker(
                              currentTrip!, tripsProvider),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                                color: Colors.orange.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Budget section
          if (currentTrip != null) _buildBudgetSection(currentTrip!),

          const SizedBox(height: 24),

          // Places section
          _buildSectionHeader(
            Icons.place,
            'Places to Visit',
            Colors.green.shade700,
            tripPlaces?.length ?? 0,
          ),

          const SizedBox(height: 16),

          // Places list
          if (tripPlaces?.isNotEmpty == true)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tripPlaces!.length,
              itemBuilder: (context, index) {
                final place = tripPlaces![index];
                return _buildPlaceCard(place, tripsProvider);
              },
            )
          else
            _buildEmptySection(
                'No places added yet', Icons.place, Colors.green),

          const SizedBox(height: 24),

          // Guides section
          _buildSectionHeader(
            Icons.person,
            'Tour Guides',
            Colors.blue.shade700,
            tripGuides?.length ?? 0,
          ),

          const SizedBox(height: 16),

          // Guides list
          if (tripGuides?.isNotEmpty == true)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tripGuides!.length,
              itemBuilder: (context, index) {
                final guide = tripGuides![index];
                return _buildGuideCard(guide, tripsProvider);
              },
            )
          else
            _buildEmptySection(
                'No guides added yet', Icons.person, Colors.blue),

          const SizedBox(height: 24),

          // Hotels section
          _buildSectionHeader(
            Icons.hotel,
            'Hotels',
            Colors.purple.shade700,
            tripHotels?.length ?? 0,
          ),

          const SizedBox(height: 16),

          // Hotels list
          if (tripHotels?.isNotEmpty == true)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tripHotels!.length,
              itemBuilder: (context, index) {
                final hotel = tripHotels![index];
                return _buildHotelCard(hotel, tripsProvider);
              },
            )
          else
            _buildEmptySection(
                'No hotels added yet', Icons.hotel, Colors.purple),

          const SizedBox(height: 24),

          // Vehicles section
          _buildSectionHeader(
            Icons.directions_car,
            'Vehicles',
            Colors.teal.shade700,
            tripVehicles?.length ?? 0,
          ),

          const SizedBox(height: 16),

          // Vehicles list
          if (tripVehicles != null && tripVehicles!.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tripVehicles!.length,
              itemBuilder: (context, index) {
                final vehicle = tripVehicles![index];
                return _buildVehicleCard(vehicle, tripsProvider);
              },
            )
          else
            _buildEmptySection(
                tripVehicles == null
                    ? 'Loading vehicles...'
                    : 'No vehicles added yet',
                Icons.directions_car,
                Colors.teal),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      IconData icon, String title, Color color, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: color.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place, TripsProvider tripsProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/places/${place.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Place image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: place.images.isNotEmpty
                    ? Image.network(
                        place.images.first,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.place,
                                color: Colors.grey.shade600, size: 30),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.place,
                            color: Colors.grey.shade600, size: 30),
                      ),
              ),

              const SizedBox(width: 16),

              // Place details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (place.province?.isNotEmpty == true ||
                        place.district?.isNotEmpty == true)
                      Text(
                        [place.province, place.district]
                            .where((s) => s?.isNotEmpty == true)
                            .join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (place.entryFee?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          place.entryFee!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: () => _removePlaceFromTrip(place, tripsProvider),
                icon: Icon(Icons.close, color: Colors.red.shade400),
                tooltip: 'Remove from trip',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removePlaceFromTrip(
      Place place, TripsProvider tripsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Place'),
        content: Text('Remove ${place.name} from your trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await tripsProvider.removePlaceFromTrip(place.id);
      _refreshAllTripData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${place.name} removed from your trip'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDatePicker(Trip trip, TripsProvider tripsProvider) async {
    DateTime? startDate = trip.startDate;
    DateTime? endDate = trip.endDate;

    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Trip Dates'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start Date'),
                subtitle: Text(
                    startDate != null ? _formatDate(startDate!) : 'Not set'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setState(() {
                      startDate = date;
                      if (endDate != null && endDate!.isBefore(date)) {
                        endDate = date;
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('End Date'),
                subtitle:
                    Text(endDate != null ? _formatDate(endDate!) : 'Not set'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setState(() {
                      endDate = date;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'startDate': startDate,
                'endDate': endDate,
              }),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && trip.id != null) {
      final success = await tripsProvider.updateTripDates(
        trip.id!,
        startDate: result['startDate'],
        endDate: result['endDate'],
      );

      if (success) {
        _refreshAllTripData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Trip dates updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tripsProvider.error ?? 'Failed to update dates'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildBudgetSection(Trip trip) {
    // Convert LKR to USD (using approximate exchange rate)
    double lkrToUsd(double lkrAmount) {
      const exchangeRate = 290.0;
      return lkrAmount / exchangeRate;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet,
                      color: Colors.green.shade700, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Trip Budget',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Entry fees section
            _buildBudgetItem(
              Icons.location_on,
              'Entry Fees',
              trip.getFormattedEntriesTotal(),
              Colors.green.shade700,
              Colors.green.shade50,
            ),

            const SizedBox(height: 16),

            // Guides section
            _buildBudgetItem(
              Icons.person,
              'Guide Fees',
              trip.getFormattedGuidesTotal(),
              Colors.blue.shade700,
              Colors.blue.shade50,
            ),

            const SizedBox(height: 16),

            // Hotels section
            _buildBudgetItem(
              Icons.hotel,
              'Hotel Costs',
              trip.getFormattedHotelsTotal(),
              Colors.purple.shade700,
              Colors.purple.shade50,
            ),

            const SizedBox(height: 16),

            // Vehicles section
            _buildBudgetItem(
              Icons.directions_car,
              'Vehicle Costs',
              trip.getFormattedVehiclesTotal(),
              Colors.teal.shade700,
              Colors.teal.shade50,
            ),

            const SizedBox(height: 16),

            // Other expenses section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt,
                          color: Colors.orange.shade700, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Other Expenses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => _showOtherExpensesDialog(trip),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'Edit',
                          style: TextStyle(
                              color: Colors.orange.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LKR ${trip.otherExpenses.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total budget
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on,
                          color: Colors.grey.shade700, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Total Budget',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trip.getFormattedBudget(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Add USD conversion
                  Text(
                    'USD ${lkrToUsd(trip.totalBudget).toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} (approx.)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trip.travellersCount > 1) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trip.getPerPersonBudget(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildBudgetItem(
      IconData icon, String title, String amount, Color color, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTravellersCountPicker(
      Trip trip, TripsProvider tripsProvider) async {
    int selectedCount = trip.travellersCount;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Number of Travellers'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many people will be traveling?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: selectedCount > 1
                        ? () => setState(() => selectedCount--)
                        : null,
                    icon: Icon(Icons.remove_circle_outline,
                        color: selectedCount > 1
                            ? Colors.orange.shade700
                            : Colors.grey),
                    iconSize: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      selectedCount.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: selectedCount < 50
                        ? () => setState(() => selectedCount++)
                        : null,
                    icon: Icon(Icons.add_circle_outline,
                        color: selectedCount < 50
                            ? Colors.orange.shade700
                            : Colors.grey),
                    iconSize: 40,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Maximum 50 travellers',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedCount),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != trip.travellersCount && trip.id != null) {
      final success = await tripsProvider.updateTripDetails(
        trip.id!,
        travellersCount: result,
      );

      if (success) {
        _refreshAllTripData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Travellers count updated successfully'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                tripsProvider.error ?? 'Failed to update travellers count'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showOtherExpensesDialog(Trip trip) async {
    final controller = TextEditingController(
      text: trip.otherExpenses > 0 ? trip.otherExpenses.toString() : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Other Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter additional expenses (hotels, food, transport, etc.)'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (LKR)',
                border: OutlineInputBorder(),
                prefixText: 'LKR ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              Navigator.pop(context, amount);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && trip.id != null) {
      final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
      final success = await tripsProvider.updateTripDetails(
        trip.id!,
        otherExpenses: result,
      );

      if (success) {
        _refreshAllTripData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Other expenses updated successfully'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tripsProvider.error ?? 'Failed to update expenses'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    controller.dispose();
  }

  Widget _buildGuideCard(Guide guide, TripsProvider tripsProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/guides/${guide.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Guide image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: guide.images.isNotEmpty
                    ? Image.network(
                        guide.images.first,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.person,
                                color: Colors.grey.shade600, size: 30),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person,
                            color: Colors.grey.shade600, size: 30),
                      ),
              ),

              const SizedBox(width: 16),

              // Guide details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.guideName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (guide.address.city.isNotEmpty ||
                        guide.address.province.isNotEmpty)
                      Text(
                        [guide.address.city, guide.address.province]
                            .where((s) => s.isNotEmpty)
                            .join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LKR ${guide.pricing.dailyRate.toStringAsFixed(0)}/day',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (guide.ratings.averageRating > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${guide.ratings.averageRating.toStringAsFixed(1)} (${guide.ratings.totalRatings})',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: () => _removeGuideFromTrip(guide, tripsProvider),
                icon: Icon(Icons.close, color: Colors.red.shade400),
                tooltip: 'Remove from trip',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeGuideFromTrip(
      Guide guide, TripsProvider tripsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Guide'),
        content: Text('Remove ${guide.guideName} from your trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await tripsProvider.removeGuideFromTrip(guide.id);
      _refreshAllTripData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${guide.guideName} removed from your trip'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildHotelCard(dynamic hotelData, TripsProvider tripsProvider) {
    // Extract hotel information from the data
    final hotelId = hotelData['hotelId'] ?? hotelData['_id'] ?? '';
    final hotelName =
        hotelData['hotelName'] ?? hotelData['name'] ?? 'Unknown Hotel';
    final cityName = hotelData['city'] ?? '';
    final packageName =
        hotelData['packageName'] ?? hotelData['roomType'] ?? 'Room Package';
    final totalPrice = hotelData['totalPrice'] ?? 0.0;
    final checkInDate = hotelData['checkInDate'] != null
        ? DateTime.parse(hotelData['checkInDate'])
        : null;
    final checkOutDate = hotelData['checkOutDate'] != null
        ? DateTime.parse(hotelData['checkOutDate'])
        : null;
    final roomsBooked = hotelData['roomsBooked'] ?? 1;
    final guestCount = hotelData['guestCount'] ?? 1;

    // Format dates
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return '${date.day}/${date.month}/${date.year}';
    }

    // Calculate nights
    int nights = 0;
    if (checkInDate != null && checkOutDate != null) {
      nights = checkOutDate.difference(checkInDate).inDays;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hotelId.isNotEmpty ? () => context.go('/hotels/$hotelId') : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Hotel image placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hotel, color: Colors.grey.shade600, size: 30),
              ),

              const SizedBox(width: 16),

              // Hotel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (cityName.isNotEmpty)
                      Text(
                        cityName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        packageName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.purple.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (nights > 0)
                      Text(
                        '$nights night${nights > 1 ? 's' : ''}, $roomsBooked room${roomsBooked > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Text(
                      'LKR ${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (checkInDate != null && checkOutDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${formatDate(checkInDate)} - ${formatDate(checkOutDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: () => _removeHotelFromTrip(hotelId, tripsProvider),
                icon: Icon(Icons.close, color: Colors.red.shade400),
                tooltip: 'Remove from trip',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeHotelFromTrip(
      String hotelId, TripsProvider tripsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Hotel'),
        content: const Text('Remove this hotel booking from your trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await tripsProvider.removeHotelFromTrip(hotelId);
      _refreshAllTripData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hotel removed from your trip'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildVehicleCard(dynamic vehicleData, TripsProvider tripsProvider) {
    // Extract vehicle information from the embedded data
    // Extract the vehicle ID (this is what we use to fetch details)
    final vehicleId = vehicleData is Map
        ? (vehicleData['vehicleId'] ?? vehicleData['_id'] ?? '')
        : '';

    // Extract cost information directly from the embedded data
    final dailyCost =
        vehicleData is Map ? (vehicleData['dailyCost'] ?? 0.0) : 0.0;

    final totalTripCost =
        vehicleData is Map ? (vehicleData['totalTripCost'] ?? 0.0) : 0.0;

    // Extract other information
    final travellersCount =
        vehicleData is Map ? (vehicleData['travellersCount'] ?? 1) : 1;

    final addedAtStr = vehicleData is Map ? vehicleData['addedAt'] : null;
    final addedAt = addedAtStr != null ? DateTime.parse(addedAtStr) : null;

    // Format date
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return '${date.day}/${date.month}/${date.year}';
    }

    // Use a placeholder name since we don't have the actual vehicle details in the response
    final vehicleType = "Vehicle"; // Simple placeholder

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: vehicleId.isNotEmpty
            ? () => context.go('/vehicles/$vehicleId')
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vehicle image placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_car,
                    color: Colors.grey.shade600, size: 30),
              ),

              const SizedBox(width: 16),

              // Vehicle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LKR ${dailyCost.toStringAsFixed(2)}/day',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total: LKR ${totalTripCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (addedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Added: ${formatDate(addedAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: () =>
                    _removeVehicleFromTrip(vehicleId, tripsProvider),
                icon: Icon(Icons.close, color: Colors.red.shade400),
                tooltip: 'Remove from trip',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeVehicleFromTrip(
      String vehicleId, TripsProvider tripsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Vehicle'),
        content: const Text('Remove this vehicle from your trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await tripsProvider.removeVehicleFromTrip(vehicleId);

      if (result) {
        // Refresh the trip data to get updated vehicles list
        await tripsProvider.getOrCreateDefaultTrip();
        await _refreshAllTripData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vehicle removed from your trip'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tripsProvider.error ?? 'Failed to remove vehicle'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                child: const Text(
                  'Add to Trip',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.place, color: Colors.green.shade700, size: 28),
                ),
                title: const Text(
                  'Add Places',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Explore and add tourist places to your trip',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/places');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.person, color: Colors.blue.shade700, size: 28),
                ),
                title: const Text(
                  'Add Guides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Find and hire local tour guides',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/guides');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.hotel,
                      color: Colors.purple.shade700, size: 28),
                ),
                title: const Text(
                  'Add Hotels',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Book accommodations for your trip',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/hotels');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.directions_car,
                      color: Colors.teal.shade700, size: 28),
                ),
                title: const Text(
                  'Add Vehicles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Add vehicles for your trip',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/vehicles');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
