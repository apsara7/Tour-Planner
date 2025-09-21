class Vehicle {
  final String id;
  final String name;
  final double cost;
  final String imageUrl;

  Vehicle({
    required this.id,
    required this.name,
    required this.cost,
    required this.imageUrl,
  });
}

// Sample vehicles for testing
final List<Vehicle> sampleVehicles = [
  Vehicle(
    id: 'v1',
    name: 'Sedan',
    cost: 50.0,
    imageUrl: 'https://example.com/sedan.jpg',
  ),
  Vehicle(
    id: 'v2',
    name: 'SUV',
    cost: 75.0,
    imageUrl: 'https://example.com/suv.jpg',
  ),
];
