import 'package:freezed_annotation/freezed_annotation.dart';

import '../presentation/controllers/logging_controller.dart';
import 'app_error_code.dart';

part 'request_error.freezed.dart';

@freezed
class RequestError with _$RequestError {
  const factory RequestError({
    required LogLevel logLevel,
    required Object message,
    AppErrorCode? appErrorCode,
    Object? error,
    StackTrace? stackTrace,
  }) = _RequestError;
}
