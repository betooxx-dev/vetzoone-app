import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/shared_preferences_helper.dart';

abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData);
  Future<Map<String, dynamic>> updateUserWithFile(String userId, Map<String, dynamic> userData, File file);
  Future<Map<String, dynamic>> getUserById(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await apiClient.patch(
        '${ApiEndpoints.userUpdate}/$userId',
        data: userData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['data'] != null) {
          // Actualizar SharedPreferences con los nuevos datos
          await _updateSharedPreferences(responseData['data']);
          return responseData['data'];
        }
        throw Exception('Respuesta del servidor inválida');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserWithFile(String userId, Map<String, dynamic> userData, File file) async {
    try {
      // Verificar que el archivo existe antes de enviarlo
      if (!await file.exists()) {
        print('❌ Archivo de perfil no encontrado: ${file.path}');
        throw Exception('Archivo de imagen no encontrado. Por favor, selecciona la imagen nuevamente.');
      }

      final fileSize = await file.length();
      print('📁 Archivo de perfil encontrado: ${file.path}');
      print('📏 Tamaño: $fileSize bytes');

      // Crear FormData para enviar el archivo
      final formData = FormData.fromMap({
        ...userData,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await apiClient.patch(
        '${ApiEndpoints.userUpdate}/$userId',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['data'] != null) {
          // Actualizar SharedPreferences con los nuevos datos
          await _updateSharedPreferences(responseData['data']);
          return responseData['data'];
        }
        throw Exception('Respuesta del servidor inválida');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error actualizando usuario con archivo: $e');
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.userGetById}/$userId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        throw Exception('Respuesta del servidor inválida');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  Future<void> _updateSharedPreferences(Map<String, dynamic> userData) async {
    try {
      if (userData['first_name'] != null) {
        await SharedPreferencesHelper.saveUserFirstName(userData['first_name']);
      }
      if (userData['last_name'] != null) {
        await SharedPreferencesHelper.saveUserLastName(userData['last_name']);
      }
      if (userData['phone'] != null) {
        await SharedPreferencesHelper.saveUserPhone(userData['phone']);
      }
      if (userData['email'] != null) {
        await SharedPreferencesHelper.saveUserEmail(userData['email']);
      }
      if (userData['profile_photo'] != null) {
        await SharedPreferencesHelper.saveUserProfilePhoto(userData['profile_photo']);
      }
      if (userData['role'] != null) {
        await SharedPreferencesHelper.saveUserRole(userData['role']);
      }
      if (userData['is_active'] != null) {
        await SharedPreferencesHelper.saveUserIsActive(userData['is_active']);
      }
      if (userData['is_verified'] != null) {
        await SharedPreferencesHelper.saveUserIsVerified(userData['is_verified']);
      }
      
      print('✅ SharedPreferences actualizadas con datos del usuario completos');
      print('📋 Datos actualizados: ${userData.keys.join(', ')}');
    } catch (e) {
      print('❌ Error actualizando SharedPreferences: $e');
    }
  }
} 