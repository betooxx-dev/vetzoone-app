import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/pet_endpoints.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/shared_preferences_helper.dart';
import '../../models/pet/pet_model.dart';
import '../../models/appointment/appointment_model.dart';
import '../../models/medical_records/medical_record_with_treatments_model.dart';
import '../../models/medical_records/vaccination_model.dart';
import '../../models/auth/user_model.dart';

class PetDetailDTO {
  final PetModel pet;
  final List<AppointmentModel> appointments;
  PetDetailDTO({required this.pet, required this.appointments});
}

class PetCompleteDetailDTO {
  final PetModel pet;
  final List<AppointmentModel> appointments;
  final List<MedicalRecordWithTreatmentsModel> medicalRecords;
  final List<VaccinationModel> vaccinations;
  final UserModel? user; // ← Agregar información del propietario
  
  PetCompleteDetailDTO({
    required this.pet,
    required this.appointments,
    required this.medicalRecords,
    required this.vaccinations,
    this.user, // ← Agregar como parámetro opcional
  });
}

abstract class PetRemoteDataSource {
  Future<List<PetModel>> getAllPets(String userId);
  Future<PetDetailDTO> getPetById(String petId);
  Future<PetCompleteDetailDTO> getPetCompleteById(String petId);
  Future<PetModel> createPet(PetModel pet, {File? imageFile});
  Future<PetModel> updatePet(String petId, PetModel pet, {File? imageFile});
  Future<void> deletePet(String petId);
  Future<List<PetModel>> getVetPatients(String vetId);
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final Dio _dio;

  PetRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<PetModel>> getAllPets(String userId) async {
    try {
      final url = PetEndpoints.getAllPetsUrl(userId);
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PetModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pets');
      }
    } catch (e) {
      throw Exception('Error fetching pets: $e');
    }
  }

  @override
  Future<PetDetailDTO> getPetById(String petId) async {
    try {
      final url = PetEndpoints.getPetByIdUrl(petId);
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final pet = PetModel.fromJson(data['pet']);
        final appointments = (data['appointments'] as List<dynamic>? ?? [])
            .map((json) => AppointmentModel.fromJson(json)).toList();
        return PetDetailDTO(pet: pet, appointments: appointments);
      } else {
        throw Exception('Failed to load pet');
      }
    } catch (e) {
      throw Exception('Error fetching pet: $e');
    }
  }

  @override
  Future<PetModel> createPet(PetModel pet, {File? imageFile}) async {
    try {
      final url = PetEndpoints.createPetUrl();
      
      FormData formData = FormData();
      
      final petData = pet.toCreateJson();
      petData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      
      if (imageFile != null) {
        // Verificar que el archivo existe antes de enviarlo
        if (await imageFile.exists()) {
          String fileName = imageFile.path.split('/').last;
          final fileSize = await imageFile.length();
          print('📁 Archivo encontrado: ${imageFile.path}');
          print('📏 Tamaño: $fileSize bytes');
          
          formData.files.add(
            MapEntry(
              'file',
              await MultipartFile.fromFile(
                imageFile.path,
                filename: fileName,
              ),
            ),
          );
        } else {
          print('❌ Archivo no encontrado: ${imageFile.path}');
          throw Exception('Archivo de imagen no encontrado. Por favor, selecciona la imagen nuevamente.');
        }
      }
      
      print('🐾 Creating pet with FormData...');
      print('📤 FormData fields: ${formData.fields}');
      print('📤 FormData files: ${formData.files.length} files');
      
      final token = await SharedPreferencesHelper.getToken();
      print('🔑 Token available: ${token != null ? 'YES' : 'NO'}');
      
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('✅ Create pet response status: ${response.statusCode}');
      print('📦 Create pet response data: ${response.data}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return PetModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create pet - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating pet: $e');
      if (e is DioException) {
        print('❌ Dio Error type: ${e.type}');
        print('❌ Dio Error message: ${e.message}');
        print('❌ Request data: ${e.requestOptions.data}');
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      throw Exception('Error creating pet: $e');
    }
  }

  @override
  Future<PetModel> updatePet(String petId, PetModel pet, {File? imageFile}) async {
    try {
      final url = PetEndpoints.updatePetUrl(petId);
      
      FormData formData = FormData();
      
      final petData = pet.toUpdateJson();
      petData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      
      if (imageFile != null) {
        // Verificar que el archivo existe antes de enviarlo
        if (await imageFile.exists()) {
          String fileName = imageFile.path.split('/').last;
          final fileSize = await imageFile.length();
          print('📁 Archivo encontrado: ${imageFile.path}');
          print('📏 Tamaño: $fileSize bytes');
          
          formData.files.add(
            MapEntry(
              'file',
              await MultipartFile.fromFile(
                imageFile.path,
                filename: fileName,
              ),
            ),
          );
        } else {
          print('❌ Archivo no encontrado: ${imageFile.path}');
          throw Exception('Archivo de imagen no encontrado. Por favor, selecciona la imagen nuevamente.');
        }
      }
      
      print('🐾 Updating pet with FormData...');
      print('📡 URL: $url');
      print('🆔 Pet ID: $petId');
      print('📤 FormData fields: ${formData.fields}');
      print('📤 FormData files: ${formData.files.length} files');
      
      final token = await SharedPreferencesHelper.getToken();
      print('🔑 Token available: ${token != null ? 'YES' : 'NO'}');
      
      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('✅ Update pet response status: ${response.statusCode}');
      print('📦 Update pet response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return PetModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update pet - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating pet: $e');
      if (e is DioException) {
        print('❌ Dio Error type: ${e.type}');
        print('❌ Dio Error message: ${e.message}');
        print('❌ Request data: ${e.requestOptions.data}');
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      throw Exception('Error updating pet: $e');
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      final url = PetEndpoints.deletePetUrl(petId);
      final response = await _dio.delete(url);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete pet');
      }
    } catch (e) {
      throw Exception('Error deleting pet: $e');
    }
  }

  @override
  Future<List<PetModel>> getVetPatients(String vetId) async {
    try {
      final url = ApiEndpoints.getVetPatientsUrl(vetId);
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PetModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vet patients');
      }
    } catch (e) {
      print('❌ Error fetching vet patients: $e');
      throw Exception('Error fetching vet patients: $e');
    }
  }

  @override
  Future<PetCompleteDetailDTO> getPetCompleteById(String petId) async {
    try {
      final url = ApiEndpoints.getPetByIdUrl(petId);
      
      print('🐕 SOLICITANDO DETALLES COMPLETOS DEL PET:');
      print('URL: $url');
      print('Pet ID: $petId');
      
      final response = await _dio.get(url);
      
      print('📡 RESPUESTA DEL SERVIDOR:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        print('🔍 ANALIZANDO DATOS RECIBIDOS:');
        print('Data keys: ${data?.keys}');
        print('Pet data: ${data?['pet']}');
        print('Appointments data: ${data?['appointments']}');
        print('Medical Records data: ${data?['medical_records']}');
        print('Vaccinations data: ${data?['vaccinations']}');
        print('User data: ${data?['user']}'); // ← Log para user data
        
        // Parse pet data first
        final petData = data['pet'] as Map<String, dynamic>;
        print('🐕 PET DATA RECIBIDA: ${petData.keys}');
        
        // Inyectar medical_records y vaccinations en el pet data si están separados
        if (data['medical_records'] != null && petData['medical_records'] == null) {
          petData['medical_records'] = data['medical_records'];
          print('� Injecting medical_records into pet data');
        }
        
        if (data['vaccinations'] != null && petData['vaccinations'] == null) {
          petData['vaccinations'] = data['vaccinations'];
          print('🔄 Injecting vaccinations into pet data');
        }
        
        // Parse pet with injected data
        final pet = PetModel.fromJson(petData);
        print('🐕 Pet parseado exitosamente: ${pet.name}');
        
        // Parse appointments
        final appointments = (data['appointments'] as List<dynamic>? ?? [])
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
        print('📅 Appointments parseadas: ${appointments.length}');
        
        // Parse user (propietario) data
        UserModel? user;
        final userData = data['user'];
        if (userData != null) {
          try {
            user = UserModel.fromJson(userData);
            print('👤 User parseado exitosamente: ${user.fullName}');
            print('   - ID: ${user.id}');
            print('   - Email: ${user.email}');
            print('   - Phone: ${user.phone}');
          } catch (e) {
            print('❌ Error parseando user: $e');
            print('   - User data raw: $userData');
          }
        } else {
          print('⚠️ No hay información de user en la respuesta');
        }
        
        // Parse medical records with treatments (from separate data)
        final medicalRecordsData = data['medical_records'];
        print('🏥 Medical Records en JSON: $medicalRecordsData');
        
        List<MedicalRecordWithTreatmentsModel> medicalRecords = [];
        if (medicalRecordsData != null && medicalRecordsData is List) {
          medicalRecords = medicalRecordsData
              .map((json) => MedicalRecordWithTreatmentsModel.fromJson(json))
              .toList();
          print('✅ Medical Records parseados: ${medicalRecords.length}');
        } else {
          print('⚠️ No hay medical_records en el JSON del pet o no es una lista válida');
        }
        
        // Parse vaccinations (from separate data)
        final vaccinationsData = data['vaccinations'];
        print('💉 Vaccinations en JSON: $vaccinationsData');
        
        List<VaccinationModel> vaccinations = [];
        if (vaccinationsData != null && vaccinationsData is List) {
          vaccinations = vaccinationsData
              .map((json) => VaccinationModel.fromJson(json))
              .toList();
          print('✅ Vaccinations parseadas: ${vaccinations.length}');
        } else {
          print('⚠️ No hay vaccinations en el JSON del pet o no es una lista válida');
        }
        
        print('📊 RESUMEN FINAL DE PARSEO:');
        print('   - Pet: ${pet.name}');
        print('   - Appointments: ${appointments.length}');
        print('   - Medical Records: ${medicalRecords.length}');
        print('   - Vaccinations: ${vaccinations.length}');
        print('   - User: ${user != null ? user.fullName : 'NO DISPONIBLE'}');
        
        return PetCompleteDetailDTO(
          pet: pet,
          appointments: appointments,
          medicalRecords: medicalRecords,
          vaccinations: vaccinations,
          user: user, // ← Incluir user en la respuesta
        );
      } else {
        throw Exception('Failed to load pet complete details');
      }
    } catch (e) {
      print('❌ Error fetching pet complete details: $e');
      throw Exception('Error fetching pet complete details: $e');
    }
  }
}