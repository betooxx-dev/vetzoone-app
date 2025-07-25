import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/appointment/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getUpcomingAppointmentsByUserId(
    String userId,
    DateTime dateFrom,
    DateTime dateTo,
  );
  Future<List<AppointmentModel>> getAppointmentsByPetId(String petId);
  Future<List<AppointmentModel>> getAllAppointmentsByUserId(String userId);
  Future<List<AppointmentModel>> getAppointmentsByVetId(String vetId);
  Future<AppointmentModel> getAppointmentById(String appointmentId);
  Future<AppointmentModel> createAppointment(Map<String, dynamic> appointmentData);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient apiClient;

  AppointmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AppointmentModel>> getUpcomingAppointmentsByUserId(
    String userId,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final url = ApiEndpoints.getAppointmentsByUserUrl(userId);
      
      final queryParams = {
        'dateFrom': dateFrom.toIso8601String().split('T')[0],
        'dateTo': dateTo.toIso8601String().split('T')[0],
      };
      
      print('🗓️ PETICIÓN UPCOMING APPOINTMENTS:');
      print('URL: $url');
      print('User ID: $userId');
      print('Query Params: $queryParams');
      
      final response = await apiClient.get(url, queryParameters: queryParams);
      
      print('✅ APPOINTMENTS RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data['data'] ?? [];
        return appointmentsData
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load appointments - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING APPOINTMENTS:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching appointments: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByPetId(String petId) async {
    try {
      final url = ApiEndpoints.getAppointmentsByPetUrl(petId);
      
      print('🗓️ PETICIÓN APPOINTMENTS BY PET:');
      print('URL: $url');
      print('Pet ID: $petId');
      
      final response = await apiClient.get(url);
      
      print('✅ PET APPOINTMENTS RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data['data'] ?? [];
        return appointmentsData
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load pet appointments - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING PET APPOINTMENTS:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching pet appointments: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAllAppointmentsByUserId(String userId) async {
    try {
      final url = ApiEndpoints.getAppointmentsByUserUrl(userId);
      
      print('🗓️ PETICIÓN ALL APPOINTMENTS BY USER:');
      print('URL: $url');
      print('User ID: $userId');
      
      final response = await apiClient.get(url);
      
      print('✅ ALL APPOINTMENTS RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data['data'] ?? [];
        return appointmentsData
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load all appointments - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING ALL APPOINTMENTS:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching all appointments: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByVetId(String vetId) async {
    try {
      final url = ApiEndpoints.getAppointmentsByVetUrl(vetId);
      
      print('🗓️ PETICIÓN APPOINTMENTS BY VET:');
      print('URL: $url');
      print('Vet ID: $vetId');
      
      final response = await apiClient.get(url);
      
      print('✅ VET APPOINTMENTS RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data['data'] ?? [];
        return appointmentsData
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load vet appointments - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING VET APPOINTMENTS:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching vet appointments: $e');
    }
  }

  @override
  Future<AppointmentModel> getAppointmentById(String appointmentId) async {
    try {
      final url = ApiEndpoints.getAppointmentByIdUrl(appointmentId);
      
      print('🗓️ PETICIÓN APPOINTMENT BY ID:');
      print('URL: $url');
      print('Appointment ID: $appointmentId');
      
      final response = await apiClient.get(url);
      
      print('✅ APPOINTMENT BY ID RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      // Log específico para medical records
      final appointmentData = response.data['data'];
      final petData = appointmentData['pet'];
      print('🐕 PET DATA FROM API: $petData');
      
      if (petData != null && petData['medical_records'] != null) {
        print('🏥 MEDICAL RECORDS FROM API: ${petData['medical_records']}');
        print('🏥 MEDICAL RECORDS COUNT FROM API: ${(petData['medical_records'] as List).length}');
      } else {
        print('⚠️ NO MEDICAL RECORDS EN RESPUESTA DE API');
        print('🔍 Pet data keys: ${petData?.keys}');
      }
      
      if (response.statusCode == 200) {
        final appointmentData = response.data['data'];
        return AppointmentModel.fromJson(appointmentData);
      } else {
        throw Exception('Failed to load appointment - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCHING APPOINTMENT BY ID:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error fetching appointment: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final url = ApiEndpoints.createAppointmentUrl;
      
      print('📅 CREANDO NUEVA CITA:');
      print('URL: $url');
      print('Data: $appointmentData');
      
      final response = await apiClient.post(url, data: appointmentData);
      
      print('✅ CITA CREADA EXITOSAMENTE:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final appointmentData = response.data['data'];
        return AppointmentModel.fromJson(appointmentData);
      } else {
        throw Exception('Failed to create appointment - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR CREANDO CITA:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      throw Exception('Error creating appointment: $e');
    }
  }
}