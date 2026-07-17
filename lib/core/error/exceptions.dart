class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  const NetworkException();
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class NotFoundException implements Exception {
  const NotFoundException();
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;
  ValidationException(this.errors);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
