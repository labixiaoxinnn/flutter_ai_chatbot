import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../logging/domain/app_error_code.dart';
import '../../logging/domain/request_error.dart';
import '../../logging/presentation/controllers/logging_controller.dart';
import '../domain/pre_signed_url.dart';
import 'upload_repository.dart';


class UploadRepositoryImpl extends UploadRepository {
  UploadRepositoryImpl(super.authRepository, super.dio);

  @override
  TaskEither<RequestError, Unit> uploadFile(String filePath) {
    return _getPresignedUrl(filePath).flatMap(
      (preSignedUrl) {
        return httpCall(() async {
          File file = File(filePath);

          FormData formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(filePath,
                filename: file.path.split('/').last),
          });
          Response response = await dio.put(
            preSignedUrl,
            data: formData,
          );

          if (response.statusCode != null &&
              response.statusCode! >= 200 &&
              response.statusCode! < 300) {
            return unit;
          }

          throw (
            RequestError(
              logLevel: LogLevel.severe,
              message: response.statusMessage ?? "Unknown error",
              error: response.statusMessage ?? "Unknown error",
              appErrorCode: AppErrorCode.unKnownError,
            ),
          );
        });
      },
    );
  }

  TaskEither<RequestError, String> _getPresignedUrl(String filePath) {
    return httpCall(() async {
      final file = await MultipartFile.fromFile(filePath);

      if (file.filename == null) {
        throw const RequestError(
          logLevel: LogLevel.severe,
          message: "File name is null",
          error: "File name is null",
          appErrorCode: AppErrorCode.invalidFileNameError,
        );
      }
      final response = await dio.get(
        "https://dev-api.example.com/v1/presigned-url",
        queryParameters: PreSignedUrlParams(
                fileName: file.filename!,
                methodName: MethodName.putObject,
        )
            .toJson(),
      );
      return response.data["data"]["url"];
    });
  }
}
