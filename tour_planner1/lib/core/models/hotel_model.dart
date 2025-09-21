class Hotel {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String phone;
  final String email;
  final List<String> images;
  final List<String> amenities;
  final HotelRatings ratings;
  final List<HotelPackage> packages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.images,
    required this.amenities,
    required this.ratings,
    required this.packages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Handle different field names from backend
    final hotelData = json['hotel'] ?? json;

    return Hotel(
      id: hotelData['_id'] ?? hotelData['id'] ?? '',
      name: hotelData['hotelName'] ?? '',
      description: hotelData['description'] ?? '',
      city:
          hotelData['address'] is Map ? hotelData['address']['city'] ?? '' : '',
      address: hotelData['address'] is Map
          ? hotelData['address']['street'] ?? ''
          : '',
      phone: hotelData['contactDetails'] is Map
          ? hotelData['contactDetails']['phone'] ?? ''
          : '',
      email: hotelData['contactDetails'] is Map
          ? hotelData['contactDetails']['email'] ?? ''
          : '',
      images: List<String>.from(
          hotelData['images'] is List ? hotelData['images'] : []),
      amenities: List<String>.from(
          hotelData['facilities'] is List ? hotelData['facilities'] : []),
      ratings: HotelRatings.fromJson({
        'overall': hotelData['rating'] ?? 3.0,
        'totalReviews': 0,
        'cleanliness': 0.0,
        'service': 0.0,
        'location': 0.0,
        'valueForMoney': 0.0,
      }),
      packages: (hotelData['roomPackages'] as List<dynamic>?)
              ?.map((package) => HotelPackage.fromJson(package))
              .toList() ??
          [],
      createdAt: hotelData['createdAt'] != null
          ? DateTime.parse(hotelData['createdAt'])
          : DateTime.now(),
      updatedAt: hotelData['updatedAt'] != null
          ? DateTime.parse(hotelData['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hotelName': name,
      'description': description,
      'address': {
        'city': city,
        'street': address,
      },
      'contactDetails': {
        'phone': phone,
        'email': email,
      },
      'images': images,
      'facilities': amenities,
      'rating': ratings.overall,
      'roomPackages': packages.map((package) => package.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class HotelRatings {
  final double overall;
  final int totalReviews;
  final double cleanliness;
  final double service;
  final double location;
  final double valueForMoney;

  HotelRatings({
    required this.overall,
    required this.totalReviews,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.valueForMoney,
  });

  factory HotelRatings.fromJson(Map<String, dynamic> json) {
    return HotelRatings(
      overall: _parseDouble(json['overall']) ?? 3.0,
      totalReviews: json['totalReviews'] ?? 0,
      cleanliness: _parseDouble(json['cleanliness']) ?? 0.0,
      service: _parseDouble(json['service']) ?? 0.0,
      location: _parseDouble(json['location']) ?? 0.0,
      valueForMoney: _parseDouble(json['valueForMoney']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'totalReviews': totalReviews,
      'cleanliness': cleanliness,
      'service': service,
      'location': location,
      'valueForMoney': valueForMoney,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class HotelPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final int roomCapacity;
  final int availableRooms;
  final int totalRooms;
  final List<String> includedServices;
  final bool isActive;
  final List<String> images;
  final String status;

  HotelPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.roomCapacity,
    required this.availableRooms,
    required this.totalRooms,
    required this.includedServices,
    required this.isActive,
    required this.images,
    required this.status,
  });

  factory HotelPackage.fromJson(Map<String, dynamic> json) {
    return HotelPackage(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['packageName'] ?? json['roomType'] ?? '',
      description: json['description'] ?? '',
      price: HotelRatings._parseDouble(json['price']) ?? 0.0,
      roomCapacity: json['capacity'] ?? 1,
      availableRooms: json['availableRooms'] ?? 0,
      totalRooms: json['totalRooms'] ?? 0,
      includedServices:
          List<String>.from(json['amenities'] is List ? json['amenities'] : []),
      isActive: json['status'] == 'active',
      images: List<String>.from(json['images'] is List ? json['images'] : []),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'packageName': name,
      'description': description,
      'price': price,
      'capacity': roomCapacity,
      'availableRooms': availableRooms,
      'totalRooms': totalRooms,
      'amenities': includedServices,
      'status': status,
      'images': images,
    };
  }

  bool get isValidForBooking {
    final now = DateTime.now();
    return isActive && availableRooms > 0 && status == 'active';
  }

  int calculateMaxRoomsForGuests(int guestCount) {
    if (roomCapacity <= 0) return 0;
    final roomsNeeded = (guestCount / roomCapacity).ceil();
    return roomsNeeded <= availableRooms ? roomsNeeded : availableRooms;
  }

  double calculateTotalPrice(DateTime checkIn, DateTime checkOut) {
    final nights = checkOut.difference(checkIn).inDays;
    return price * nights;
  }

  // Format price as LKR currency
  String get formattedPrice => 'LKR ${price.toStringAsFixed(0)}';
}

class HotelBooking {
  final String id;
  final String hotelId;
  final String packageId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomsBooked;
  final int guestCount;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  HotelBooking({
    required this.id,
    required this.hotelId,
    required this.packageId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomsBooked,
    required this.guestCount,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory HotelBooking.fromJson(Map<String, dynamic> json) {
    return HotelBooking(
      id: json['_id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      packageId: json['packageId'] ?? '',
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      roomsBooked: json['roomsBooked'] ?? 1,
      guestCount: json['guestCount'] ?? 1,
      totalPrice: HotelRatings._parseDouble(json['totalPrice']) ?? 0.0,
      status: BookingStatus.fromString(json['status'] ?? 'pending'),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hotelId': hotelId,
      'packageId': packageId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'roomsBooked': roomsBooked,
      'guestCount': guestCount,
      'totalPrice': totalPrice,
      'status': status.toString().toLowerCase(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get totalNights => checkOutDate.difference(checkInDate).inDays;

  // Format total price as LKR currency
  String get formattedTotalPrice => 'LKR ${totalPrice.toStringAsFixed(2)}';
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }
}
