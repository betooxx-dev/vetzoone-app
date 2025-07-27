import '../../repositories/veterinarian_repository.dart';
import '../../models/search_result.dart';

class SearchVeterinariansUseCase {
  final VeterinarianRepository repository;

  SearchVeterinariansUseCase(this.repository);

  Future<SearchResult> call({
    String? search,
    String? location,
    String? specialty,
    int? limit,
    bool? symptoms,
    bool? useAI = false,
  }) async {
    return await repository.searchVeterinarians(
      search: search,
      location: location,
      specialty: specialty,
      limit: limit,
      symptoms: symptoms,
      useAI: useAI,
    );
  }
}