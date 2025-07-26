import '../../entities/medical_record.dart';
import '../../repositories/medical_records_repository.dart';

class GetMedicalRecordsUseCase {
  final MedicalRecordsRepository repository;

  GetMedicalRecordsUseCase(this.repository);

  Future<List<MedicalRecord>> call(String petId) async {
    return await repository.getMedicalRecordsByPetId(petId);
  }
}