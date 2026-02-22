abstract class Failure {
  const Failure(this.message, {this.code});

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

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class GeneralFailure extends Failure {
  const GeneralFailure(super.message, {super.code});
}
