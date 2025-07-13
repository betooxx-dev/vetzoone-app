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
      final response = await apiClient.post(
        url,
        data: userData,
      );
      return response.data;
    } catch (e) {
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