import '../entities/medical_record.dart';
import '../entities/vaccination.dart';

abstract class MedicalRecordsRepository {
  Future<List<MedicalRecord>> getMedicalRecordsByPetId(String petId);
  Future<List<Vaccination>> getVaccinationsByPetId(String petId);
}