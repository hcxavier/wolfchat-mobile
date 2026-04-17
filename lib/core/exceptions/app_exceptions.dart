abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class ModelException extends AppException {
  const ModelException(super.message);
}

class PersistenceException extends AppException {
  const PersistenceException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}
