import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required Dio dio}) : _dio = dio;

  Dio get dio => _dio;

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(url, data: data, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(url, data: data, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(url, data: data, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(url, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Tiempo de conexión agotado');
        case DioExceptionType.badResponse:
          return Exception('Error del servidor: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return Exception('Solicitud cancelada');
        case DioExceptionType.unknown:
          return Exception('Error de conexión');
        default:
          return Exception('Error desconocido');
      }
    }
    return Exception('Error inesperado: $error');
  }
}