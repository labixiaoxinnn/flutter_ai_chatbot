import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response_body.freezed.dart';
part 'error_response_body.g.dart';

@freezed
class ErrorResponseBody with _$ErrorResponseBody {
  const factory ErrorResponseBody({
    ErrorData? error,
  }) = _ErrorResponseBody;

  factory ErrorResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseBodyFromJson(json);
}

@freezed
class ErrorData with _$ErrorData {
  const factory ErrorData({
    String? code,
    String? message,
  }) = _ErrorData;

  factory ErrorData.fromJson(Map<String, dynamic> json) =>
      _$ErrorDataFromJson(json);
}
