import 'dart:async' as async;
import 'dart:io';

/// Digital Kavach's typed exception hierarchy.
///
/// Every failure surfaced to UI MUST be a [KavachException] subtype.
/// Convert raw errors at the boundary using [runCatching].
///
/// Later phases (AI Router, Scanner, Firebase repos) MUST throw these,
/// never bare Exceptions.
sealed class KavachException implements Exception {
  const KavachException(this.code, [this.developerMessage]);

  /// Stable machine code (e.g. `network`, `ai.quota`).
  final String code;

  /// Optional developer-facing detail. NEVER shown to end users.
  final String? developerMessage;

  @override
  String toString() =>
      'KavachException($code)${developerMessage != null ? ": $developerMessage" : ""}';
}

class NetworkException extends KavachException {
  const NetworkException([String? msg]) : super('network', msg);
}

class KavachTimeoutException extends KavachException {
  const KavachTimeoutException([String? msg]) : super('timeout', msg);
}

class AiProviderException extends KavachException {
  const AiProviderException(this.providerName, [String? msg])
      : super('ai.provider', msg);
  final String providerName;
}

class QuotaExceededException extends KavachException {
  const QuotaExceededException([String? msg]) : super('ai.quota', msg);
}

class AiParseException extends KavachException {
  const AiParseException([String? msg]) : super('ai.parse', msg);
}

class NoProviderException extends KavachException {
  const NoProviderException([String? msg]) : super('ai.none', msg);
}

class PermissionException extends KavachException {
  const PermissionException(this.which, [String? msg])
      : super('permission', msg);
  final String which;
}

class AuthException extends KavachException {
  const AuthException([String? msg]) : super('auth', msg);
}

class StorageException extends KavachException {
  const StorageException([String? msg]) : super('storage', msg);
}

class ValidationException extends KavachException {
  const ValidationException([String? msg]) : super('validation', msg);
}

class UnknownException extends KavachException {
  const UnknownException([String? msg]) : super('unknown', msg);
}

/// Wraps any [Future] so that thrown errors are normalized into
/// [KavachException] subtypes. Use at every I/O / provider boundary.
Future<T> runCatching<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on KavachException {
    rethrow;
  } on SocketException catch (e) {
    throw NetworkException(e.message);
  } on HttpException catch (e) {
    throw NetworkException(e.message);
  } on async.TimeoutException catch (e) {
    throw KavachTimeoutException(e.message);
  } on FormatException catch (e) {
    throw AiParseException(e.message);
  } catch (e, _) {
    throw UnknownException(e.toString());
  }
}