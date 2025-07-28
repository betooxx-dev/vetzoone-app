# 📊 Implementación Completa de Analytics en Flutter

## ✅ **Archivos Implementados**

### 1. **Servicio de Analítica**
📁 `lib/core/services/analytics_service.dart`
- ✅ Gestión de sesiones de usuario
- ✅ Tracking de búsquedas  
- ✅ Integración con backend de analítica
- ✅ Manejo del ciclo de vida de la app

### 2. **Mixin para Ciclo de Vida**
📁 `lib/core/mixins/analytics_lifecycle_mixin.dart`
- ✅ Manejo automático de sesiones al abrir/cerrar app
- ✅ Integración con `WidgetsBindingObserver`

### 3. **Constantes de Analítica**
📁 `lib/core/constants/analytics_constants.dart`
- ✅ Tipos de búsqueda
- ✅ Mapeo de especialidades a categorías
- ✅ Detección de búsquedas por síntomas

### 4. **Integración en Página de Búsqueda**
📁 `lib/presentation/pages/owner/veterinarians/search_veterinarians_page.dart`
- ✅ Tracking automático de sesiones
- ✅ Tracking de todas las búsquedas
- ✅ Detección de filtros aplicados
- ✅ Conteo de resultados

## 🚀 **Funcionalidades Implementadas**

### **Gestión de Sesiones:**
- ✅ **Inicio automático** cuando abre la app
- ✅ **Cierre automático** cuando cierra la app  
- ✅ **Prevención de duplicados** (cierra sesiones previas)
- ✅ **Manejo de estados** de la aplicación (paused, resumed, etc.)

### **Tracking de Búsquedas:**
- ✅ **Búsquedas manuales** (con texto + filtros)
- ✅ **Búsquedas por síntomas con IA**
- ✅ **Búsquedas solo con filtros**
- ✅ **Categorización automática** (veterinarian, symptoms, general, etc.)
- ✅ **Captura de filtros aplicados** (ubicación, especialidad)
- ✅ **Conteo de resultados** automático

### **Integración con Backend:**
- ✅ **Endpoints configurados** para analytic-ms
- ✅ **Manejo de errores** en requests
- ✅ **Logs de debug** para troubleshooting
- ✅ **URL del gateway** configurada correctamente

## 📡 **Endpoints Utilizados**

```bash
# Gestión de sesiones
POST {{gateway}}/event-log/session/start
POST {{gateway}}/event-log/session/end/:sessionId

# Tracking de búsquedas  
POST {{gateway}}/event-log/search

# Consulta de analíticas
GET {{gateway}}/event-log/user/:userId/activity
GET {{gateway}}/event-log/user/:userId/session-duration
```

## 🔄 **Flujo de Funcionamiento**

### **1. Al Abrir la App:**
```dart
// Se ejecuta automáticamente via AnalyticsAppLifecycleMixin
AnalyticsService.startSession(userId)
```

### **2. Al Realizar Búsqueda:**
```dart
// En _performManualSearch() o _searchBySymptomsWithAI()
_trackSearch(
  query: "veterinario cerca de mi",
  isAISearch: false,
)

// Se envía automáticamente:
AnalyticsService.trackSearch(
  searchQuery: "veterinario cerca de mi",
  searchType: "veterinarian", 
  resultsCount: 15,
  filtersApplied: {...},
)
```

### **3. Al Cerrar la App:**
```dart
// Se ejecuta automáticamente via AnalyticsAppLifecycleMixin  
AnalyticsService.endSession()
```

## 🎯 **Datos Capturados**

### **Por Sesión:**
- ✅ `user_id` - ID del usuario logueado
- ✅ `session_id` - UUID único por sesión
- ✅ `session_start` - Timestamp de inicio
- ✅ `session_end` - Timestamp de fin
- ✅ `total_searches` - Contador automático
- ✅ `session_duration_seconds` - Calculado automáticamente

### **Por Búsqueda:**
- ✅ `search_query` - Texto ingresado por el usuario
- ✅ `search_type` - Categoría (veterinarian, symptoms, general, etc.)
- ✅ `results_count` - Número de resultados obtenidos
- ✅ `filters_applied` - JSON con filtros activos:
  ```json
  {
    "location": "Tuxtla Gutiérrez",
    "location_code": "tuxtla_gutierrez", 
    "specialty": "Medicina General",
    "specialty_code": "general_medicine",
    "is_ai_search": false,
    "has_filters": true
  }
  ```

## 🔧 **Configuración Requerida**

### **1. Dependencias (ya incluidas):**
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_bloc: ^8.1.3
```

### **2. Variables de Usuario:**
La implementación obtiene automáticamente el `user_id` de:
```dart
SharedPreferencesHelper.getUserId()
```

### **3. URL del Gateway:**
Configurada desde:
```dart
ApiEndpoints.gatewayBaseUrl
// "https://k2ob2307th.execute-api.us-east-2.amazonaws.com/dev"
```

## 📊 **Ejemplo de Uso en Otras Páginas**

Para implementar analytics en otras páginas:

```dart
class MiPageState extends State<MiPage> 
    with WidgetsBindingObserver, AnalyticsAppLifecycleMixin {
  
  String? _currentUserId;
  
  @override
  String? get userId => _currentUserId;
  
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }
  
  Future<void> _loadUserId() async {
    final userId = await SharedPreferencesHelper.getUserId();
    setState(() {
      _currentUserId = userId;
    });
  }
  
  // El tracking de sesiones se maneja automáticamente
  // Solo necesitas trackear búsquedas específicas:
  void _trackMySearch(String query) {
    AnalyticsService.trackSearch(
      searchQuery: query,
      searchType: 'appointment', // o el tipo que corresponda
      resultsCount: 10,
    );
  }
}
```

## 🐛 **Debugging**

Los logs de debug aparecerán en la consola:
```
✅ Sesión iniciada: abc-123-def-456
📊 Resultados de búsqueda: 15
✅ Búsqueda trackeada: veterinario cerca de mi
✅ Sesión finalizada: abc-123-def-456
```

En caso de errores:
```
❌ Error al iniciar sesión: 500
❌ Exception al trackear búsqueda: NetworkException
```

## 🎉 **Estado Final**

La implementación está **100% completa y funcional**:

- ✅ **Sesiones automáticas** al abrir/cerrar app
- ✅ **Tracking de búsquedas** en página de veterinarios  
- ✅ **Integración con backend** analytic-ms
- ✅ **Captura de filtros** y resultados
- ✅ **Manejo de errores** robusto
- ✅ **UserId real** del usuario logueado
- ✅ **Logs de debug** para monitoring

¡Todo listo para recopilar datos de uso y generar insights! 📈
