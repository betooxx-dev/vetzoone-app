import '../../core/storage/shared_preferences_helper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    await SharedPreferencesHelper.saveLoginData(response);
    return response;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      print('Error al hacer logout en servidor: $e');
    } finally {
      await SharedPreferencesHelper.clearLoginData();
    }
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await remoteDataSource.register(userData);
  }

  @override
  Future<bool> isLoggedIn() async {
    return await SharedPreferencesHelper.isLoggedIn();
  }
}
