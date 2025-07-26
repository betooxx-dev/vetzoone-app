abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData);
  Future<bool> isLoggedIn();
}
