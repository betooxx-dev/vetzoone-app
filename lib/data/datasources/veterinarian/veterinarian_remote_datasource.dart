import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/veterinarian/veterinarian_model.dart';
import '../../../domain/models/search_result.dart';
import '../../../presentation/blocs/veterinarian/veterinarian_state.dart';

abstract class VeterinarianRemoteDataSource {
  Future<SearchResult> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
    bool? symptoms,
    bool? useAI,
  });
  Future<VeterinarianModel> getVeterinarianById(String vetId);
}

class VeterinarianRemoteDataSourceImpl implements VeterinarianRemoteDataSource {
  final ApiClient apiClient;

  VeterinarianRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SearchResult> searchVeterinarians({
    String? search,
    String? location,
    String? specialty,
    int? limit,
    bool? symptoms,
    bool? useAI,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (location != null && location.isNotEmpty)
        queryParams['location'] = location;
      if (specialty != null && specialty.isNotEmpty)
        queryParams['specialty'] = specialty;
      if (limit != null) queryParams['limit'] = limit;
      
      // ✨ NUEVA LÓGICA: Usar IA si está especificado o si es búsqueda por síntomas
      if (useAI == true || symptoms == true) {
        queryParams['useAI'] = 'true';
        print('🧠 Búsqueda con IA activada');
        if (symptoms == true) {
          print('   - Activada por síntomas: $search');
        }
        if (useAI == true) {
          print('   - Activada explícitamente por parámetro useAI');
        }
      }

      print('📡 Enviando petición con parámetros: $queryParams');

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

          // ✨ NUEVA LÓGICA: Extraer información de IA si está disponible
          AIPrediction? aiPrediction;
          final aiPredictionData = dataSection?['aiPrediction'];
          if (aiPredictionData != null && aiPredictionData is Map<String, dynamic>) {
            print('🤖 Predicción de IA recibida:');
            print('   - Consulta original: ${aiPredictionData['originalQuery']}');
            print('   - Especialidad predicha: ${aiPredictionData['predictedSpecialty']}');
            print('   - Confianza: ${aiPredictionData['confidence']}');
            print('   - Código de especialidad: ${aiPredictionData['specialtyCode']}');

            aiPrediction = AIPrediction(
              originalQuery: aiPredictionData['originalQuery'] ?? '',
              predictedSpecialty: aiPredictionData['predictedSpecialty'] ?? '',
              confidence: (aiPredictionData['confidence'] ?? 0.0).toDouble(),
              specialtyCode: aiPredictionData['specialtyCode'] ?? '',
            );
          }

          print('📊 Veterinarios encontrados: ${vetsData.length}');

          final veterinarians = vetsData
              .map((json) => VeterinarianModel.fromJson(json))
              .toList();

          return SearchResult(
            veterinarians: veterinarians,
            aiPrediction: aiPrediction,
          );
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
