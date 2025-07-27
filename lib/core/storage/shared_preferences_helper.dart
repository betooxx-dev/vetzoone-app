import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../injection/injection.dart';
import '../../data/datasources/vet/vet_remote_datasource.dart';

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
  static const String _keyVetProfilePhoto = 'vet_profile_photo';
  static const String _keyVetSpecialties = 'vet_specialties';
  static const String _keyVetYearsExperience = 'vet_years_experience';
  static const String _keyVetLocationCity = 'vet_location_city';
  static const String _keyVetLocationState = 'vet_location_state';
  static const String _keyVetBio = 'vet_bio';
  static const String _keyVetServices = 'vet_services';
  static const String _keyVetConsultationFee = 'vet_consultation_fee';
  static const String _keyVetAnimalsServed = 'vet_animals_served';
  static const String _keyVetAvailability = 'vet_availability';

  static Future<void> saveLoginData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 🧹 Limpiar datos previos antes de guardar los nuevos
    print('🧹 Limpiando datos previos antes del nuevo login...');
    await clearAllData();
    
    final userData = data['data'];

    print('💾 Guardando nuevos datos de login...');
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
    
    print('✅ Datos de login guardados correctamente');
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
    print('🧹 Iniciando limpieza de datos de logout...');
    
    // Limpiar todos los datos sin importar el rol del usuario
    print('�️ Limpiando todos los datos de SharedPreferences...');
    await clearAllData();
    
    print('✅ Limpieza de datos de logout finalizada');
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
  static Future<void> saveVetProfileFromResponse(Map<String, dynamic> response) async {
    print('🔧 GUARDANDO RESPUESTA COMPLETA DEL VETERINARIO:');
    print('Response completo: $response');
    print('Response keys: ${response.keys}');
    print('Response.data: ${response['data']}');
    
    // Validar que la respuesta no sea null
    if (response.isEmpty) {
      print('❌ ERROR: Response está vacío!');
      throw Exception('La respuesta del servidor está vacía');
    }
    
    final vetData = response['data'];
    print('🔍 INSPECCIONANDO VET DATA:');
    print('vetData: $vetData');
    print('vetData.keys: ${vetData?.keys}');
    print('vetData.runtimeType: ${vetData.runtimeType}');
    
    // Validar que vetData no sea null
    if (vetData == null) {
      print('❌ ERROR: vetData es null!');
      throw Exception('Los datos del veterinario no están disponibles en la respuesta del servidor');
    }
    
    // Validar que vetData sea un mapa
    if (vetData is! Map<String, dynamic>) {
      print('❌ ERROR: vetData no es un Map válido!');
      throw Exception('Los datos del veterinario tienen un formato inválido: ${vetData.runtimeType}');
    }
    
    final userData = vetData['user'];
    print('🔍 INSPECCIONANDO USER DATA:');
    print('userData: $userData');

    print('🆔 EXTRAYENDO IDs:');
    final vetId = vetData['id'];
    final userId = userData?['id'];
    final license = vetData['license'];
    
    print('Vet ID raw: $vetId');
    print('Vet ID type: ${vetId.runtimeType}');
    print('Vet ID toString: ${vetId?.toString()}');
    print('User ID: $userId');
    print('License: $license');

    // Validar que tengamos datos mínimos necesarios
    if (vetId == null) {
      print('❌ ERROR: Vet ID es null!');
      throw Exception('El perfil del veterinario no tiene un ID válido');
    }
    
    if (userData == null) {
      print('❌ ERROR: User data es null!');
      throw Exception('Los datos del usuario no están disponibles en el perfil del veterinario');
    }
    
    if (userId == null) {
      print('❌ ERROR: User ID es null!');
      throw Exception('El usuario asociado al veterinario no tiene un ID válido');
    }

    try {
      // Actualizar datos del usuario con la información más reciente
      await _updateUserDataFromVetResponse(userData);
      print('✅ Datos del usuario actualizados correctamente');

      // Guardar todos los datos del veterinario
      await _saveCompleteVetData(vetData);
      print('✅ Datos del veterinario guardados correctamente');

      // Verificar que se guardó correctamente
      final savedVetId = await getVetId();
      final savedVetData = await getVetData();
      print('✅ VERIFICACIÓN POST-GUARDADO:');
      print('Vet ID guardado: $savedVetId');
      print('Vet Data disponible: ${savedVetData != null}');

      if (savedVetId == null || savedVetId.isEmpty) {
        throw Exception('Error al verificar el guardado: El Vet ID no se guardó correctamente');
      }

      print('📦 Perfil completo del veterinario guardado exitosamente en SharedPreferences');
      print('Usuario actualizado: ${userData['first_name']} ${userData['last_name']}');
      print('Veterinario: ${vetData['license']} - Especialidades: ${vetData['specialties']}');
    } catch (e) {
      print('❌ Error durante el proceso de guardado: $e');
      throw Exception('Error al guardar los datos del veterinario: $e');
    }
  }

  static Future<void> _updateUserDataFromVetResponse(Map<String, dynamic>? userData) async {
    if (userData == null) {
      print('⚠️ WARNING: userData es null, saltando actualización de usuario');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Actualizar datos del usuario con validaciones
      await prefs.setString(_keyUserFirstName, userData['first_name']?.toString() ?? '');
      await prefs.setString(_keyUserLastName, userData['last_name']?.toString() ?? '');
      await prefs.setString(_keyUserPhone, userData['phone']?.toString() ?? '');
      await prefs.setString(_keyUserProfilePhoto, userData['profile_photo']?.toString() ?? '');
      await prefs.setString(_keyUserEmail, userData['email']?.toString() ?? '');
      await prefs.setBool(_keyUserIsActive, userData['is_active'] == true);
      await prefs.setBool(_keyUserIsVerified, userData['is_verified'] == true);
      
      print('✅ Datos del usuario actualizados desde respuesta del veterinario');
    } catch (e) {
      print('❌ Error actualizando datos del usuario: $e');
      throw Exception('Error al actualizar datos del usuario: $e');
    }
  }

  static Future<void> _saveCompleteVetData(Map<String, dynamic> vetData) async {
    if (vetData.isEmpty) {
      throw Exception('Los datos del veterinario están vacíos');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('💾 GUARDANDO DATOS COMPLETOS DEL VETERINARIO:');
      print('Vet Data recibido: $vetData');
      
      final vetId = vetData['id']?.toString() ?? '';
      print('🆔 VET ID A GUARDAR: "$vetId"');
      print('🔑 Key para VET ID: $_keyVetId');
      
      if (vetId.isEmpty) {
        throw Exception('El ID del veterinario está vacío o es inválido');
      }
      
      await prefs.setString(_keyVetId, vetId);
      print('✅ Vet ID guardado en SharedPreferences');
      
      // Guardar otros datos con validaciones de tipo
      await prefs.setString(_keyVetLicense, vetData['license']?.toString() ?? '');
      await prefs.setString(_keyVetProfilePhoto, vetData['profile_photo']?.toString() ?? '');
      
      // Manejar arrays JSON de manera segura
      try {
        await prefs.setString(_keyVetSpecialties, jsonEncode(vetData['specialties'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando specialties, usando array vacío: $e');
        await prefs.setString(_keyVetSpecialties, jsonEncode([]));
      }
      
      // Manejar números de manera segura
      final yearsExperience = vetData['years_experience'];
      if (yearsExperience is int) {
        await prefs.setInt(_keyVetYearsExperience, yearsExperience);
      } else if (yearsExperience is String) {
        final parsed = int.tryParse(yearsExperience) ?? 0;
        await prefs.setInt(_keyVetYearsExperience, parsed);
      } else {
        await prefs.setInt(_keyVetYearsExperience, 0);
      }
      
      await prefs.setString(_keyVetLocationCity, vetData['location_city']?.toString() ?? '');
      await prefs.setString(_keyVetLocationState, vetData['location_state']?.toString() ?? '');
      await prefs.setString(_keyVetBio, vetData['bio']?.toString() ?? '');
      
      // Manejar otros arrays JSON de manera segura
      try {
        await prefs.setString(_keyVetServices, jsonEncode(vetData['services'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando services, usando array vacío: $e');
        await prefs.setString(_keyVetServices, jsonEncode([]));
      }
      
      // Manejar consultation_fee de manera segura
      final consultationFee = vetData['consultation_fee'];
      if (consultationFee is double) {
        await prefs.setDouble(_keyVetConsultationFee, consultationFee);
      } else if (consultationFee is int) {
        await prefs.setDouble(_keyVetConsultationFee, consultationFee.toDouble());
      } else if (consultationFee is String) {
        final parsed = double.tryParse(consultationFee) ?? 0.0;
        await prefs.setDouble(_keyVetConsultationFee, parsed);
      } else {
        await prefs.setDouble(_keyVetConsultationFee, 0.0);
      }
      
      // Manejar arrays restantes de manera segura
      try {
        await prefs.setString(_keyVetAnimalsServed, jsonEncode(vetData['animals_served'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando animals_served, usando array vacío: $e');
        await prefs.setString(_keyVetAnimalsServed, jsonEncode([]));
      }
      
      try {
        await prefs.setString(_keyVetAvailability, jsonEncode(vetData['availability'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando availability, usando array vacío: $e');
        await prefs.setString(_keyVetAvailability, jsonEncode([]));
      }
      
      // Guardar timestamps si están disponibles
      await prefs.setString(_keyVetCreatedAt, vetData['created_at']?.toString() ?? '');
      await prefs.setString(_keyVetUpdatedAt, vetData['updated_at']?.toString() ?? '');
      
      // Construir nombre completo del veterinario desde userData si está disponible
      final userData = vetData['user'];
      if (userData != null) {
        final fullName = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
        await prefs.setString(_keyVetName, fullName);
        print('✅ Nombre del veterinario guardado: $fullName');
      } else {
        print('⚠️ userData no disponible, no se puede construir el nombre completo');
      }
      
      // Guardar descripción (bio) como descripción también
      await prefs.setString(_keyVetDescription, vetData['bio']?.toString() ?? '');
      
      // Verificación inmediata
      final savedVetId = prefs.getString(_keyVetId);
      print('🔍 VERIFICACIÓN INMEDIATA - Vet ID leído: "$savedVetId"');
      
      print('✅ Todos los datos del veterinario guardados exitosamente');
    } catch (e) {
      print('❌ Error crítico guardando datos del veterinario: $e');
      throw Exception('Error al guardar datos del veterinario en almacenamiento local: $e');
    }
  }

  static Future<void> saveVetData(Map<String, dynamic> vetData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('💾 GUARDANDO DATOS DEL VETERINARIO (método saveVetData):');
      print('Vet Data recibido: $vetData');
      
      // Guardar datos básicos con validaciones
      await prefs.setString(_keyVetId, vetData['id']?.toString() ?? '');
      await prefs.setString(_keyVetName, vetData['name']?.toString() ?? '');
      await prefs.setString(_keyVetLicense, vetData['license']?.toString() ?? '');
      await prefs.setString(_keyVetDescription, vetData['description']?.toString() ?? '');
      await prefs.setString(_keyVetCreatedAt, vetData['created_at']?.toString() ?? '');
      await prefs.setString(_keyVetUpdatedAt, vetData['updated_at']?.toString() ?? '');
      
      // Guardar datos adicionales si están disponibles
      await prefs.setString(_keyVetProfilePhoto, vetData['profile_photo']?.toString() ?? '');
      await prefs.setString(_keyVetBio, vetData['bio']?.toString() ?? '');
      await prefs.setString(_keyVetLocationCity, vetData['location_city']?.toString() ?? '');
      await prefs.setString(_keyVetLocationState, vetData['location_state']?.toString() ?? '');
      
      // Manejar números de manera segura
      final yearsExperience = vetData['years_experience'];
      if (yearsExperience is int) {
        await prefs.setInt(_keyVetYearsExperience, yearsExperience);
      } else if (yearsExperience is String) {
        final parsed = int.tryParse(yearsExperience) ?? 0;
        await prefs.setInt(_keyVetYearsExperience, parsed);
      } else {
        await prefs.setInt(_keyVetYearsExperience, yearsExperience ?? 0);
      }
      
      final consultationFee = vetData['consultation_fee'];
      if (consultationFee is double) {
        await prefs.setDouble(_keyVetConsultationFee, consultationFee);
      } else if (consultationFee is int) {
        await prefs.setDouble(_keyVetConsultationFee, consultationFee.toDouble());
      } else if (consultationFee is String) {
        final parsed = double.tryParse(consultationFee) ?? 0.0;
        await prefs.setDouble(_keyVetConsultationFee, parsed);
      } else {
        await prefs.setDouble(_keyVetConsultationFee, consultationFee?.toDouble() ?? 0.0);
      }
      
      // Manejar arrays JSON de manera segura
      try {
        await prefs.setString(_keyVetSpecialties, jsonEncode(vetData['specialties'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando specialties: $e');
        await prefs.setString(_keyVetSpecialties, jsonEncode([]));
      }
      
      try {
        await prefs.setString(_keyVetServices, jsonEncode(vetData['services'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando services: $e');
        await prefs.setString(_keyVetServices, jsonEncode([]));
      }
      
      try {
        await prefs.setString(_keyVetAnimalsServed, jsonEncode(vetData['animals_served'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando animals_served: $e');
        await prefs.setString(_keyVetAnimalsServed, jsonEncode([]));
      }
      
      try {
        await prefs.setString(_keyVetAvailability, jsonEncode(vetData['availability'] ?? []));
      } catch (e) {
        print('⚠️ Error guardando availability: $e');
        await prefs.setString(_keyVetAvailability, jsonEncode([]));
      }
      
      print('📦 Datos del veterinario guardados exitosamente en SharedPreferences:');
      print('ID: ${vetData['id']}');
      print('Nombre: ${vetData['name']}');
      print('Licencia: ${vetData['license']}');
    } catch (e) {
      print('❌ Error en saveVetData: $e');
      throw Exception('Error al guardar datos del veterinario: $e');
    }
  }

  static Future<Map<String, dynamic>?> getVetData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final vetId = prefs.getString(_keyVetId);
    print('🔍 GET VET DATA LLAMADO:');
    print('Vet ID encontrado: "$vetId"');
    
    if (vetId == null || vetId.isEmpty) {
      print('❌ GET VET DATA: Vet ID es null o vacío, retornando null');
      return null; // No hay datos del veterinario guardados
    }
    
    print('✅ GET VET DATA: Vet ID válido, construyendo datos...');
    
    // Decodificar arrays JSON
    List<dynamic> specialties = [];
    List<dynamic> services = [];
    List<dynamic> animalsServed = [];
    List<dynamic> availability = [];
    
    try {
      final specialtiesJson = prefs.getString(_keyVetSpecialties);
      if (specialtiesJson != null && specialtiesJson.isNotEmpty) {
        specialties = jsonDecode(specialtiesJson);
      }
      
      final servicesJson = prefs.getString(_keyVetServices);
      if (servicesJson != null && servicesJson.isNotEmpty) {
        services = jsonDecode(servicesJson);
      }
      
      final animalsServedJson = prefs.getString(_keyVetAnimalsServed);
      if (animalsServedJson != null && animalsServedJson.isNotEmpty) {
        animalsServed = jsonDecode(animalsServedJson);
      }
      
      final availabilityJson = prefs.getString(_keyVetAvailability);
      if (availabilityJson != null && availabilityJson.isNotEmpty) {
        availability = jsonDecode(availabilityJson);
      }
    } catch (e) {
      print('⚠️ Error al decodificar arrays JSON del veterinario: $e');
    }
    
    return {
      'id': vetId,
      'name': prefs.getString(_keyVetName) ?? '',
      'license': prefs.getString(_keyVetLicense) ?? '',
      'description': prefs.getString(_keyVetDescription) ?? '',
      'profile_photo': prefs.getString(_keyVetProfilePhoto) ?? '',
      'specialties': specialties,
      'years_experience': prefs.getInt(_keyVetYearsExperience) ?? 0,
      'location_city': prefs.getString(_keyVetLocationCity) ?? '',
      'location_state': prefs.getString(_keyVetLocationState) ?? '',
      'bio': prefs.getString(_keyVetBio) ?? '',
      'services': services,
      'consultation_fee': prefs.getDouble(_keyVetConsultationFee) ?? 0.0,
      'animals_served': animalsServed,
      'availability': availability,
      'created_at': prefs.getString(_keyVetCreatedAt) ?? '',
      'updated_at': prefs.getString(_keyVetUpdatedAt) ?? '',
    };
  }

  static Future<String?> getVetId() async {
    final prefs = await SharedPreferences.getInstance();
    final vetId = prefs.getString(_keyVetId);
    print('🔍 GET VET ID LLAMADO:');
    print('Key: $_keyVetId');
    print('Valor encontrado: "$vetId"');
    print('Es null: ${vetId == null}');
    print('Es empty: ${vetId?.isEmpty ?? true}');
    return vetId;
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
    await prefs.remove(_keyVetProfilePhoto);
    await prefs.remove(_keyVetSpecialties);
    await prefs.remove(_keyVetYearsExperience);
    await prefs.remove(_keyVetLocationCity);
    await prefs.remove(_keyVetLocationState);
    await prefs.remove(_keyVetBio);
    await prefs.remove(_keyVetServices);
    await prefs.remove(_keyVetConsultationFee);
    await prefs.remove(_keyVetAnimalsServed);
    await prefs.remove(_keyVetAvailability);
    
    print('🗑️ Datos del veterinario eliminados de SharedPreferences');
  }

  static Future<void> clearUserData() async {
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
    
    print('🗑️ Datos del usuario eliminados de SharedPreferences');
  }

  /// Método de emergencia para limpiar ABSOLUTAMENTE TODOS los datos
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🔥 LIMPIEZA COMPLETA: Todos los datos eliminados de SharedPreferences');
  }

  /// Método para pre-cargar datos del veterinario después del login
  static Future<bool> preloadVeterinarianData() async {
    try {
      print('🔄 Pre-cargando datos del veterinario...');
      
      // Obtener userId del token guardado
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        print('❌ No se encontró userId después del login');
        return false;
      }
      
      print('👤 Usuario ID encontrado: $userId');
      
      // Obtener dependencia del data source
      final vetDataSource = sl<VetRemoteDataSource>();
      
      // Intentar obtener datos del veterinario
      final vetResponse = await vetDataSource.getVetByUserId(userId);
      
      if (vetResponse.isEmpty) {
        print('ℹ️ Usuario no tiene perfil de veterinario');
        return true; // No es error, simplemente no es veterinario
      }
      
      // Guardar datos del veterinario
      final fullResponse = vetResponse.containsKey('message')
          ? vetResponse
          : {'message': 'Vet retrieved successfully', 'data': vetResponse};
      
      await saveVetProfileFromResponse(fullResponse);
      print('✅ Datos del veterinario pre-cargados exitosamente');
      
      return true;
    } catch (e) {
      print('⚠️ Error pre-cargando datos del veterinario: $e');
      // No es un error crítico, el usuario puede continuar
      return true;
    }
  }

  static Future<bool> hasVetProfile() async {
    final vetId = await getVetId();
    return vetId != null && vetId.isNotEmpty;
  }

  static Future<List<String>> getVetSpecialties() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final specialtiesJson = prefs.getString(_keyVetSpecialties);
      if (specialtiesJson != null && specialtiesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(specialtiesJson);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('⚠️ Error al obtener especialidades del veterinario: $e');
    }
    return [];
  }

  static Future<int> getVetYearsExperience() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyVetYearsExperience) ?? 0;
  }

  static Future<String?> getVetLocationCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetLocationCity);
  }

  static Future<String?> getVetLocationState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetLocationState);
  }

  static Future<String?> getVetBio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetBio);
  }

  static Future<List<String>> getVetServices() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final servicesJson = prefs.getString(_keyVetServices);
      if (servicesJson != null && servicesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(servicesJson);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('⚠️ Error al obtener servicios del veterinario: $e');
    }
    return [];
  }

  static Future<double> getVetConsultationFee() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyVetConsultationFee) ?? 0.0;
  }

  static Future<List<String>> getVetAnimalsServed() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final animalsServedJson = prefs.getString(_keyVetAnimalsServed);
      if (animalsServedJson != null && animalsServedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(animalsServedJson);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('⚠️ Error al obtener animales atendidos del veterinario: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getVetAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final availabilityJson = prefs.getString(_keyVetAvailability);
      if (availabilityJson != null && availabilityJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(availabilityJson);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('⚠️ Error al obtener disponibilidad del veterinario: $e');
    }
    return [];
  }

  static Future<String?> getVetProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVetProfilePhoto);
  }
}
