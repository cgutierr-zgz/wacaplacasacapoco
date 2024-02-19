import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';
import 'package:wacaplacasacapoco/util/extensions.dart';
import 'package:path/path.dart' as p;

class DropZone extends StatefulWidget {
  const DropZone({super.key});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  late final DownloaderCubit cubit = context.read<DownloaderCubit>();
  late final DropzoneViewController controller;
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _DropZoneDecoration(
        onHover: onHover,
        child: Stack(
          children: [
            DropzoneView(
              onCreated: (ctrl) => controller = ctrl,
              cursor: onHover ? CursorType.copy : null,
              operation: DragOperation.copy,
              onHover: () => setState(() => onHover = true),
              onDrop: (ev) async {
                final filename = await controller.getFilename(ev);
                // final fileMIME = await controller.getFileMIME(ev);

                final data = await controller.getFileData(ev);

                final ext = p.extension(filename).toLowerCase();

                if (ext case '.png' || '.jpeg' || '.jpg') {
                  setState(() => onHover = false);
                  final added = cubit.addFile(
                    fileName: filename,
                    fileContent: data,
                  );
                  if (!added && mounted) {
                    context.showSnackBar(
                      'File with name "$filename" already exists',
                      type: SnackbarType.error,
                    );
                  }
                } else {
                  if (!mounted) return;
                  context.showSnackBar(
                    'only .png, .jpeg and .jpg files plis <3',
                    type: SnackbarType.error,
                  );
                }
              },
              onLeave: () => setState(() => onHover = false),
            ),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Drop your Images here'),
                  FilePickerButton(),
                ],
              ),
            ),
          ],
        ), //.constrain(),
      ),
    );
  }
}

class _DropZoneDecoration extends StatelessWidget {
  const _DropZoneDecoration({
    required this.child,
    required this.onHover,
  });

  final Widget child;
  final bool onHover;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 300,
      margin: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: onHover ? Colors.blue.shade100 : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(20),
        dashPattern: const [10, 10],
        color: onHover ? Colors.blue : Colors.grey,
        strokeWidth: 2,
        child: child,
      ),
    );
  }
}
