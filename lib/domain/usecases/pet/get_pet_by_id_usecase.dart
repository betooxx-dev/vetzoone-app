import '../../entities/pet.dart';
import '../../repositories/pet_repository.dart';
import '../../../data/datasources/pet/pet_remote_datasource.dart';

class GetPetByIdUseCase {
  final PetRepository repository;

  GetPetByIdUseCase({required this.repository});

  Future<PetDetailDTO> call(String petId) async {
    try {
      return await repository.getPetById(petId);
    } catch (e) {
      throw Exception('Error al obtener información de la mascota: $e');
    }
  }
} 