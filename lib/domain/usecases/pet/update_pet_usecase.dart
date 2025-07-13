import 'dart:io';
import '../../entities/pet.dart';
import '../../repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase({required this.repository});

  Future<Pet> call(String petId, Pet pet, {File? imageFile}) async {
    return await repository.updatePet(petId, pet, imageFile: imageFile);
  }
}