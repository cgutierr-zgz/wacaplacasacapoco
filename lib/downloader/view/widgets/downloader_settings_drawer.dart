import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';

class DownloaderSettingsDrawer extends StatelessWidget {
  const DownloaderSettingsDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DownloaderCubit>();

    return BlocBuilder<DownloaderCubit, DownloaderState>(
      builder: (context, state) {
        return Drawer(
          child: Column(
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Text('BlurHash'),
              const BlurhashInput(),
              SwitchListTile(
                value: state.downloadBlurHashImages,
                title: const Text('Download BlurHash Images'),
                onChanged: (_) => cubit.toggleDownloadBlurHashImages(),
              ),
              const Divider(),
              const Text('Download sizes'),
              Text(DownloadSizes.values.toString()),
            ],
          ),
        );
      },
    );
  }
}
