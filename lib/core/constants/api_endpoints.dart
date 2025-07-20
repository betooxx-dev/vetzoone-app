class ApiEndpoints {
  static const String gatewayBaseUrl =
      'https://k2ob2307th.execute-api.us-east-2.amazonaws.com/dev';

  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';

  // User endpoints
  static const String userUpdate = '/user';
  static const String userGetById = '/user';

  // Veterinarian endpoints
  static const String vetCreate = '/vet';
  static const String vetGetByUserId = '/vet/user';

  // Appointment endpoints
  static const String appointmentsByUser = '/appointments/user';
  static const String appointmentsByPet = '/appointments/pet';

  // Helper methods for complete URLs
  static String get baseUrl => gatewayBaseUrl;
  static String get authLoginUrl => '$gatewayBaseUrl$authLogin';
  static String get authRegisterUrl => '$gatewayBaseUrl$authRegister';
  static String get authLogoutUrl => '$gatewayBaseUrl$authLogout';

  static String getUserByIdUrl(String userId) =>
      '$gatewayBaseUrl$userGetById/$userId';
  static String getVetByUserIdUrl(String userId) =>
      '$gatewayBaseUrl$vetGetByUserId/$userId';
  static String get createVetUrl => '$gatewayBaseUrl$vetCreate';

  static String getAppointmentsByUserUrl(String userId) =>
      '$gatewayBaseUrl$appointmentsByUser/$userId';
  static String getAppointmentsByPetUrl(String petId) =>
      '$gatewayBaseUrl$appointmentsByPet/$petId';
}
