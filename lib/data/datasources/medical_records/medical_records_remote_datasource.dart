import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/medical_records/medical_record_model.dart';
import '../../models/medical_records/vaccination_model.dart';

abstract class MedicalRecordsRemoteDataSource {
  Future<List<MedicalRecordModel>> getMedicalRecordsByPetId(String petId);
  Future<List<VaccinationModel>> getVaccinationsByPetId(String petId);
}

class MedicalRecordsRemoteDataSourceImpl implements MedicalRecordsRemoteDataSource {
  final ApiClient apiClient;

  MedicalRecordsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MedicalRecordModel>> getMedicalRecordsByPetId(String petId) async {
    try {
      final url = ApiEndpoints.getMedicalRecordsByPetUrl(petId);
      
      print('🏥 PETICIÓN MEDICAL RECORDS:');
      print('URL: $url');
      print('Pet ID: $petId');
      
      final response = await apiClient.get(url);
      
      print('✅ MEDICAL RECORDS RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> recordsData = response.data['data'] ?? [];
        return recordsData
            .map((json) => MedicalRecordModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load medical records - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING MEDICAL RECORDS:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching medical records: $e');
    }
  }

  @override
  Future<List<VaccinationModel>> getVaccinationsByPetId(String petId) async {
    try {
      final url = ApiEndpoints.getVaccinationsByPetUrl(petId);
      
      print('💉 PETICIÓN VACCINATIONS:');
      print('URL: $url');
      print('Pet ID: $petId');
      
      final response = await apiClient.get(url);
      
      print('✅ VACCINATIONS RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> vaccinationsData = response.data['data'] ?? [];
        return vaccinationsData
            .map((json) => VaccinationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load vaccinations - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING VACCINATIONS:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching vaccinations: $e');
    }
  }
}