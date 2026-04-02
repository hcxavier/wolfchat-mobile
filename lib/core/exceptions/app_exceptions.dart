/// Base exception for all Wolfchat application errors.
///
/// All custom exceptions extend [AppException] so they can be
/// caught uniformly and mapped to user-friendly messages.
abstract class AppException implements Exception {
  const AppException(this.message);

  /// Technical error message (for logging/debugging).
  final String message;

  @override
  String toString() => message;
}

/// Authentication / API key errors.
///
/// Thrown when the API key is missing, invalid, or expired.
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Rate limiting errors (HTTP 429).
///
/// Thrown when the user has exceeded the API provider's request quota.
class RateLimitException extends AppException {
  const RateLimitException(super.message);
}

/// Network / connectivity errors.
///
/// Thrown on connection failures, DNS errors, etc.
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Timeout errors.
///
/// Thrown when a request exceeds its allowed duration.
class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

/// Model-related errors.
///
/// Thrown when no model is selected, no models are available,
/// or the model ID is invalid.
class ModelException extends AppException {
  const ModelException(super.message);
}

/// Persistence / database errors.
///
/// Thrown when reading or writing local data fails.
class PersistenceException extends AppException {
  const PersistenceException(super.message);
}

/// Generic server errors (HTTP 5xx and other uncategorized codes).
class ServerException extends AppException {
  const ServerException(super.message);
}
