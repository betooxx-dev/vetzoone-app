import '../entities/veterinarian.dart';

abstract class VeterinarianRepository {
  Future<List<Veterinarian>> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
    bool? symptoms,
  });
  Future<Veterinarian> getVeterinarianById(String vetId);
}