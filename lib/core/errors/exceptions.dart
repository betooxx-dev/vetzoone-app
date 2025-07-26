abstract class AppException implements Exception {
  final String message;
  const AppException({required this.message});
}

class ServerException extends AppException {
  const ServerException({required super.message});
}

class NetworkException extends AppException {
  const NetworkException({required super.message});
}

class CacheException extends AppException {
  const CacheException({required super.message});
}

class BadRequestException extends AppException {
  const BadRequestException({required super.message});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({required super.message});
}

class ForbiddenException extends AppException {
  const ForbiddenException({required super.message});
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message});
}

class ConflictException extends AppException {
  const ConflictException({required super.message});
}

class ValidationException extends AppException {
  const ValidationException({required super.message});
}