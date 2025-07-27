import '../../domain/repositories/veterinarian_repository.dart';
import '../../domain/entities/veterinarian.dart';
import '../../domain/models/search_result.dart';
import '../datasources/veterinarian/veterinarian_remote_datasource.dart';

class VeterinarianRepositoryImpl implements VeterinarianRepository {
  final VeterinarianRemoteDataSource remoteDataSource;

  VeterinarianRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SearchResult> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
    bool? symptoms,
    bool? useAI,
  }) async {
    return await remoteDataSource.searchVeterinarians(
      search: search,
      location: location,
      specialty: specialty,
      limit: limit,
      symptoms: symptoms,
      useAI: useAI,
    );
  }

  @override
  Future<Veterinarian> getVeterinarianById(String vetId) async {
    return await remoteDataSource.getVeterinarianById(vetId);
  }
}