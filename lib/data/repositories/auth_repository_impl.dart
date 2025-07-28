import '../../core/storage/shared_preferences_helper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth/auth_remote_datasource.dart';
import '../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    
    // Validar si el usuario está activo (solo para PET_OWNER)
    final userData = response['data'] as Map<String, dynamic>?;
    if (userData != null) {
      final userRole = userData['role'] as String?;
      final isActive = userData['is_active'] as bool?;
      
      // Validar solo para usuarios con rol PET_OWNER
      if (userRole == 'PET_OWNER' && isActive == false) {
        throw ServerException(
          message: 'Tu cuenta está en revisión por comportamiento sospechoso. Por favor, contacta a soporte@zifra.mx para más información.',
        );
      }
    }
    
    // Guardar datos de login (que ya limpia los datos previos)
    await SharedPreferencesHelper.saveLoginData(response);
    
    // Pre-cargar datos del veterinario si existe
    await SharedPreferencesHelper.preloadVeterinarianData();
    
    return response;
  }

  @override
  Future<void> logout() async {
    // Solo limpiar datos locales, no hacer petición al servidor
    print('🔐 Iniciando logout local...');
    await SharedPreferencesHelper.clearLoginData();
    print('🔐 Logout local completado');
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
