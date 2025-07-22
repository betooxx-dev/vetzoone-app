import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/veterinarian/veterinarian_model.dart';

abstract class VeterinarianRemoteDataSource {
  Future<List<VeterinarianModel>> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
  });
  Future<VeterinarianModel> getVeterinarianById(String vetId);
}

class VeterinarianRemoteDataSourceImpl implements VeterinarianRemoteDataSource {
  final ApiClient apiClient;

  VeterinarianRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VeterinarianModel>> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (location != null && location.isNotEmpty)
        queryParams['location'] = location;
      if (specialty != null && specialty.isNotEmpty)
        queryParams['specialty'] = specialty;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiEndpoints.searchVeterinariansUrl,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          // La estructura es: data -> vets -> []
          final dataSection = responseData['data'] as Map<String, dynamic>?;
          final List<dynamic> vetsData = dataSection?['vets'] ?? [];

          print('📊 Veterinarios encontrados: ${vetsData.length}');

          return vetsData
              .map((json) => VeterinarianModel.fromJson(json))
              .toList();
        }
      }
      throw Exception('Error HTTP: ${response.statusCode}');
    } catch (e) {
      print('❌ ERROR: $e');
      throw Exception('Error al buscar veterinarios: $e');
    }
  }

  @override
  Future<VeterinarianModel> getVeterinarianById(String vetId) async {
    try {
      final url = ApiEndpoints.getVeterinarianByIdUrl(vetId);

      print('🔍 PETICIÓN PERFIL VETERINARIO:');
      print('URL: $url');
      print('Vet ID: $vetId');

      final response = await apiClient.get(url);

      print('✅ RESPUESTA PERFIL VETERINARIO:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return VeterinarianModel.fromJson(responseData['data']);
        } else {
          throw Exception('Formato de respuesta inesperado para perfil');
        }
      } else {
        throw Exception('Error HTTP al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR OBTENIENDO PERFIL VETERINARIO:');
      print('Error: $e');

      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }

      throw Exception('Error al obtener veterinario: $e');
    }
  }
}
