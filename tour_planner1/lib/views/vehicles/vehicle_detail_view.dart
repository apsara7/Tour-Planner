import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/vehicle_model.dart';
import '../../core/providers/trips_provider.dart';
import '../../core/services/api_service.dart';

class VehicleDetailView extends StatefulWidget {
  final String vehicleId;
  final Vehicle? vehicle;

  const VehicleDetailView({
    super.key,
    required this.vehicleId,
    this.vehicle,
  });

  @override
  State<VehicleDetailView> createState() => _VehicleDetailViewState();
}

class _VehicleDetailViewState extends State<VehicleDetailView> {
  Vehicle? _vehicle;
  bool _isLoading = true;
  String _errorMessage = '';
  int _travellersCount = 1;
  bool _withDriver = false; // Add driver option
  final TextEditingController _notesController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _vehicle = widget.vehicle;
      _isLoading = false;
    } else {
      _loadVehicleDetails();
    }
  }

  Future<void> _loadVehicleDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _apiService.getVehicleById(widget.vehicleId);
      final vehicle = Vehicle.fromJson(response['vehicle']);

      if (mounted) {
        setState(() {
          _vehicle = vehicle;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading vehicle details: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToTrip() async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);

    // Set the context for user ID retrieval
    tripsProvider.setContext(context);

    // Check if vehicle can accommodate the travellers count
    if (_travellersCount > (_vehicle?.passengerAmount ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Travellers count exceeds vehicle capacity!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get or create default trip to ensure we have a trip ID
      final trip = await tripsProvider.getOrCreateDefaultTrip();

      // Check if trip has a valid ID
      if (trip.id == null) {
        throw Exception('Trip ID is null');
      }

      await _apiService.addVehicleToTrip(
        trip.id!, // Use trip.id with null check
        widget.vehicleId,
        tripsProvider
            .currentUserId, // Use tripsProvider.currentUserId instead of tripsProvider.userId
        travellersCount: _travellersCount,
        notes: _notesController.text,
        withDriver: _withDriver, // Pass the withDriver option
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added to your trip successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to the previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Extract just the error message without the "Exception:" prefix
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage =
              errorMessage.substring(11); // Remove "Exception: " prefix
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle?.type ?? 'Vehicle Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
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
                        onPressed: _loadVehicleDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _vehicle == null
                  ? const Center(
                      child: Text(
                        'Vehicle not found',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vehicle Images
                          if (_vehicle!.images.isNotEmpty)
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(_vehicle!.images.first),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Vehicle Type
                                Text(
                                  _vehicle!.type,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Owner Info
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      _vehicle!.owner.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Vehicle Details
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        _buildDetailRow(
                                          Icons.people,
                                          'Passenger Capacity',
                                          '${_vehicle!.passengerAmount} passengers',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildDetailRow(
                                          Icons.attach_money,
                                          'Rent Price per Day',
                                          'LKR ${_vehicle!.rentPrice.toStringAsFixed(0)}',
                                        ),
                                        // Show driver cost only if it's greater than 0
                                        if (_vehicle!.driverCost > 0) ...[
                                          const SizedBox(height: 12),
                                          _buildDetailRow(
                                            Icons.local_taxi,
                                            'Driver Cost per Day',
                                            'LKR ${_vehicle!.driverCost.toStringAsFixed(0)}',
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        _buildDetailRow(
                                          Icons.check_circle,
                                          'Status',
                                          _vehicle!.status,
                                          isStatus: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Add to Trip Section
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Add to Your Trip',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const Text('Travellers:'),
                                            const SizedBox(width: 16),
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if (_travellersCount > 1) {
                                                  setState(() {
                                                    _travellersCount--;
                                                  });
                                                }
                                              },
                                            ),
                                            Text(
                                              '$_travellersCount',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                // Check if we can increase the count
                                                if (_travellersCount <
                                                    _vehicle!.passengerAmount) {
                                                  setState(() {
                                                    _travellersCount++;
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Cannot exceed vehicle capacity!'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Driver option
                                        if (_vehicle!.driverCost > 0) ...[
                                          Row(
                                            children: [
                                              const Text('With Driver:'),
                                              const SizedBox(width: 16),
                                              Switch(
                                                value: _withDriver,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _withDriver = value;
                                                  });
                                                },
                                                activeColor: Colors.teal,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        TextField(
                                          controller: _notesController,
                                          decoration: const InputDecoration(
                                            labelText: 'Notes (Optional)',
                                            border: OutlineInputBorder(),
                                          ),
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        // Cost breakdown
                                        _buildCostBreakdown(),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _addToTrip,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Add to My Trip',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isStatus = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: value.toLowerCase() == 'available'
                  ? Colors.green[100]
                  : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: value.toLowerCase() == 'available'
                    ? Colors.green[800]
                    : Colors.red[800],
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    final trip = tripsProvider.currentTrip;

    // Calculate trip duration
    int tripDays = 1;
    if (trip?.startDate != null && trip?.endDate != null) {
      tripDays = trip!.endDate!.difference(trip.startDate!).inDays +
          1; // +1 to include both start and end dates
    }

    // Calculate vehicle cost
    final vehicleCost = _vehicle!.rentPrice * tripDays;

    // Calculate driver cost if needed
    final driverCost = _withDriver ? _vehicle!.driverCost * tripDays : 0.0;

    // Calculate total cost
    final totalCost = vehicleCost + driverCost;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Vehicle Rent:'),
                Text('LKR ${vehicleCost.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration: $tripDays ${tripDays == 1 ? 'day' : 'days'}'),
                const Text(''),
              ],
            ),
            if (_withDriver) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Driver Cost:'),
                  Text('LKR ${driverCost.toStringAsFixed(2)}'),
                ],
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'LKR ${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
