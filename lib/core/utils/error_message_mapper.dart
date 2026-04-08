import 'dart:async' as dart_async;
import 'package:wolfchat/core/exceptions/app_exceptions.dart';

/// Maps any caught exception/error to a user-friendly Portuguese message.
///
/// Usage:
/// ```dart
/// catch (e) {
///   _errorMessage = ErrorMessageMapper.from(e);
/// }
/// ```
abstract class ErrorMessageMapper {
  /// Converts any exception to a friendly message.
  ///
  /// Handles:
  /// - [AppException] subclasses → their built-in message
  /// - [dart_async.TimeoutException] → timeout message
  /// - Generic [Exception] / [Object] → fallback message
  static String from(Object error) {
    switch (error) {
      case AuthException():
        return error.message;
      case RateLimitException():
        return error.message;
      case NetworkException():
        return error.message;
      case TimeoutException():
        return error.message;
      case ModelException():
        return error.message;
      case PersistenceException():
        return error.message;
      case ServerException():
        return error.message;
      case dart_async.TimeoutException():
        return 'A conexão demorou muito. '
            'Verifique sua internet e tente novamente.';
      case FormatException():
        return 'Ocorreu um erro inesperado. Tente novamente.';
      default:
        final raw = error.toString().toLowerCase();

        // Try to detect common patterns in raw error strings
        if (raw.contains('socket') ||
            raw.contains('connection') ||
            raw.contains('network') ||
            raw.contains('oserror')) {
          return 'Não foi possível conectar ao servidor. '
              'Verifique sua conexão com a internet.';
        }

        if (raw.contains('timeout')) {
          return 'A conexão demorou muito. '
              'Verifique sua internet e tente novamente.';
        }

        return 'Ocorreu um erro inesperado. Tente novamente em instantes.';
    }
  }

  /// Returns a short title for the error (for use in dialogs/banners).
  static String title(Object error) {
    switch (error) {
      case AuthException():
        return 'Autenticação';
      case RateLimitException():
        return 'Limite excedido';
      case NetworkException():
        return 'Conexão';
      case TimeoutException():
        return 'Timeout';
      case ModelException():
        return 'Modelo';
      case PersistenceException():
        return 'Dados';
      case ServerException():
        return 'Servidor';
      default:
        return 'Erro';
    }
  }
}

// Pseudo-update for commit 27 at 2026-04-08 05:35:49
