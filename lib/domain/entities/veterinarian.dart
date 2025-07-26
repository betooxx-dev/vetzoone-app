import 'user.dart';

class Veterinarian {
  final String id;
  final String? profilePhoto;
  final String license;
  final List<String> specialties;
  final int yearsExperience;
  final String? locationCity;
  final String? locationState;
  final String? bio;
  final List<String> services;
  final double? consultationFee;
  final List<String> animalsServed;
  final List<String> availability;
  final DateTime createdAt;
  final User user;

  const Veterinarian({
    required this.id,
    this.profilePhoto,
    required this.license,
    required this.specialties,
    required this.yearsExperience,
    this.locationCity,
    this.locationState,
    this.bio,
    required this.services,
    this.consultationFee,
    required this.animalsServed,
    required this.availability,
    required this.createdAt,
    required this.user,
  });

  String get fullName => '${user.firstName} ${user.lastName}';
  
  String get location {
    if (locationCity != null && locationState != null) {
      return '$locationCity, $locationState';
    } else if (locationCity != null) {
      return locationCity!;
    } else if (locationState != null) {
      return locationState!;
    }
    return 'Ubicación no especificada';
  }

  String get experienceText {
    if (yearsExperience == 0) return 'Nuevo';
    if (yearsExperience == 1) return '1 año de experiencia';
    return '$yearsExperience años de experiencia';
  }
}