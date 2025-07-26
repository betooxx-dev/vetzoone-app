import '../../entities/vaccination.dart';
import '../../repositories/medical_records_repository.dart';

class GetVaccinationsUseCase {
  final MedicalRecordsRepository repository;

  GetVaccinationsUseCase(this.repository);

  Future<List<Vaccination>> call(String petId) async {
    return await repository.getVaccinationsByPetId(petId);
  }
}