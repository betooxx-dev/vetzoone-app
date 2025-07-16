import 'package:dio/dio.dart';
import '../storage/shared_preferences_helper.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('🔑 AUTH INTERCEPTOR - REQUEST:');
    print('URL: ${options.uri}');
    print('Method: ${options.method}');
    print('Headers antes: ${options.headers}');
    print('Data: ${options.data}');
    
    final token = await SharedPreferencesHelper.getToken();
    print('Token obtenido: ${token != null ? "SÍ (${token.length} chars)" : "NO"}');
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    print('Headers después: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🚨 AUTH INTERCEPTOR - ERROR:');
    print('Error type: ${err.type}');
    print('Status code: ${err.response?.statusCode}');
    print('Response data: ${err.response?.data}');
    print('Request URL: ${err.requestOptions.uri}');
    print('Request data: ${err.requestOptions.data}');
    print('Request headers: ${err.requestOptions.headers}');
    
    if (err.response?.statusCode == 401) {
      print('⚠️ Error 401 - Limpiando datos de login');
      SharedPreferencesHelper.clearLoginData();
    }
    handler.next(err);
  }
}
