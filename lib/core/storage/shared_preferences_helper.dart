import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFirstName = 'user_first_name';
  static const String _keyUserLastName = 'user_last_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserProfilePhoto = 'user_profile_photo';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserIsActive = 'user_is_active';
  static const String _keyUserIsVerified = 'user_is_verified';
  
  // Claves para datos del veterinario
  static const String _keyVetId = 'vet_id';
  static const String _keyVetName = 'vet_name';
  static const String _keyVetLicense = 'vet_license';
  static const String _keyVetDescription = 'vet_description';
  static const String _keyVetCreatedAt = 'vet_created_at';
  static const String _keyVetUpdatedAt = 'vet_updated_at';

  static Future<void> saveLoginData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = data['data'];

    await prefs.setString(_keyToken, userData['token']);
    await prefs.setString(_keyUserId, userData['id']);
    await prefs.setString(_keyUserEmail, userData['email']);
    await prefs.setString(_keyUserFirstName, userData['first_name']);
    await prefs.setString(_keyUserLastName, userData['last_name']);
    await prefs.setString(_keyUserPhone, userData['phone']);
    await prefs.setString(
      _keyUserProfilePhoto,
      userData['profile_photo'] ?? '',
    );
    await prefs.setString(_keyUserRole, userData['role']);
    await prefs.setBool(_keyUserIsActive, userData['is_active']);
    await prefs.setBool(_keyUserIsVerified, userData['is_verified']);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserFirstName);
    await prefs.remove(_keyUserLastName);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserProfilePhoto);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserIsActive);
    await prefs.remove(_keyUserIsVerified);
    
    // También limpiar datos del veterinario
    await clearVetData();
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<String?> getUserFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserFirstName);
  }

  static Future<String?> getUserLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserLastName);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPhone);
  }

  static Future<String?> getUserProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserProfilePhoto);
  }

  static Future<bool?> getUserIsActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUserIsActive);
  }

  static Future<bool?> getUserIsVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUserIsVerified);
  }

  // Métodos para actualizar campos individuales del usuario
  static Future<void> saveUserFirstName(String firstName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserFirstName, firstName);
  }

  static Future<void> saveUserLastName(String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserLastName, lastName);
  }

  static Future<void> saveUserPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserPhone, phone);
  }

  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<void> saveUserProfilePhoto(String profilePhoto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfilePhoto, profilePhoto);
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  static Future<void> saveUserIsActive(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUserIsActive, isActive);
  }

  static Future<void> saveUserIsVerified(bool isVerified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUserIsVerified, isVerified);
  }

  // Métodos para datos del veterinario
  static Future<void> saveVetData(Map<String, dynamic> vetData) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyVetId, vetData['id']?.toString() ?? '');
    await prefs.setString(_keyVetName, vetData['name']?.toString() ?? '');
    await prefs.setString(_keyVetLicense, vetData['license']?.toString() ?? '');
    await prefs.setString(_keyVetDescription, vetData['description']?.toString() ?? '');
    await prefs.setString(_keyVetCreatedAt, vetData['created_at']?.toString() ?? '');
    await prefs.setString(_keyVetUpdatedAt, vetData['updated_at']?.toString() ?? '');
    
    print('📦 Datos del veterinario guardados en SharedPreferences:');
    print('ID: ${vetData['id']}');
    print('Nombre: ${vetData['name']}');
    print('Licencia: ${vetData['license']}');
  }

  static Future<Map<String, dynamic>?> getVetData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final vetId = prefs.getString(_keyVetId);
    if (vetId == null || vetId.isEmpty) {
      return null; // No hay datos del veterinario guardados
    }
    
    return {
      'id': vetId,
      'name': prefs.getString(_keyVetName) ?? '',
      'license': prefs.getString(_keyVetLicense) ?? '',
      'description': prefs.getString(_keyVetDescription) ?? '',
      'created_at': prefs.getString(_keyVetCreatedAt) ?? '',
      'updated_at': prefs.getString(_keyVetUpdatedAt) ?? '',
    };
  }

  static Future<String?> getVetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetId);
  }

  static Future<String?> getVetName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetName);
  }

  static Future<String?> getVetLicense() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetLicense);
  }

  static Future<String?> getVetDescription() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetDescription);
  }

  static Future<void> clearVetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyVetId);
    await prefs.remove(_keyVetName);
    await prefs.remove(_keyVetLicense);
    await prefs.remove(_keyVetDescription);
    await prefs.remove(_keyVetCreatedAt);
    await prefs.remove(_keyVetUpdatedAt);
    
    print('🗑️ Datos del veterinario eliminados de SharedPreferences');
  }

  static Future<bool> hasVetProfile() async {
    final vetId = await getVetId();
    return vetId != null && vetId.isNotEmpty;
  }
}
