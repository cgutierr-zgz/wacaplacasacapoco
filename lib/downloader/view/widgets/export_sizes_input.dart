import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';

class ExportSizesInput extends StatefulWidget {
  const ExportSizesInput({super.key});

  @override
  State<ExportSizesInput> createState() => _ExportSizesInputState();
}

class _ExportSizesInputState extends State<ExportSizesInput> {
  late final cubit = context.read<DownloaderCubit>();
  final List<SizeInput> _sizeInputs = [];

  @override
  void initState() {
    super.initState();
    final sizes = cubit.state.downloadSizes.map((e) => e.toString()).toList();
    final sizeInputs = <SizeInput>[];

    for (var i = 0; i < sizes.length; i++) {
      sizeInputs.add(
        SizeInput(
          initialX: cubit.state.downloadSizes[i].$1,
          initialY: cubit.state.downloadSizes[i].$2,
          onDelete: () => _removeSizeInput(i),
          onSubmitted: (x, y) => cubit.addDownloadSize(x: x, y: y),
        ),
      );
    }

    _sizeInputs.addAll(sizeInputs);
  }

  void _addSizeInput() {
    setState(() {
      final rand = math.Random();
      final x = rand.nextInt(1200);
      final y = rand.nextInt(1200);
      final newSize = '$x$y';

      if (cubit.state.downloadSizes.contains((x, y))) {
        log('Error: Size $newSize already exists');

        return;
      }

      _sizeInputs.add(
        SizeInput(
          initialX: x,
          initialY: y,
          onDelete: () => _removeSizeInput(_sizeInputs.length - 1),
          onSubmitted: (x, y) => cubit.addDownloadSize(x: x, y: y),
        ),
      );
    });
  }

  void _removeSizeInput(int index) {
    setState(() {
      _sizeInputs.removeAt(index);
      cubit.removeDownloadSize(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._sizeInputs,
        ElevatedButton(
          onPressed: _addSizeInput,
          child: const Text('Add Size'),
        ),
      ],
    );
  }
}

class SizeInput extends StatelessWidget {
  SizeInput({
    required int initialX,
    required int initialY,
    required this.onSubmitted,
    required this.onDelete,
    super.key,
  })  : xController = TextEditingController(text: initialX.toString()),
        yController = TextEditingController(text: initialY.toString());

  final TextEditingController xController;
  final TextEditingController yController;
  final void Function(int, int) onSubmitted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            controller: xController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'X',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: yController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Y',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
