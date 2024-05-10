import 'package:file_selector/file_selector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_picker_controller.g.dart';

enum FilePickerState {
  initialized,
  success,
  failure,
  duplicate,
}

final platformFilesProvider =
    StateProvider.autoDispose<List<XFile>>((ref) => []);

@riverpod
class FilePickerController extends _$FilePickerController {
  @override
  FilePickerState build() {
    ref.read(platformFilesProvider); // just to initialize the provider
    return FilePickerState.initialized;
  }

  void addFiles(List<XFile> files) {
    final platformFilesController = ref.read(platformFilesProvider.notifier);

    if (files.any((input) => platformFilesController.state.any((existing) =>
        input.name == existing.name && input.length == existing.length))) {
      state = FilePickerState.duplicate;
      return;
    }
    platformFilesController.state = [
      ...platformFilesController.state,
      ...files
    ];
    state = FilePickerState.success;
  }

  void removeFile(XFile file) {
    final platformFilesController = ref.read(platformFilesProvider.notifier);
    platformFilesController.state = platformFilesController.state
        .where((element) =>
            element.name != file.name && element.length != file.length)
        .toList();
    state = FilePickerState.success;
  }
}
