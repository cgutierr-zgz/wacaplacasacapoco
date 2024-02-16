import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';
import 'package:wacaplacasacapoco/util/extensions.dart';

class BlurhashInput extends StatefulWidget {
  const BlurhashInput({super.key});

  @override
  State<BlurhashInput> createState() => _BlurhashInputState();
}

class _BlurhashInputState extends State<BlurhashInput> {
  final TextEditingController firstNumberController = TextEditingController();
  final TextEditingController secondNumberController = TextEditingController();
  late final DownloaderCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<DownloaderCubit>();
    firstNumberController.text = '${cubit.state.blurHashMode.$1}';
    secondNumberController.text = '${cubit.state.blurHashMode.$2}';
  }

  @override
  void dispose() {
    firstNumberController.dispose();
    secondNumberController.dispose();
    super.dispose();
  }

  void _showError() => context.showSnackBar(
        'BlurHash components must be between 1 and 9',
        type: SnackbarType.error,
      );

  void _onSubmitted({String? x, String? y}) {
    try {
      final valueX = x == null ? null : int.parse(x);
      final valueY = y == null ? null : int.parse(y);
      if (valueX == null && valueY == null) {
        throw Exception('Nothing was parsed ');
      }

      if (valueX != null && (valueX < 1 || valueX > 9)) {
        throw Exception('Invalid value');
      }

      if (valueY != null && (valueY < 1 || valueY > 9)) {
        throw Exception('Invalid value');
      }

      cubit.updateBlurHash(x: valueX, y: valueY);
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (_) {
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        _InputBox(
          label: 'x',
          controller: firstNumberController,
          onSubmitted: (value) => _onSubmitted(x: value),
        ),
        const SizedBox(width: 5),
        _InputBox(
          label: 'y',
          controller: secondNumberController,
          onSubmitted: (value) => _onSubmitted(y: value),
        ),
        const Spacer(),
      ],
    );
  }
}

class _InputBox extends StatefulWidget {
  const _InputBox({
    required this.label,
    required this.controller,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final void Function(String)? onSubmitted;

  @override
  State<_InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<_InputBox> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (value) => widget.onSubmitted?.call(value),
        onChanged: (value) => widget.onSubmitted?.call(value),
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
