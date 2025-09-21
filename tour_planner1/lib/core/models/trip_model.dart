class Trip {
  final String? id;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> placeIds;
  final List<String> guideIds;
  final List<String> hotelIds;
  final List<String> vehicleIds; // Add vehicleIds field
  final List<dynamic> vehicles; // Add full vehicles data field
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int travellersCount;
  final double entriesTotal;
  final double guidesTotal;
  final double hotelsTotal;
  final double vehiclesTotal; // Add vehiclesTotal field
  final double otherExpenses;
  final double totalBudget;

  Trip({
    this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.placeIds = const [],
    this.guideIds = const [],
    this.hotelIds = const [],
    this.vehicleIds = const [], // Initialize vehicleIds
    this.vehicles = const [], // Initialize vehicles
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.travellersCount = 1,
    this.entriesTotal = 0.0,
    this.guidesTotal = 0.0,
    this.hotelsTotal = 0.0,
    this.vehiclesTotal = 0.0, // Initialize vehiclesTotal
    this.otherExpenses = 0.0,
    this.totalBudget = 0.0,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      placeIds: Trip._extractPlaceIds(json),
      guideIds: Trip._extractGuideIds(json),
      hotelIds: Trip._extractHotelIds(json),
      vehicleIds: Trip._extractVehicleIds(json), // Extract vehicleIds
      vehicles: Trip._extractVehicles(json), // Extract full vehicles data
      userId: json['userId'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      travellersCount: json['travellersCount'] ?? 1,
      entriesTotal:
          (json['estimatedBudget']?['entriesTotal'] ?? 0.0).toDouble(),
      guidesTotal: (json['estimatedBudget']?['guidesTotal'] ?? 0.0).toDouble(),
      hotelsTotal: (json['estimatedBudget']?['hotelsTotal'] ?? 0.0).toDouble(),
      vehiclesTotal: (json['estimatedBudget']?['vehiclesTotal'] ?? 0.0)
          .toDouble(), // Extract vehiclesTotal
      otherExpenses:
          (json['estimatedBudget']?['otherExpenses'] ?? 0.0).toDouble(),
      totalBudget: (json['estimatedBudget']?['totalBudget'] ?? 0.0).toDouble(),
    );
  }

  // Helper method to extract place IDs from either placeIds array or populated places array
  static List<String> _extractPlaceIds(Map<String, dynamic> json) {
    print('DEBUG: _extractPlaceIds called with keys: ${json.keys.toList()}');
    print('DEBUG: places field type: ${json['places']?.runtimeType}');
    print('DEBUG: placeIds field type: ${json['placeIds']?.runtimeType}');

    // If placeIds exists, use it directly
    if (json['placeIds'] != null) {
      print('DEBUG: Found placeIds: ${json['placeIds']}');
      return List<String>.from(json['placeIds']);
    }

    // If places array exists (populated), extract IDs from place objects
    if (json['places'] != null && json['places'] is List) {
      final places = json['places'] as List;
      print('DEBUG: Found places array with ${places.length} items');

      final extractedIds = <String>[];

      for (final place in places) {
        print('DEBUG: Processing place type: ${place.runtimeType}');
        print(
            'DEBUG: Processing place keys: ${place is Map ? (place as Map).keys.toList() : 'not a map'}');

        if (place is Map<String, dynamic>) {
          // Try different possible ID field names
          String? placeId;

          // First priority: Check for placeId field (contains the actual place data)
          if (place['placeId'] != null) {
            if (place['placeId'] is String) {
              placeId = place['placeId'] as String;
              print('DEBUG: Found placeId as string: $placeId');
            } else if (place['placeId'] is Map<String, dynamic>) {
              placeId = place['placeId']['_id'] as String?;
              print('DEBUG: Found placeId._id: $placeId');
            }
          }
          // Second priority: Check for direct _id field (legacy support)
          else if (place['_id'] != null) {
            placeId = place['_id'] as String;
            print('DEBUG: Found direct _id: $placeId');
          }
          // Check for id field as fallback
          else if (place['id'] != null) {
            placeId = place['id'] as String;
            print('DEBUG: Found id field: $placeId');
          }

          if (placeId != null && placeId.isNotEmpty) {
            extractedIds.add(placeId);
          } else {
            print('DEBUG: Could not extract ID from place: $place');
          }
        } else {
          print(
              'DEBUG: Place is not a Map, it\'s: ${place.runtimeType} - $place');
        }
      }

      print('DEBUG: Extracted ${extractedIds.length} place IDs: $extractedIds');
      return extractedIds;
    }

    print('DEBUG: No place data found, returning empty list');
    return [];
  }

  // Helper method to extract guide IDs from either guideIds array or populated guides array
  static List<String> _extractGuideIds(Map<String, dynamic> json) {
    print('DEBUG: _extractGuideIds called with keys: ${json.keys.toList()}');
    print('DEBUG: guides field type: ${json['guides']?.runtimeType}');
    print('DEBUG: guideIds field type: ${json['guideIds']?.runtimeType}');

    // If guideIds exists, use it directly
    if (json['guideIds'] != null) {
      print('DEBUG: Found guideIds: ${json['guideIds']}');
      return List<String>.from(json['guideIds']);
    }

    // If guides array exists (populated), extract IDs from guide objects
    if (json['guides'] != null && json['guides'] is List) {
      final guides = json['guides'] as List;
      print('DEBUG: Found guides array with ${guides.length} items');

      final extractedIds = <String>[];

      for (final guide in guides) {
        print('DEBUG: Processing guide type: ${guide.runtimeType}');
        print(
            'DEBUG: Processing guide keys: ${guide is Map ? (guide as Map).keys.toList() : 'not a map'}');

        if (guide is Map<String, dynamic>) {
          // Try different possible ID field names
          String? guideId;

          // First priority: Check for guideId field (contains the actual guide data)
          if (guide['guideId'] != null) {
            if (guide['guideId'] is String) {
              guideId = guide['guideId'] as String;
              print('DEBUG: Found guideId as string: $guideId');
            } else if (guide['guideId'] is Map<String, dynamic>) {
              guideId = guide['guideId']['_id'] as String?;
              print('DEBUG: Found guideId._id: $guideId');
            }
          }
          // Second priority: Check for direct _id field (legacy support)
          else if (guide['_id'] != null) {
            guideId = guide['_id'] as String;
            print('DEBUG: Found direct _id: $guideId');
          }
          // Check for id field as fallback
          else if (guide['id'] != null) {
            guideId = guide['id'] as String;
            print('DEBUG: Found id field: $guideId');
          }

          if (guideId != null && guideId.isNotEmpty) {
            extractedIds.add(guideId);
          } else {
            print('DEBUG: Could not extract ID from guide: $guide');
          }
        } else {
          print(
              'DEBUG: Guide is not a Map, it\'s: ${guide.runtimeType} - $guide');
        }
      }

      print('DEBUG: Extracted ${extractedIds.length} guide IDs: $extractedIds');
      return extractedIds;
    }

    print('DEBUG: No guide data found, returning empty list');
    return [];
  }

  // Helper method to extract hotel IDs from either hotelIds array or populated hotels array
  static List<String> _extractHotelIds(Map<String, dynamic> json) {
    print('DEBUG: _extractHotelIds called with keys: ${json.keys.toList()}');
    print('DEBUG: hotels field type: ${json['hotels']?.runtimeType}');
    print('DEBUG: hotelIds field type: ${json['hotelIds']?.runtimeType}');

    // If hotelIds exists, use it directly
    if (json['hotelIds'] != null) {
      print('DEBUG: Found hotelIds: ${json['hotelIds']}');
      return List<String>.from(json['hotelIds']);
    }

    // If hotels array exists (populated), extract IDs from hotel objects
    if (json['hotels'] != null && json['hotels'] is List) {
      final hotels = json['hotels'] as List;
      print('DEBUG: Found hotels array with ${hotels.length} items');

      final extractedIds = <String>[];

      for (final hotel in hotels) {
        print('DEBUG: Processing hotel type: ${hotel.runtimeType}');
        print(
            'DEBUG: Processing hotel keys: ${hotel is Map ? (hotel as Map).keys.toList() : 'not a map'}');

        if (hotel is Map<String, dynamic>) {
          // Try different possible ID field names
          String? hotelId;

          // First priority: Check for hotelId field (contains the actual hotel data)
          if (hotel['hotelId'] != null) {
            if (hotel['hotelId'] is String) {
              hotelId = hotel['hotelId'] as String;
              print('DEBUG: Found hotelId as string: $hotelId');
            } else if (hotel['hotelId'] is Map<String, dynamic>) {
              hotelId = hotel['hotelId']['_id'] as String?;
              print('DEBUG: Found hotelId._id: $hotelId');
            }
          }
          // Second priority: Check for direct _id field (legacy support)
          else if (hotel['_id'] != null) {
            hotelId = hotel['_id'] as String;
            print('DEBUG: Found direct _id: $hotelId');
          }
          // Check for id field as fallback
          else if (hotel['id'] != null) {
            hotelId = hotel['id'] as String;
            print('DEBUG: Found id field: $hotelId');
          }

          if (hotelId != null && hotelId.isNotEmpty) {
            extractedIds.add(hotelId);
          } else {
            print('DEBUG: Could not extract ID from hotel: $hotel');
          }
        } else {
          print(
              'DEBUG: Hotel is not a Map, it\'s: ${hotel.runtimeType} - $hotel');
        }
      }

      print('DEBUG: Extracted ${extractedIds.length} hotel IDs: $extractedIds');
      return extractedIds;
    }

    print('DEBUG: No hotel data found, returning empty list');
    return [];
  }

  // Helper method to extract vehicle IDs from either vehicleIds array or populated vehicles array
  static List<String> _extractVehicleIds(Map<String, dynamic> json) {
    print('DEBUG: _extractVehicleIds called with keys: ${json.keys.toList()}');
    print('DEBUG: vehicles field type: ${json['vehicles']?.runtimeType}');
    print('DEBUG: vehicleIds field type: ${json['vehicleIds']?.runtimeType}');

    // If vehicleIds exists, use it directly
    if (json['vehicleIds'] != null) {
      print('DEBUG: Found vehicleIds: ${json['vehicleIds']}');
      return List<String>.from(json['vehicleIds']);
    }

    // If vehicles array exists (populated), extract IDs from vehicle objects
    if (json['vehicles'] != null && json['vehicles'] is List) {
      final vehicles = json['vehicles'] as List;
      print('DEBUG: Found vehicles array with ${vehicles.length} items');

      final extractedIds = <String>[];

      for (final vehicle in vehicles) {
        print('DEBUG: Processing vehicle type: ${vehicle.runtimeType}');
        print(
            'DEBUG: Processing vehicle keys: ${vehicle is Map ? (vehicle as Map).keys.toList() : 'not a map'}');

        if (vehicle is Map<String, dynamic>) {
          // Try different possible ID field names
          String? vehicleId;

          // First priority: Check for vehicleId field (contains the actual vehicle data)
          if (vehicle['vehicleId'] != null) {
            if (vehicle['vehicleId'] is String) {
              vehicleId = vehicle['vehicleId'] as String;
              print('DEBUG: Found vehicleId as string: $vehicleId');
            } else if (vehicle['vehicleId'] is Map<String, dynamic>) {
              vehicleId = vehicle['vehicleId']['_id'] as String?;
              print('DEBUG: Found vehicleId._id: $vehicleId');
            }
          }
          // Second priority: Check for direct _id field (legacy support)
          else if (vehicle['_id'] != null) {
            vehicleId = vehicle['_id'] as String;
            print('DEBUG: Found direct _id: $vehicleId');
          }
          // Check for id field as fallback
          else if (vehicle['id'] != null) {
            vehicleId = vehicle['id'] as String;
            print('DEBUG: Found id field: $vehicleId');
          }

          if (vehicleId != null && vehicleId.isNotEmpty) {
            extractedIds.add(vehicleId);
          } else {
            print('DEBUG: Could not extract ID from vehicle: $vehicle');
          }
        } else {
          print(
              'DEBUG: Vehicle is not a Map, it\'s: ${vehicle.runtimeType} - $vehicle');
        }
      }

      print(
          'DEBUG: Extracted ${extractedIds.length} vehicle IDs: $extractedIds');
      return extractedIds;
    }

    print('DEBUG: No vehicle data found, returning empty list');
    return [];
  }

  // Helper method to extract full vehicles data
  static List<dynamic> _extractVehicles(Map<String, dynamic> json) {
    print('DEBUG: _extractVehicles called with keys: ${json.keys.toList()}');
    print('DEBUG: vehicles field type: ${json['vehicles']?.runtimeType}');

    // If vehicles array exists, use it directly
    if (json['vehicles'] != null && json['vehicles'] is List) {
      final vehicles = json['vehicles'] as List;
      print('DEBUG: Found vehicles array with ${vehicles.length} items');

      // Print details of each vehicle for debugging
      for (int i = 0; i < vehicles.length; i++) {
        print('DEBUG: Vehicle $i: ${vehicles[i]}');
      }

      return List<dynamic>.from(vehicles);
    }

    print('DEBUG: No vehicles data found, returning empty list');
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'placeIds': placeIds,
      'guideIds': guideIds,
      'hotelIds': hotelIds,
      'vehicleIds': vehicleIds, // Include vehicleIds in JSON
      'vehicles': vehicles, // Include full vehicles data in JSON
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'travellersCount': travellersCount,
      'estimatedBudget': {
        'entriesTotal': entriesTotal,
        'guidesTotal': guidesTotal,
        'hotelsTotal': hotelsTotal,
        'vehiclesTotal': vehiclesTotal, // Include vehiclesTotal in JSON
        'otherExpenses': otherExpenses,
        'totalBudget': totalBudget,
      },
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? placeIds,
    List<String>? guideIds,
    List<String>? hotelIds,
    List<String>? vehicleIds, // Add vehicleIds parameter
    List<dynamic>? vehicles, // Add vehicles parameter
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? travellersCount,
    double? entriesTotal,
    double? guidesTotal,
    double? hotelsTotal,
    double? vehiclesTotal, // Add vehiclesTotal parameter
    double? otherExpenses,
    double? totalBudget,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      placeIds: placeIds ?? this.placeIds,
      guideIds: guideIds ?? this.guideIds,
      hotelIds: hotelIds ?? this.hotelIds,
      vehicleIds: vehicleIds ?? this.vehicleIds, // Copy vehicleIds
      vehicles: vehicles ?? this.vehicles, // Copy vehicles
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      travellersCount: travellersCount ?? this.travellersCount,
      entriesTotal: entriesTotal ?? this.entriesTotal,
      guidesTotal: guidesTotal ?? this.guidesTotal,
      hotelsTotal: hotelsTotal ?? this.hotelsTotal,
      vehiclesTotal: vehiclesTotal ?? this.vehiclesTotal, // Copy vehiclesTotal
      otherExpenses: otherExpenses ?? this.otherExpenses,
      totalBudget: totalBudget ?? this.totalBudget,
    );
  }

  // Helper method to get formatted date range
  String getDateRange() {
    if (startDate == null && endDate == null) {
      return 'Dates not set';
    } else if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
    } else if (startDate != null) {
      return 'From ${_formatDate(startDate!)}';
    } else {
      return 'Until ${_formatDate(endDate!)}';
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

  // Helper method to get duration
  int? getDurationInDays() {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!).inDays + 1;
    }
    return null;
  }

  // Helper method to format budget in Sri Lankan Rupees
  String getFormattedBudget() {
    if (totalBudget <= 0) return 'Budget not calculated';
    return 'LKR ${_formatCurrency(totalBudget)}';
  }

  // Helper method to get per person budget
  String getPerPersonBudget() {
    if (totalBudget <= 0 || travellersCount <= 0) return 'N/A';
    final perPerson = totalBudget / travellersCount;
    return 'LKR ${_formatCurrency(perPerson)} per person';
  }

  // Helper method to get formatted entries total
  String getFormattedEntriesTotal() {
    if (entriesTotal <= 0) return 'No entry fees';
    return 'LKR ${_formatCurrency(entriesTotal)} for $travellersCount ${travellersCount == 1 ? 'person' : 'people'}';
  }

  // Helper method to get formatted guides total
  String getFormattedGuidesTotal() {
    if (guidesTotal <= 0) return 'No guide fees';
    return 'LKR ${_formatCurrency(guidesTotal)} for entire trip';
  }

  // Helper method to get formatted hotels total
  String getFormattedHotelsTotal() {
    if (hotelsTotal <= 0) return 'No hotel costs';
    return 'LKR ${_formatCurrency(hotelsTotal)} for entire trip';
  }

  // Helper method to get formatted vehicles total
  String getFormattedVehiclesTotal() {
    if (vehiclesTotal <= 0) return 'No vehicle costs';
    return 'LKR ${_formatCurrency(vehiclesTotal)} for entire trip';
  }

  // Helper method to format currency with commas
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
