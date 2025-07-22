import '../../domain/repositories/veterinarian_repository.dart';
import '../../domain/entities/veterinarian.dart';
import '../datasources/veterinarian/veterinarian_remote_datasource.dart';

class VeterinarianRepositoryImpl implements VeterinarianRepository {
  final VeterinarianRemoteDataSource remoteDataSource;

  VeterinarianRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Veterinarian>> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
  }) async {
    return await remoteDataSource.searchVeterinarians(
      search: search,
      location: location,
      specialty: specialty,
      limit: limit,
    );
  }

  @override
  Future<Veterinarian> getVeterinarianById(String vetId) async {
    return await remoteDataSource.getVeterinarianById(vetId);
  }
}