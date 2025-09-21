class Guide {
  final String id;
  final String guideName;
  final String? description;
  final ContactDetails contactDetails;
  final Address address;
  final Experience experience;
  final License license;
  final Ratings ratings;
  final Availability availability;
  final Pricing pricing;
  final List<String> images;
  final String status;
  final String? bio;
  final List<String> achievements;
  final SocialMedia? socialMedia;
  final DateTime createdAt;
  final DateTime updatedAt;

  Guide({
    required this.id,
    required this.guideName,
    this.description,
    required this.contactDetails,
    required this.address,
    required this.experience,
    required this.license,
    required this.ratings,
    required this.availability,
    required this.pricing,
    this.images = const [],
    required this.status,
    this.bio,
    this.achievements = const [],
    this.socialMedia,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['_id'] ?? '',
      guideName: json['guideName'] ?? '',
      description: json['description'],
      contactDetails: ContactDetails.fromJson(json['contactDetails'] ?? {}),
      address: Address.fromJson(json['address'] ?? {}),
      experience: Experience.fromJson(json['experience'] ?? {}),
      license: License.fromJson(json['license'] ?? {}),
      ratings: Ratings.fromJson(json['ratings'] ?? {}),
      availability: Availability.fromJson(json['availability'] ?? {}),
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'] ?? 'pending_verification',
      bio: json['bio'],
      achievements: json['achievements'] != null
          ? List<String>.from(json['achievements'])
          : [],
      socialMedia: json['socialMedia'] != null
          ? SocialMedia.fromJson(json['socialMedia'])
          : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ContactDetails {
  final String phone;
  final String email;
  final String? website;
  final String? emergencyContact;

  ContactDetails({
    required this.phone,
    required this.email,
    this.website,
    this.emergencyContact,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      emergencyContact: json['emergencyContact'],
    );
  }
}

class Address {
  final String street;
  final String city;
  final String province;
  final String? postalCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.province,
    this.postalCode,
    this.country = 'Sri Lanka',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postalCode'],
      country: json['country'] ?? 'Sri Lanka',
    );
  }
}

class Experience {
  final int yearsOfExperience;
  final List<String> specializations;
  final List<String> languages;
  final List<String> certifications;

  Experience({
    required this.yearsOfExperience,
    this.specializations = const [],
    this.languages = const [],
    this.certifications = const [],
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      specializations: json['specializations'] != null
          ? List<String>.from(json['specializations'])
          : [],
      languages:
          json['languages'] != null ? List<String>.from(json['languages']) : [],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
    );
  }
}

class License {
  final String licenseNumber;
  final String licenseType;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String issuingAuthority;
  final String? licenseImage;

  License({
    required this.licenseNumber,
    required this.licenseType,
    required this.issuedDate,
    required this.expiryDate,
    required this.issuingAuthority,
    this.licenseImage,
  });

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      licenseNumber: json['licenseNumber'] ?? '',
      licenseType: json['licenseType'] ?? '',
      issuedDate: DateTime.parse(
          json['issuedDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: DateTime.parse(
          json['expiryDate'] ?? DateTime.now().toIso8601String()),
      issuingAuthority: json['issuingAuthority'] ?? '',
      licenseImage: json['licenseImage'],
    );
  }
}

class Ratings {
  final double averageRating;
  final int totalRatings;
  final RatingBreakdown ratingBreakdown;

  Ratings({
    this.averageRating = 0.0,
    this.totalRatings = 0,
    required this.ratingBreakdown,
  });

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingBreakdown: RatingBreakdown.fromJson(json['ratingBreakdown'] ?? {}),
    );
  }
}

class RatingBreakdown {
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  RatingBreakdown({
    this.fiveStar = 0,
    this.fourStar = 0,
    this.threeStar = 0,
    this.twoStar = 0,
    this.oneStar = 0,
  });

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) {
    return RatingBreakdown(
      fiveStar: json['fiveStar'] ?? 0,
      fourStar: json['fourStar'] ?? 0,
      threeStar: json['threeStar'] ?? 0,
      twoStar: json['twoStar'] ?? 0,
      oneStar: json['oneStar'] ?? 0,
    );
  }
}

class Availability {
  final bool isAvailable;
  final List<String> workingDays;
  final WorkingHours workingHours;

  Availability({
    this.isAvailable = true,
    this.workingDays = const [],
    required this.workingHours,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      isAvailable: json['isAvailable'] ?? true,
      workingDays: json['workingDays'] != null
          ? List<String>.from(json['workingDays'])
          : [],
      workingHours: WorkingHours.fromJson(json['workingHours'] ?? {}),
    );
  }
}

class WorkingHours {
  final String start;
  final String end;

  WorkingHours({
    this.start = '09:00',
    this.end = '18:00',
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      start: json['start'] ?? '09:00',
      end: json['end'] ?? '18:00',
    );
  }
}

class Pricing {
  final double hourlyRate;
  final double dailyRate;
  final String currency;

  Pricing({
    required this.hourlyRate,
    required this.dailyRate,
    this.currency = 'LKR',
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      hourlyRate: (json['hourlyRate'] ?? 0.0).toDouble(),
      dailyRate: (json['dailyRate'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'LKR',
    );
  }

  String getFormattedHourlyRate() {
    return '$currency ${hourlyRate.toStringAsFixed(2)}/hour';
  }

  String getFormattedDailyRate() {
    return '$currency ${dailyRate.toStringAsFixed(2)}/day';
  }
}

class SocialMedia {
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;

  SocialMedia({
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
    );
  }
}
