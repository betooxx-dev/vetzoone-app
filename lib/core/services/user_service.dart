import '../storage/shared_preferences_helper.dart';

class UserService {
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final firstName = await SharedPreferencesHelper.getUserFirstName();
    final lastName = await SharedPreferencesHelper.getUserLastName();
    final email = await SharedPreferencesHelper.getUserEmail();
    final phone = await SharedPreferencesHelper.getUserPhone();
    final profilePhoto = await SharedPreferencesHelper.getUserProfilePhoto();
    final role = await SharedPreferencesHelper.getUserRole();
    final isActive = await SharedPreferencesHelper.getUserIsActive();
    final isVerified = await SharedPreferencesHelper.getUserIsVerified();
    final userId = await SharedPreferencesHelper.getUserId();

    return {
      'id': userId,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'fullName': '${firstName ?? ''} ${lastName ?? ''}',
      'email': email ?? '',
      'phone': phone ?? '',
      'profilePhoto': profilePhoto ?? '',
      'role': role ?? '',
      'isActive': isActive ?? false,
      'isVerified': isVerified ?? false,
    };
  }

  static Future<String> getUserFullName() async {
    final firstName = await SharedPreferencesHelper.getUserFirstName();
    final lastName = await SharedPreferencesHelper.getUserLastName();
    return '${firstName ?? ''} ${lastName ?? ''}';
  }

  static Future<String> getUserGreeting() async {
    final firstName = await SharedPreferencesHelper.getUserFirstName();
    final role = await SharedPreferencesHelper.getUserRole();

    if (role == 'VETERINARIAN') {
      return 'Dr. ${firstName ?? 'Usuario'}';
    } else {
      return '¡Hola, ${firstName ?? 'Usuario'}!';
    }
  }

  static Future<bool> isVeterinarian() async {
    final role = await SharedPreferencesHelper.getUserRole();
    return role == 'VETERINARIAN';
  }

  static Future<bool> isOwner() async {
    final role = await SharedPreferencesHelper.getUserRole();
    return role == 'PET_OWNER';
  }
}
