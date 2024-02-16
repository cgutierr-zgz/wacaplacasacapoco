import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';
import 'package:wacaplacasacapoco/util/extensions.dart';

class FilePickerButton extends StatelessWidget {
  const FilePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DownloaderCubit>();

    return TextButton(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        if (result == null) return;
        for (final file in result.files) {
          if (file.bytes == null) continue;
          final added = cubit.addFile(
            fileName: file.name.split('.').first,
            fileContent: file.bytes!,
          );
          if (!added && context.mounted) {
            context.showSnackBar(
              'File with name "${file.name}" already exists',
              type: SnackbarType.error,
            );
          }
        }
      },
      child: const Text(
        'or click here to pick files',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
