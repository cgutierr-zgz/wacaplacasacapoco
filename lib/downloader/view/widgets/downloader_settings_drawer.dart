import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart';
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
              SwitchListTile(
                value: state.downloadOriginalImage,
                title: const Text('Download Original Image'),
                onChanged: (_) => cubit.toggleDownloadOGImage(),
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
              SwitchListTile(
                value: state.maintainAspectRatio,
                title: const Text('Maintain Aspect Ratio'),
                onChanged: (_) => cubit.toggleMaintainAspectRatio(),
              ),
              const Text('Interpolation Mode'),
              DropdownButton<Interpolation>(
                value: state.interpolationMode,
                items: List.generate(
                  Interpolation.values.length,
                  (index) {
                    final item = Interpolation.values[index];
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                      onTap: () => cubit.changeInterpolation(item),
                    );
                  },
                ),
                onChanged: (value) {},
              ),
            ],
          ),
        );
      },
    );
  }
}
