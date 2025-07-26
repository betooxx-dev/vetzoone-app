import '../../domain/entities/medical_record.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../datasources/medical_records/medical_records_remote_datasource.dart';

class MedicalRecordsRepositoryImpl implements MedicalRecordsRepository {
  final MedicalRecordsRemoteDataSource remoteDataSource;

  MedicalRecordsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MedicalRecord>> getMedicalRecordsByPetId(String petId) async {
    try {
      final medicalRecords = await remoteDataSource.getMedicalRecordsByPetId(petId);
      return medicalRecords;
    } catch (e) {
      throw Exception('Error getting medical records: $e');
    }
  }

  @override
  Future<List<Vaccination>> getVaccinationsByPetId(String petId) async {
    try {
      final vaccinations = await remoteDataSource.getVaccinationsByPetId(petId);
      return vaccinations;
    } catch (e) {
      throw Exception('Error getting vaccinations: $e');
    }
  }
}