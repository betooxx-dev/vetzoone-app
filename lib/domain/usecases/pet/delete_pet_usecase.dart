import '../../repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase({required this.repository});

  Future<void> call(String petId) async {
    return await repository.deletePet(petId);
  }
}