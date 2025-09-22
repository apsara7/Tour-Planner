import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/vehicle_model.dart';
import '../../core/services/api_service.dart';
import 'vehicle_detail_view.dart';

class VehiclesListView extends StatefulWidget {
  const VehiclesListView({super.key});

  @override
  State<VehiclesListView> createState() => _VehiclesListViewState();
}

class _VehiclesListViewState extends State<VehiclesListView> {
  final ApiService _apiService = ApiService();
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _apiService.getAllVehicles();

      // Parse vehicles from response
      final vehicles = response
          .map<Vehicle>((vehicle) => Vehicle.fromJson(vehicle))
          .toList();

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _filteredVehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading vehicles: $e';
        });
      }
    }
  }

  void _filterVehicles() {
    setState(() {
      _filteredVehicles = _vehicles.where((vehicle) {
        final matchesSearch = vehicle.type
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            vehicle.owner.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        // Only show available vehicles
        final isAvailable = vehicle.status.toLowerCase() == 'available';

        return matchesSearch && isAvailable;
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search vehicles...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) => _filterVehicles(),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to vehicle detail view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailView(
                vehicleId: vehicle.id,
                vehicle: vehicle,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                image: vehicle.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(vehicle.images.first),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      )
                    : null,
                color: vehicle.images.isEmpty ? Colors.grey[300] : null,
              ),
              child: vehicle.images.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.directions_car,
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
                  // Vehicle Type
                  Text(
                    vehicle.type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Owner
                  Text(
                    vehicle.owner.name,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Passenger Capacity
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.grey, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${vehicle.passengerAmount} passengers',
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LKR ${vehicle.rentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          vehicle.status,
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
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
        title: const Text('Vehicles'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/plan-trip'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
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
                              onPressed: _loadVehicles,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredVehicles.isEmpty
                        ? const Center(
                            child: Text(
                              'No vehicles found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 vehicles per row
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  0.75, // Further reduced aspect ratio
                            ),
                            itemCount: _filteredVehicles.length,
                            itemBuilder: (context, index) {
                              return _buildVehicleCard(
                                  _filteredVehicles[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
