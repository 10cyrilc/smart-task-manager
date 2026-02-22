abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType[$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}
