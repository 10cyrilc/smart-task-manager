// ignore_for_file: avoid_classes_with_only_static_members

import 'app_exception.dart';
import 'failures.dart';

class ErrorMapper {
  static Failure mapExceptionToFailure(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, code: exception.code);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message, code: exception.code);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, code: exception.code);
    } else if (exception is AppException) {
      return GeneralFailure(exception.message, code: exception.code);
    } else {
      return GeneralFailure('An unexpected error occurred: ${exception.toString()}');
    }
  }
}
