import '../../entities/veterinarian.dart';
import '../../repositories/veterinarian_repository.dart';

class GetVeterinarianProfileUseCase {
  final VeterinarianRepository repository;

  GetVeterinarianProfileUseCase(this.repository);

  Future<Veterinarian> call(String vetId) async {
    return await repository.getVeterinarianById(vetId);
  }
}