import '../../entities/veterinarian.dart';
import '../../repositories/veterinarian_repository.dart';

class SearchVeterinariansUseCase {
  final VeterinarianRepository repository;

  SearchVeterinariansUseCase(this.repository);

  Future<List<Veterinarian>> call({
    String? search,
    String? location,
    String? specialty,
    int? limit,
  }) async {
    return await repository.searchVeterinarians(
      search: search,
      location: location,
      specialty: specialty,
      limit: limit,
    );
  }
}