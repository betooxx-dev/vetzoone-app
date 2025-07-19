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
      final url = '${ApiEndpoints.appointmentBaseUrl}${ApiEndpoints.appointmentsByUser}/$userId';
      
      final queryParams = {
        'dateFrom': dateFrom.toIso8601String().split('T')[0], // Solo la fecha en formato YYYY-MM-DD
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
      final url = '${ApiEndpoints.appointmentBaseUrl}/pet/$petId';
      final response = await apiClient.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data['data'] ?? [];
        return appointmentsData.map((json) => AppointmentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments by pet');
      }
    } catch (e) {
      throw Exception('Error fetching appointments by pet: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAllAppointmentsByUserId(String userId) async {
    try {
      final url = '${ApiEndpoints.appointmentBaseUrl}${ApiEndpoints.appointmentsByUser}/$userId';
      final response = await apiClient.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data['data'] ?? [];
        return appointmentsData.map((json) => AppointmentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all appointments');
      }
    } catch (e) {
      throw Exception('Error fetching all appointments: $e');
    }
  }
} 