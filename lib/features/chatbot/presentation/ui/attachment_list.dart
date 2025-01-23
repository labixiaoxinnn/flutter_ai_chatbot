import 'package:file_selector/file_selector.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../gen/assets.gen.dart';
import '../../../ui_theme/spacing.dart';
import '../../../ui_theme/ui_theme.dart';
import '../controller/file_picker_controller.dart';

const supportedImageFormats = ['jpg', 'png'];
const cPdf = 'pdf';
const supportedDocFormats = [cPdf, 'doc', 'docx'];

class AttachmentList extends ConsumerWidget {
  const AttachmentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformFiles = ref.watch(platformFilesProvider);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 12,
      mainAxisSpacing: kSingleSpacing,
      crossAxisSpacing: kSingleSpacing,
      children: <Widget>[
        ...platformFiles.map(
          (XFile platformFile) {
            final String fileExtension =
                getFileExtension(platformFile.name).toLowerCase();
            final bool isPDF = fileExtension == cPdf;
            return GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("File Details"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              Text(
                                'File Name: ${platformFile.name}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'File Size: ${filesize(platformFile.length())}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("OK"))
                        ],
                      );
                    });
              },
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: kSingleSpacing,
                      right: kSingleSpacing,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(borderRadius),
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      child: supportedImageFormats.contains(
                        fileExtension,
                      )
                          ? FutureBuilder(
                              future: platformFile.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text('Error loading image'),
                                  );
                                }

                                return Image.memory(
                                  snapshot.data as Uint8List,
                                  fit: BoxFit.cover,
                                );
                              })
                          : Stack(
                              children: [
                                SvgPicture.asset(
                                  isPDF ? Assets.svg.pdf : Assets.svg.word,
                                  fit: BoxFit.cover,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    platformFile.name,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        shape: BoxShape.circle,
                      ),
                      child: InkResponse(
                        onTap: () {
                          ref
                              .read(filePickerControllerProvider.notifier)
                              .removeFile(platformFile);
                        },
                        child: const Icon(
                          Icons.cancel,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

String getFileExtension(String fileName) {
  String ext = '';

  final int lastIndex = fileName.lastIndexOf('.');
  if (lastIndex >= 0) {
    ext = fileName.substring(lastIndex + 1);
  }
  return ext;
}
