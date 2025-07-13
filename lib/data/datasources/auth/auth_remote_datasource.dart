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
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await apiClient.post(
      ApiEndpoints.authRegister,
      data: userData,
    );
    return response.data;
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.authLogout);
  }
}
