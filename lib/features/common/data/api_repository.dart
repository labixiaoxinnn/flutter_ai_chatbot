import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../authentication/data/auth_repository.dart';
import '../../logging/domain/app_error_code.dart';
import '../../logging/domain/request_error.dart';
import '../../logging/presentation/controllers/logging_controller.dart';
import '../domain/error_response_body.dart';

abstract class ApiRepository {
  final AuthRepository authRepository;
  final Dio dio;

  ApiRepository(this.authRepository, this.dio);

  //! This method must be called before any API request is made.
  //! This is required to ensure that the Authorization header is set with the latest JWT token.
  //! It takes care of refreshing the token if it has expired.
  Future<void> setAuthorizationHeader() async {
    (await authRepository.fetchIdToken().run()).match((l) {
      return null;
    }, (r) {
      dio.options.headers['Authorization'] = 'Bearer $r';
    });
  }

  Future<void> setAccessTokenHeader() async {
    (await authRepository.fetchAccessToken().run()).match((l) {
      return null;
    }, (r) {
      dio.options.headers['x-access-token'] = r;
    });
  }

  TaskEither<RequestError, T> httpCall<T>(
    Future<T> Function() apiCall, {
    LogLevel logLevel = LogLevel.severe,
    String message = '',
    String error = '',
    StackTrace? stackTrace,
  }) {
    return TaskEither<RequestError, T>(() async {
      try {
        //await setAuthorizationHeader();
        return right(await _measureDuration(() => apiCall()));
      } on DioException catch (e) {
        if (e.response == null) {
          return left(
            RequestError(
              logLevel: logLevel,
              message: e.message ?? "Unknown error",
              error: e.error ?? "Unknown error",
              appErrorCode: AppErrorCode.unKnownError,
              stackTrace: stackTrace,
            ),
          );
        }
        try {
          ErrorResponseBody errorResponseBody =
              ErrorResponseBody.fromJson(e.response?.data);
          AppErrorCode appErrorCode = AppErrorCode.unauthorizedError;

          if (e.response?.statusCode == HttpStatus.notFound) {
            appErrorCode = AppErrorCode.objectNotFoundError;
          } else if (e.response?.statusCode == HttpStatus.unprocessableEntity) {
            appErrorCode = AppErrorCode.unprocessableEntity;
          } else if (e.response?.statusCode == HttpStatus.requestTimeout) {
            appErrorCode = AppErrorCode.requestTimeoutError;
            errorResponseBody = const ErrorResponseBody(
              error: ErrorData(
                code: 'requestTimeoutError',
                message:
                    'Request timed out. Transaction might have been successful.'
                    'Please check your transaction history.',
              ),
            );
          } else if (e.response?.statusCode == HttpStatus.badGateway) {
            appErrorCode = AppErrorCode.unKnownError;
            errorResponseBody = const ErrorResponseBody(
              error: ErrorData(
                code: 'BAD_GATEWAY',
                message: 'Unable to connect to server. Please try again later.',
              ),
            );
          }
          return left(
            RequestError(
              logLevel: LogLevel.severe,
              message: errorResponseBody.error?.message ?? message,
              error: errorResponseBody.error?.code ?? error,
              appErrorCode: appErrorCode,
              stackTrace: StackTrace.current,
            ),
          );
        } catch (e) {
          return left(
            RequestError(
              logLevel: logLevel,
              message: e.toString(),
              error: e.toString(),
              appErrorCode: AppErrorCode.unKnownError,
              stackTrace: StackTrace.current,
            ),
          );
        }
      } catch (error, stackTrace) {
        return left(
          RequestError(
            logLevel: logLevel,
            message: message,
            error: error,
            appErrorCode: AppErrorCode.unKnownError,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  Future<T> _measureDuration<T>(Future<T> Function() apiCall) async {
    final stopwatch = Stopwatch()..start();
    final result = await apiCall();
    stopwatch.stop();

    //print('The operation took ${stopwatch.elapsed}');

    return result;
  }
}
