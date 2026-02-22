import 'package:dio/dio.dart';

import '../../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = const NetworkException(
          'Connection timed out. Please check your internet connection and try again.',
        );
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final errorMessage =
            err.response?.data['message'] ??
            'An error occurred with the server.';

        if (statusCode == 401 || statusCode == 403) {
          appException = AuthException(
            errorMessage,
            code: statusCode?.toString(),
          );
        } else if (statusCode != null && statusCode >= 500) {
          appException = ServerException(
            errorMessage,
            code: statusCode.toString(),
          );
        } else {
          appException = ServerException(
            errorMessage,
            code: statusCode?.toString(),
          );
        }
        break;
      case DioExceptionType.cancel:
        appException = const ServerException(
          'Request to the server was cancelled.',
        );
        break;
      case DioExceptionType.connectionError:
        appException = const NetworkException('No internet connection.');
        break;
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        // Default case for unexpected errors
        // No need for default case as we've already handled all other cases
        appException = ServerException(
          'An unexpected error occurred: ${err.message}',
        );
        break;
    }
    handler.next(err.copyWith(error: appException));
  }
}
