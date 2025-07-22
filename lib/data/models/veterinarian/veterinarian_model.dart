import '../../../domain/entities/veterinarian.dart';
import '../auth/user_model.dart';

class VeterinarianModel extends Veterinarian {
  const VeterinarianModel({
    required super.id,
    super.profilePhoto,
    required super.license,
    required super.specialties,
    required super.yearsExperience,
    super.locationCity,
    super.locationState,
    super.bio,
    required super.services,
    super.consultationFee,
    required super.animalsServed,
    required super.availability,
    required super.createdAt,
    required super.user,
  });

  factory VeterinarianModel.fromJson(Map<String, dynamic> json) {
    try {
      return VeterinarianModel(
        id: json['id']?.toString() ?? '',
        profilePhoto: json['profile_photo'],
        license: json['license']?.toString() ?? '',
        specialties: List<String>.from(json['specialties'] ?? []),
        yearsExperience: json['years_experience'] ?? 0,
        locationCity: json['location_city'],
        locationState: json['location_state'],
        bio: json['bio'],
        services: List<String>.from(json['services'] ?? []),
        consultationFee: _parseDouble(json['consultation_fee']),
        animalsServed: List<String>.from(json['animals_served'] ?? []),
        availability: _parseAvailability(json['availability']),
        createdAt: DateTime.parse(json['created_at']),
        user: UserModel.fromJson(json['user']),
      );
    } catch (e) {
      print('❌ Error parsing veterinarian: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _parseAvailability(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) {
        if (item is Map<String, dynamic>) {
          final day = item['day'] ?? '';
          final start = item['start_time'] ?? '';
          final end = item['end_time'] ?? '';
          return '$day: $start - $end';
        }
        return item.toString();
      }).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_photo': profilePhoto,
      'license': license,
      'specialties': specialties,
      'years_experience': yearsExperience,
      'location_city': locationCity,
      'location_state': locationState,
      'bio': bio,
      'services': services,
      'consultation_fee': consultationFee,
      'animals_served': animalsServed,
      'availability': availability,
      'created_at': createdAt.toIso8601String(),
      'user': (user as UserModel).toJson(),
    };
  }
}
