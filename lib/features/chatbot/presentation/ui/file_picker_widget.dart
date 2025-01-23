import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/file_picker_controller.dart';
import 'common.dart';

enum FilePickerType { photo, file }

const XTypeGroup docTypeGroup = XTypeGroup(
  label: 'Docs',
  extensions: supportedDocFormats,
);

class FilePickerWidget extends ConsumerWidget {
  final IconData icon;
  final FilePickerType filePickerType;

  const FilePickerWidget({
    super.key,
    required this.filePickerType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(chatResponseControllerProvider);
    ref.listen(filePickerControllerProvider, (previous, current) {
      if (current == FilePickerState.duplicate) {
        const snackBar = SnackBar(
          content: Text(
            "One or more files are already present",
            textAlign: TextAlign.center,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    return responseAsync.maybeWhen(
      data: (_) {
        return InkWell(
          onTap: () async {
            if (filePickerType == FilePickerType.photo) {
              _getPhoto(ref);
            } else {
              _getFiles(ref);
            }
          },
          child: Icon(
            icon,
            size: 30,
          ),
        );
      },
      orElse: () {
        return Icon(
          icon,
          size: 30,
          color: Theme.of(context).disabledColor,
        );
      },
    );
  }

  Future<Unit> _getPhoto(
    WidgetRef ref,
  ) async {
    final pickedFileOpt = Option.fromNullable(
        await ImagePicker().pickImage(source: ImageSource.camera));

    return await pickedFileOpt.fold(
      () => Future.value(unit),
      (pickedFile) async {
        ref.read(filePickerControllerProvider.notifier).addFiles([
          XFile(
            pickedFile.path,
            name: pickedFile.name,
            length: await pickedFile.length(),
            bytes: await pickedFile.readAsBytes(),
          ),
        ]);
        return unit;
      },
    );
  }

  Future<Unit> _getFiles(
    WidgetRef ref,
  ) async {
    return Option.fromNullable(
      await openFiles(
        acceptedTypeGroups: [
          docTypeGroup,
        ],
      ),
    ).fold(
      () => unit,
      (result) {
        ref.read(filePickerControllerProvider.notifier).addFiles(result);
        return unit;
      },
    );
  }
}
