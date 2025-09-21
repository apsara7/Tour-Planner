class Place {
  final String id;
  final String name;
  final String? description;
  final String? province;
  final String? district;
  final String? location;
  final String? mapUrl;
  final double? latitude;
  final double? longitude;
  final String? visitingHours;
  final String? entryFee;
  final String? bestTimeToVisit;
  final String? transportation;
  final List<String> highlights;
  final List<String> images;

  Place({
    required this.id,
    required this.name,
    this.description,
    this.province,
    this.district,
    this.location,
    this.mapUrl,
    this.latitude,
    this.longitude,
    this.visitingHours,
    this.entryFee,
    this.bestTimeToVisit,
    this.transportation,
    this.highlights = const [],
    this.images = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      province: json['province'],
      district: json['district'],
      location: json['location'],
      mapUrl: json['mapUrl'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      visitingHours: json['visitingHours'],
      entryFee: json['entryFee'],
      bestTimeToVisit: json['bestTimeToVisit'],
      transportation: json['transportation'],
      highlights: _parseHighlights(json['highlights']),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  // Helper method to parse highlights (can be string or array)
  static List<String> _parseHighlights(dynamic highlightsData) {
    if (highlightsData == null) return [];

    if (highlightsData is String) {
      if (highlightsData.isEmpty) return [];
      return highlightsData
          .split(',')
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .toList();
    } else if (highlightsData is List) {
      return List<String>.from(highlightsData);
    }

    return [];
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'province': province,
      'district': district,
      'location': location,
      'mapUrl': mapUrl,
      'latitude': latitude,
      'longitude': longitude,
      'visitingHours': visitingHours,
      'entryFee': entryFee,
      'bestTimeToVisit': bestTimeToVisit,
      'transportation': transportation,
      'highlights': highlights,
      'images': images,
    };
  }
}
