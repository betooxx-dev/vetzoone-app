class ApiEndpoints {
  static const String gatewayBaseUrl =
      'https://k2ob2307th.execute-api.us-east-2.amazonaws.com/dev';

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';

  static const String userUpdate = '/user';
  static const String userGetById = '/user';

  static const String vetCreate = '/vet';
  static const String vetGetByUserId = '/vet/user';

  static const String appointmentsByUser = '/appointments/user';
  static const String appointmentsByPet = '/appointments/pet';

  static const String medicalRecordsByPet = '/medical-record/pet';
  static const String vaccinationsByPet = '/vaccination/record';

  static const String vetSearch = '/vet/search';
  static const String vetById = '/vet';

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

  static String getMedicalRecordsByPetUrl(String petId) =>
      '$gatewayBaseUrl$medicalRecordsByPet/$petId';
  static String getVaccinationsByPetUrl(String petId) =>
      '$gatewayBaseUrl$vaccinationsByPet/$petId';

  static String get searchVeterinariansUrl => '$gatewayBaseUrl$vetSearch';
  static String getVeterinarianByIdUrl(String vetId) =>
      '$gatewayBaseUrl$vetById/$vetId';
}
