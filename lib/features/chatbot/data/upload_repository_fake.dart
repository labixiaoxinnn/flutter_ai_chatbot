import 'package:fpdart/fpdart.dart';

import '../../logging/domain/request_error.dart';
import 'upload_repository.dart';

class UploadRepositoryFake extends UploadRepository {
  UploadRepositoryFake(super.authRepository, super.dio);

  @override
  TaskEither<RequestError, Unit> uploadFile(String filePath) {
    return TaskEither.right(unit);
  }
}
