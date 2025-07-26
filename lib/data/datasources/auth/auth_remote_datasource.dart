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
      final response = await apiClient.post(
        ApiEndpoints.authLoginUrl,
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
      print('🌐 PETICIÓN HTTP REGISTRO:');
      print('URL completa: ${ApiEndpoints.authRegisterUrl}');
      print('Datos enviados: $userData');
      print('Headers configurados en Dio: ${apiClient.dio.options.headers}');
      
      final response = await apiClient.post(
        ApiEndpoints.authRegisterUrl,
        data: userData,
      );
      
      print('✅ RESPUESTA EXITOSA:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ ERROR EN PETICIÓN HTTP:');
      print('Error completo: $e');
      
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
      await apiClient.post(ApiEndpoints.authLogoutUrl);
    } catch (e) {
      throw Exception('Error en logout: $e');
    }
  }
}