import '../../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.profilePhoto,
    required super.email,
    required super.role,
    required super.isActive,
    required super.isVerified,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      profilePhoto: json['profile_photo'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'],
      isVerified: json['is_verified'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_photo': profilePhoto,
      'email': email,
      'role': role,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}