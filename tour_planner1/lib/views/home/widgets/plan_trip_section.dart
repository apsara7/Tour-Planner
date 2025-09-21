import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../places/places_list_view.dart';
import '../../guides/guides_list_view.dart';
import '../../hotels/hotels_list_view.dart';
import '../../vehicles/vehicles_list_view.dart';
import '../../../core/models/vehicle.dart'; // Fixed import path

class PlanTripSection extends StatefulWidget {
  const PlanTripSection({super.key});

  @override
  State<PlanTripSection> createState() => _PlanTripSectionState();
}

class _PlanTripSectionState extends State<PlanTripSection> {
  // Store added vehicles
  final List<Vehicle> _addedVehicles = [];

  // Add a vehicle to the trip
  void _addVehicle(Vehicle vehicle) {
    setState(() {
      _addedVehicles.add(vehicle);
    });
  }

  // Remove a vehicle from the trip
  void _removeVehicle(String vehicleId) {
    setState(() {
      _addedVehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // ✅ Fix overflow by making it scrollable
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Your Trip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- View Your Trip Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.map, color: Colors.blue, size: 40),
                title: const Text(
                  "View Your Trip",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle:
                    const Text("Check your planned destinations & timeline"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to my-trips page
                  context.go('/my-trips');
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Added Vehicles Section ---
            if (_addedVehicles.isNotEmpty) ...[
              const Text(
                'Added Vehicles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Display vehicle cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _addedVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _addedVehicles[index];
                  return _buildVehicleCard(vehicle);
                },
              ),
              const SizedBox(height: 20),
            ],

            // --- Add Options Grid ---
            GridView.count(
              shrinkWrap: true, // for scrollable Column
              physics:
                  const NeverScrollableScrollPhysics(), // disables inner scroll
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildOptionCard(
                    context, Icons.place, "Add Places", Colors.orange),
                _buildOptionCard(
                    context, Icons.people, "Add Guides", Colors.green),
                _buildOptionCard(
                    context, Icons.hotel, "Add Hotels", Colors.purple),
                _buildOptionCard(
                    context, Icons.directions_car, "Add Vehicles", Colors.teal),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable option card widget
  static Widget _buildOptionCard(
      BuildContext context, IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navigate based on card type
          if (title == "Add Places") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlacesListView(),
              ),
            );
          } else if (title == "Add Guides") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GuidesListView(),
              ),
            );
          } else if (title == "Add Hotels") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HotelsListView(),
              ),
            );
          } else if (title == "Add Vehicles") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VehiclesListView(),
              ),
            );
          } else {
            // TODO: Add navigation for other options
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title feature coming soon!'),
                backgroundColor: color,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vehicle card with remove functionality
  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(vehicle.imageUrl),
        ),
        title: Text(vehicle.name),
        subtitle: Text(
            '${vehicle.cost.toStringAsFixed(2)} per day'), // Fixed string interpolation by removing extra $
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () => _removeVehicle(vehicle.id),
        ),
      ),
    );
  }
}
