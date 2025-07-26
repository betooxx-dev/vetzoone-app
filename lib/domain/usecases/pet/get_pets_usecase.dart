import '../../entities/pet.dart';
import '../../repositories/pet_repository.dart';

class GetPetsUseCase {
  final PetRepository repository;

  GetPetsUseCase({required this.repository});

  Future<List<Pet>> call(String userId) async {
    return await repository.getAllPets(userId);
  }
}