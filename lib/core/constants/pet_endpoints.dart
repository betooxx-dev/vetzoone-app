class PetEndpoints {
  // static const String baseUrl = 'http://192.168.0.22:3001';
  static const String baseUrl = 'http://10.0.2.2:3001';

  static const String getAllPets = '/pet/all';
  static const String getPetById = '/pet';
  static const String createPet = '/pet';
  static const String updatePet = '/pet';
  static const String deletePet = '/pet';

  // Métodos helper para construir URLs completas
  static String getAllPetsUrl(String userId) => '$baseUrl$getAllPets/$userId';
  static String getPetByIdUrl(String petId) => '$baseUrl$getPetById/$petId';
  static String createPetUrl() => '$baseUrl$createPet';
  static String updatePetUrl(String petId) => '$baseUrl$updatePet/$petId';
  static String deletePetUrl(String petId) => '$baseUrl$deletePet/$petId';
}
