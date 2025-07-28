import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

mixin AnalyticsAppLifecycleMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  String? get userId; // Debe ser implementado por la clase que use este mixin
  
  @override
  void initState() {
    super.initState();
    print('🔄 [LIFECYCLE] Inicializando mixin de analytics');
    WidgetsBinding.instance.addObserver(this);
    _initializeAnalytics();
  }
  
  @override
  void dispose() {
    print('🔄 [LIFECYCLE] Disposing mixin de analytics');
    WidgetsBinding.instance.removeObserver(this);
    _endAnalyticsSession();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final currentUserId = userId;
    print('📱 [LIFECYCLE] Cambio de estado: $state');
    print('📱 [LIFECYCLE] User ID: $currentUserId');
    
    if (currentUserId == null) {
      print('📱 [LIFECYCLE] No hay userId - saltando manejo de estado');
      return;
    }
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 [LIFECYCLE] App resumed - verificando sesión');
        print('📱 [LIFECYCLE] Asegurando sesión activa...');
        AnalyticsService.ensureSessionActive(currentUserId).then((result) {
          print('📱 [LIFECYCLE] Resultado de verificación de sesión: $result');
        });
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        print('📱 [LIFECYCLE] App paused/detached - finalizando sesión');
        _endAnalyticsSession();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        print('📱 [LIFECYCLE] App inactive/hidden - no hacer nada');
        // No hacer nada en inactive o hidden
        break;
    }
  }
  
  Future<void> _initializeAnalytics() async {
    final currentUserId = userId;
    print('🚀 [ANALYTICS-MIXIN] Verificando analytics...');
    print('🚀 [ANALYTICS-MIXIN] User ID: $currentUserId');
    print('🚀 [ANALYTICS-MIXIN] Sesión activa: ${AnalyticsService.hasActiveSession}');
    
    // ✅ NO iniciamos sesión aquí automáticamente
    // La sesión debe iniciarse desde donde ya tenemos el userId cargado
    if (currentUserId != null && !AnalyticsService.hasActiveSession) {
      print('🚀 [ANALYTICS-MIXIN] ⚠️ Usuario disponible pero sin sesión - esto debería iniciarse desde _loadUserId()');
    } else if (currentUserId == null) {
      print('🚀 [ANALYTICS-MIXIN] ⚠️ No hay userId disponible - esperando carga');
    } else {
      print('🚀 [ANALYTICS-MIXIN] ✅ Sesión ya activa');
    }
  }
  
  Future<void> _endAnalyticsSession() async {
    print('🛑 [ANALYTICS-MIXIN] Finalizando sesión de analytics...');
    print('🛑 [ANALYTICS-MIXIN] Sesión activa: ${AnalyticsService.hasActiveSession}');
    
    if (AnalyticsService.hasActiveSession) {
      print('🛑 [ANALYTICS-MIXIN] Cerrando sesión existente');
      final result = await AnalyticsService.endSession();
      print('🛑 [ANALYTICS-MIXIN] Resultado: $result');
    } else {
      print('🛑 [ANALYTICS-MIXIN] No hay sesión activa para cerrar');
    }
  }
}
