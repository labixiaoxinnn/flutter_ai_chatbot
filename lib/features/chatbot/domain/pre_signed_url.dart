import 'package:freezed_annotation/freezed_annotation.dart';

part 'pre_signed_url.freezed.dart';
part 'pre_signed_url.g.dart';

enum MethodName {
  putObject("putObject"),
  getObject("getObject");

  final String value;
  const MethodName(this.value);
}


@freezed
abstract class PreSignedUrlParams with _$PreSignedUrlParams {
  const factory PreSignedUrlParams({
    required String fileName,
    required MethodName methodName,
  }) = _PreSignedUrlParams;

  factory PreSignedUrlParams.fromJson(Map<String, dynamic> json) =>
      _$PreSignedUrlParamsFromJson(json);
}
