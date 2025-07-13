import 'dart:io';
import '../../entities/pet.dart';
import '../../repositories/pet_repository.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase({required this.repository});

  Future<Pet> call(Pet pet, {File? imageFile}) async {
    return await repository.createPet(pet, imageFile: imageFile);
  }
}