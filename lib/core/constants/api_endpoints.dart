class ApiEndpoints {
  // static const String baseUrl = 'http://192.168.0.22:3000';
  static const String baseUrl = 'http://192.168.0.22:3000';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';

  // User endpoints
  static const String userUpdate = '/user';
  static const String userGetById = '/user';

  // Veterinarian endpoints
  static const String vetCreate = '/vet';
  static const String vetGetByUserId = '/vet/user';
}
