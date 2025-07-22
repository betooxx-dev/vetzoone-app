import '../entities/veterinarian.dart';

abstract class VeterinarianRepository {
  Future<List<Veterinarian>> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
  });
  Future<Veterinarian> getVeterinarianById(String vetId);
}