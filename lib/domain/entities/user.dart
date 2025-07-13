class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? profilePhoto;
  final String email;
  final String role;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.profilePhoto,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
}