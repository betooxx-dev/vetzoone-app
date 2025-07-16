import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authLogin}';
      final response = await apiClient.post(
        url,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authRegister}';
      
      // Logs detallados para depurar la petición
      print('🌐 PETICIÓN HTTP REGISTRO:');
      print('URL completa: $url');
      print('Datos enviados: $userData');
      print('Headers configurados en Dio: ${apiClient.dio.options.headers}');
      
      final response = await apiClient.post(
        url,
        data: userData,
      );
      
      print('✅ RESPUESTA EXITOSA:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ ERROR EN PETICIÓN HTTP:');
      print('Error completo: $e');
      
      // Si es un DioException, mostrar más detalles
      if (e is DioException) {
        print('Tipo de error: ${e.type}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        print('Request data: ${e.requestOptions.data}');
        print('Request headers: ${e.requestOptions.headers}');
      }
      
      throw Exception('Error en registro: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authLogout}';
      await apiClient.post(url);
    } catch (e) {
      throw Exception('Error en logout: $e');
    }
  }
}