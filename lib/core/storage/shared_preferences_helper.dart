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
}
