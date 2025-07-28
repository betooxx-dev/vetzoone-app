class AnalyticsConstants {
  // Tipos de búsqueda para analytics (DEBEN coincidir con el backend)
  static const String searchTypeVeterinarian = 'veterinarian';
  static const String searchTypeAppointment = 'appointment';
  static const String searchTypePet = 'pet';
  static const String searchTypeGeneral = 'general';
  
  // Nota: 'symptoms' no es válido en el backend, se mapea a 'veterinarian'
  
  // Mapear especialidades a tipos de búsqueda
  static String getSearchTypeFromSpecialty(String specialty) {
    final lowerSpecialty = specialty.toLowerCase();
    
    if (lowerSpecialty.contains('veterinari') || 
        lowerSpecialty.contains('doctor') || 
        lowerSpecialty.contains('médico')) {
      return searchTypeVeterinarian;
    }
    
    if (lowerSpecialty.contains('cita') || 
        lowerSpecialty.contains('appointment') || 
        lowerSpecialty.contains('consulta')) {
      return searchTypeAppointment;
    }
    
    if (lowerSpecialty.contains('mascota') || 
        lowerSpecialty.contains('pet') || 
        lowerSpecialty.contains('animal')) {
      return searchTypePet;
    }
    
    return searchTypeGeneral;
  }
  
  // Detectar si es búsqueda por síntomas
  static bool isSymptomSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final symptomKeywords = [
      'síntoma', 'sintoma', 'dolor', 'vomit', 'diarrea', 'fiebre',
      'enferm', 'problem', 'mal', 'decaído', 'no come', 'no bebe',
      'sangre', 'herida', 'cojea', 'respira mal', 'tos'
    ];
    
    return symptomKeywords.any((keyword) => lowerQuery.contains(keyword));
  }
  
  // Obtener tipo de búsqueda basado en la query
  static String getSearchType(String query, String? specialty, bool isAISearch) {
    print('🏷️ [ANALYTICS-CONSTANTS] Determinando tipo de búsqueda...');
    print('🏷️ [ANALYTICS-CONSTANTS] Query: "$query"');
    print('🏷️ [ANALYTICS-CONSTANTS] Specialty: $specialty');
    print('🏷️ [ANALYTICS-CONSTANTS] Is AI Search: $isAISearch');
    
    // Las búsquedas por síntomas/IA se consideran búsquedas de veterinarios
    if (isAISearch || isSymptomSearch(query)) {
      print('🏷️ [ANALYTICS-CONSTANTS] Búsqueda por síntomas/IA -> mapeando a: $searchTypeVeterinarian');
      return searchTypeVeterinarian;
    }
    
    if (specialty != null) {
      final type = getSearchTypeFromSpecialty(specialty);
      print('🏷️ [ANALYTICS-CONSTANTS] Tipo por especialidad: $type');
      return type;
    }
    
    print('🏷️ [ANALYTICS-CONSTANTS] Tipo por defecto: $searchTypeGeneral');
    return searchTypeGeneral;
  }
}
