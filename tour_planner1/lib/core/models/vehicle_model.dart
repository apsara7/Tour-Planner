class Vehicle {
  final String id;
  final String type;
  final int passengerAmount;
  final VehicleOwner owner;
  final double rentPrice;
  final double driverCost; // Add driver cost field
  final String status;
  final List<String> images;

  Vehicle({
    required this.id,
    required this.type,
    required this.passengerAmount,
    required this.owner,
    required this.rentPrice,
    required this.driverCost, // Add driver cost parameter
    required this.status,
    required this.images,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      passengerAmount: json['passengerAmount'] ?? 0,
      owner: VehicleOwner.fromJson(json['owner'] ?? {}),
      rentPrice: (json['rentPrice'] ?? 0).toDouble(),
      driverCost: (json['driverCost'] ?? 0).toDouble(), // Parse driver cost
      status: json['status'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'passengerAmount': passengerAmount,
      'owner': owner.toJson(),
      'rentPrice': rentPrice,
      'driverCost': driverCost, // Include driver cost in JSON
      'status': status,
      'images': images,
    };
  }
}

class VehicleOwner {
  final String name;
  final String phone;
  final String email;

  VehicleOwner({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory VehicleOwner.fromJson(Map<String, dynamic> json) {
    return VehicleOwner(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
