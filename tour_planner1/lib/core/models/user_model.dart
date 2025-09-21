class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? profileImage;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.profileImage,
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? json['profile_image'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImage': profileImage,
      'isVerified': isVerified,
    };
  }
}