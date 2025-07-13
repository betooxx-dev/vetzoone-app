import 'dart:io';
import '../entities/pet.dart';

abstract class PetRepository {
  Future<List<Pet>> getAllPets(String userId);
  Future<Pet> getPetById(String petId);
  Future<Pet> createPet(Pet pet, {File? imageFile});
  Future<Pet> updatePet(String petId, Pet pet, {File? imageFile});
  Future<void> deletePet(String petId);
}