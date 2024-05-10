import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/data/auth_repository.dart';
import '../../common/data/api_repository.dart';
import '../../logging/domain/request_error.dart';
import 'upload_repository_fake.dart';

part 'upload_repository.g.dart';

@riverpod
UploadRepository uploadRepository(UploadRepositoryRef ref) {
  // Replace with actual implementation once API is available
  return UploadRepositoryFake(ref.watch(getAuthRepositoryProvider), Dio());
}


abstract class UploadRepository extends ApiRepository {
  UploadRepository(super.authRepository, super.dio);

  TaskEither<RequestError, Unit> uploadFile(String filePath);
}
