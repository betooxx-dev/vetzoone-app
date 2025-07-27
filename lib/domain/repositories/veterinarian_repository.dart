import '../entities/veterinarian.dart';
import '../models/search_result.dart';

abstract class VeterinarianRepository {
  Future<SearchResult> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
    bool? symptoms,
    bool? useAI,
  });
  Future<Veterinarian> getVeterinarianById(String vetId);
}