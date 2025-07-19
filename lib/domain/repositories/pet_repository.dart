import 'dart:io';
import '../entities/pet.dart';
import '../../data/datasources/pet/pet_remote_datasource.dart';

abstract class PetRepository {
  Future<List<Pet>> getAllPets(String userId);
  Future<PetDetailDTO> getPetById(String petId);
  Future<Pet> createPet(Pet pet, {File? imageFile});
  Future<Pet> updatePet(String petId, Pet pet, {File? imageFile});
  Future<void> deletePet(String petId);
}