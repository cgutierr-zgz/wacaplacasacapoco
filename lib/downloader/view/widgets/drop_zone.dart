import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';
import 'package:wacaplacasacapoco/util/extensions.dart';

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
                final name = filename.split('.').first;
                final data = await controller.getFileData(ev);
                setState(() => onHover = false);
                final added = cubit.addFile(
                  fileName: name,
                  fileContent: data,
                );
                if (!added && context.mounted) {
                  context.showSnackBar(
                    'File with name "$name" already exists',
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
