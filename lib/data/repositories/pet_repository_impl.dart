import 'dart:io';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet/pet_remote_datasource.dart';
import '../models/pet/pet_model.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Pet>> getAllPets(String userId) async {
    try {
      final pets = await remoteDataSource.getAllPets(userId);
      return pets;
    } catch (e) {
      throw Exception('Failed to get pets: $e');
    }
  }

  @override
  Future<PetDetailDTO> getPetById(String petId) async {
    try {
      final petDetail = await remoteDataSource.getPetById(petId);
      return petDetail;
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  @override
  Future<Pet> createPet(Pet pet, {File? imageFile}) async {
    try {
      final petModel = PetModel(
        id: pet.id,
        name: pet.name,
        type: pet.type,
        breed: pet.breed,
        gender: pet.gender,
        status: pet.status,
        description: pet.description,
        birthDate: pet.birthDate,
        imageUrl: pet.imageUrl,
        userId: pet.userId,
        createdAt: pet.createdAt,
        updatedAt: pet.updatedAt,
      );
      
      final createdPet = await remoteDataSource.createPet(petModel, imageFile: imageFile);
      return createdPet;
    } catch (e) {
      throw Exception('Failed to create pet: $e');
    }
  }

  @override
  Future<Pet> updatePet(String petId, Pet pet, {File? imageFile}) async {
    try {
      final petModel = PetModel(
        id: pet.id,
        name: pet.name,
        type: pet.type,
        breed: pet.breed,
        gender: pet.gender,
        status: pet.status,
        description: pet.description,
        birthDate: pet.birthDate,
        imageUrl: pet.imageUrl,
        userId: pet.userId,
        createdAt: pet.createdAt,
        updatedAt: pet.updatedAt,
      );
      
      final updatedPet = await remoteDataSource.updatePet(petId, petModel, imageFile: imageFile);
      return updatedPet;
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      await remoteDataSource.deletePet(petId);
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }
}