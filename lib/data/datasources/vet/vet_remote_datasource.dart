import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

abstract class VetRemoteDataSource {
  Future<Map<String, dynamic>> getVetByUserId(String userId);
  Future<Map<String, dynamic>> createVet(Map<String, dynamic> vetData);
}

class VetRemoteDataSourceImpl implements VetRemoteDataSource {
  final ApiClient apiClient;

  VetRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getVetByUserId(String userId) async {
    try {
      final url = '${ApiEndpoints.baseUrl}/vet/user/$userId';
      
      print('🔍 PETICIÓN GET VET BY USER:');
      print('URL: $url');
      print('User ID: $userId');
      
      final response = await apiClient.get(url);
      
      print('✅ VET ENCONTRADO:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ ERROR AL BUSCAR VET:');
      print('Error: $e');
      
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        
        // Si es 404, significa que el veterinario no existe
        if (e.response?.statusCode == 404) {
          throw VetNotFoundException('Veterinario no encontrado para el usuario $userId');
        }
      }
      
      throw Exception('Error al buscar veterinario: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createVet(Map<String, dynamic> vetData) async {
    try {
      final url = '${ApiEndpoints.baseUrl}/vet';
      
      print('🏥 INICIANDO PETICIÓN CREAR VET:');
      print('URL: $url');
      print('Data: $vetData');
      print('Timestamp: ${DateTime.now().toIso8601String()}');
      
      final startTime = DateTime.now();
      final response = await apiClient.post(url, data: vetData);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('✅ VET CREADO EXITOSAMENTE:');
      print('Status: ${response.statusCode}');
      print('Duración: ${duration.inMilliseconds}ms');
      print('Data: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ ERROR AL CREAR VET:');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Timestamp: ${DateTime.now().toIso8601String()}');
      
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        print('Error message: ${e.message}');
        
        // Manejar específicamente errores de timeout
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception('Tiempo de conexión agotado. Verifica tu conexión a internet e intenta nuevamente.');
        } else if (e.type == DioExceptionType.sendTimeout) {
          throw Exception('Tiempo de envío agotado. La petición tardó demasiado en enviarse.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Tiempo de recepción agotado. El servidor tardó demasiado en responder.');
        }
      }
      
      throw Exception('Error al crear veterinario: $e');
    }
  }
}

// Excepción personalizada para veterinario no encontrado
class VetNotFoundException implements Exception {
  final String message;
  VetNotFoundException(this.message);
  
  @override
  String toString() => message;
} 