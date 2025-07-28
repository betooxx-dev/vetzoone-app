import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';

class AnalyticsService {
  // Usar la URL del gateway configurada
  static const String _baseUrl = ApiEndpoints.gatewayBaseUrl;
  
  static String? _currentSessionId;
  static String? _currentUserId;
  static DateTime? _sessionStartTime;
  
  // Log de configuración inicial
  static void _logConfiguration() {
    print('⚙️ [ANALYTICS-CONFIG] Base URL: $_baseUrl');
    print('⚙️ [ANALYTICS-CONFIG] Sesión actual: $_currentSessionId');
    print('⚙️ [ANALYTICS-CONFIG] Usuario actual: $_currentUserId');
  }
  
  // Generar UUID simple
  static String _generateUuid() {
    final random = Random();
    const chars = '0123456789abcdef';
    final uuid = StringBuffer();
    
    for (int i = 0; i < 32; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        uuid.write('-');
      }
      uuid.write(chars[random.nextInt(chars.length)]);
    }
    
    return uuid.toString();
  }
  
  // Inicializar sesión
  static Future<bool> startSession(String userId) async {
    try {
      _logConfiguration(); // Log de configuración inicial
      
      _currentUserId = userId;
      _currentSessionId = _generateUuid();
      _sessionStartTime = DateTime.now();
      
      final requestBody = {
        'user_id': userId,
        'session_id': _currentSessionId,
      };
      
      final url = '$_baseUrl/event-log/session/start';
      
      print('🔄 [ANALYTICS] Iniciando sesión...');
      print('📤 [REQUEST] URL: $url');
      print('📤 [REQUEST] Body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('📥 [RESPONSE] Status: ${response.statusCode}');
      print('📥 [RESPONSE] Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [SUCCESS] Sesión iniciada: $_currentSessionId');
        return true;
      } else {
        print('❌ [ERROR] Error al iniciar sesión: ${response.statusCode}');
        print('❌ [ERROR] Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [EXCEPTION] Error al iniciar sesión: $e');
      return false;
    }
  }
  
  // Finalizar sesión
  static Future<bool> endSession() async {
    if (_currentSessionId == null) {
      print('⚠️ [ANALYTICS] No hay sesión activa para finalizar');
      return false;
    }
    
    try {
      final url = '$_baseUrl/event-log/session/end/$_currentSessionId';
      
      print('🔄 [ANALYTICS] Finalizando sesión...');
      print('📤 [REQUEST] URL: $url');
      print('📤 [REQUEST] Session ID: $_currentSessionId');
      print('📤 [REQUEST] User ID: $_currentUserId');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        // No enviamos body porque el backend solo necesita el sessionId de la URL
      );
      
      print('📥 [RESPONSE] Status: ${response.statusCode}');
      print('📥 [RESPONSE] Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [SUCCESS] Sesión finalizada: $_currentSessionId');
        _resetSession();
        return true;
      } else {
        print('❌ [ERROR] Error al finalizar sesión: ${response.statusCode}');
        print('❌ [ERROR] Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [EXCEPTION] Error al finalizar sesión: $e');
      return false;
    }
  }
  
  // Registrar búsqueda
  static Future<bool> trackSearch({
    required String searchQuery,
    required String searchType,
    required int resultsCount,
    Map<String, dynamic>? filtersApplied,
  }) async {
    if (_currentUserId == null || _currentSessionId == null) {
      print('❌ [ANALYTICS] No hay sesión activa para trackear búsqueda');
      print('❌ [ANALYTICS] UserId: $_currentUserId, SessionId: $_currentSessionId');
      return false;
    }
    
    try {
      final requestBody = {
        'user_id': _currentUserId,
        'session_id': _currentSessionId,
        'search_query': searchQuery,
        'search_type': searchType,
        'results_count': resultsCount,
        'filters_applied': filtersApplied != null ? jsonEncode(filtersApplied) : null,
      };
      
      final url = '$_baseUrl/event-log/search';
      
      print('🔍 [ANALYTICS] Trackeando búsqueda...');
      print('📤 [REQUEST] URL: $url');
      print('📤 [REQUEST] Body: ${jsonEncode(requestBody)}');
      print('📤 [REQUEST] Query: "$searchQuery"');
      print('📤 [REQUEST] Type: $searchType');
      print('📤 [REQUEST] Results: $resultsCount');
      print('📤 [REQUEST] Filters: $filtersApplied');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('📥 [RESPONSE] Status: ${response.statusCode}');
      print('📥 [RESPONSE] Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [SUCCESS] Búsqueda trackeada: "$searchQuery"');
        return true;
      } else {
        print('❌ [ERROR] Error al trackear búsqueda: ${response.statusCode}');
        print('❌ [ERROR] Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [EXCEPTION] Error al trackear búsqueda: $e');
      return false;
    }
  }
  
  // Obtener actividad del usuario
  static Future<Map<String, dynamic>?> getUserActivity(String userId) async {
    try {
      final url = '$_baseUrl/event-log/user/$userId/analytics';
      
      print('📊 [ANALYTICS] Obteniendo actividad del usuario...');
      print('📤 [REQUEST] URL: $url');
      print('📤 [REQUEST] User ID: $userId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print('📥 [RESPONSE] Status: ${response.statusCode}');
      print('📥 [RESPONSE] Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [SUCCESS] Actividad obtenida correctamente');
        return data;
      } else {
        print('❌ [ERROR] Error al obtener actividad: ${response.statusCode}');
        print('❌ [ERROR] Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ [EXCEPTION] Error al obtener actividad: $e');
      return null;
    }
  }
  
  // Obtener duración promedio de sesión
  static Future<double?> getUserSessionDuration(String userId) async {
    try {
      final url = '$_baseUrl/event-log/user/$userId/session-duration';
      
      print('⏱️ [ANALYTICS] Obteniendo duración de sesión...');
      print('📤 [REQUEST] URL: $url');
      print('📤 [REQUEST] User ID: $userId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print('📥 [RESPONSE] Status: ${response.statusCode}');
      print('📥 [RESPONSE] Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final duration = data['session_duration_avg']?.toDouble();
        print('✅ [SUCCESS] Duración obtenida: ${duration}s');
        return duration;
      } else {
        print('❌ [ERROR] Error al obtener duración de sesión: ${response.statusCode}');
        print('❌ [ERROR] Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ [EXCEPTION] Error al obtener duración de sesión: $e');
      return null;
    }
  }
  
  // Métodos auxiliares
  static bool get hasActiveSession => _currentSessionId != null;
  static String? get currentSessionId => _currentSessionId;
  static String? get currentUserId => _currentUserId;
  
  // Método para inicializar sesión cuando ya tenemos userId disponible
  static Future<bool> ensureSessionActive(String userId) async {
    print('🔍 [ANALYTICS] Verificando sesión activa...');
    print('🔍 [ANALYTICS] User ID disponible: $userId');
    print('🔍 [ANALYTICS] Sesión activa: $hasActiveSession');
    print('🔍 [ANALYTICS] Usuario actual: $_currentUserId');
    
    if (hasActiveSession && _currentUserId == userId) {
      print('🔍 [ANALYTICS] ✅ Sesión ya activa para este usuario');
      return true;
    }
    
    if (hasActiveSession && _currentUserId != userId) {
      print('🔍 [ANALYTICS] ⚠️ Sesión activa para otro usuario - cerrando...');
      await endSession();
    }
    
    print('🔍 [ANALYTICS] 🚀 Iniciando nueva sesión...');
    return await startSession(userId);
  }
  
  static void _resetSession() {
    _currentSessionId = null;
    _currentUserId = null;
    _sessionStartTime = null;
  }
  
  // Método para manejar el ciclo de vida de la app
  static Future<void> handleAppStateChange(String appState, String? userId) async {
    print('📱 [ANALYTICS] Cambio de estado de app: $appState');
    print('📱 [ANALYTICS] User ID: $userId');
    print('📱 [ANALYTICS] Sesión activa: $hasActiveSession');
    
    switch (appState) {
      case 'resumed':
        if (userId != null && !hasActiveSession) {
          print('📱 [ANALYTICS] App resumed - iniciando sesión');
          await startSession(userId);
        } else {
          print('📱 [ANALYTICS] App resumed - sesión ya activa o sin usuario');
        }
        break;
      case 'paused':
      case 'detached':
        if (hasActiveSession) {
          print('📱 [ANALYTICS] App paused/detached - finalizando sesión');
          await endSession();
        } else {
          print('📱 [ANALYTICS] App paused/detached - no hay sesión activa');
        }
        break;
    }
  }
}
