import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wacaplacasacapoco/downloader/downloader.dart';
import 'package:wacaplacasacapoco/downloader/view/widgets/downloader_settings_drawer.dart';

class DownloaderPage extends StatelessWidget {
  const DownloaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DownloaderCubit>();

    return BlocBuilder<DownloaderCubit, DownloaderState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Image Resizer'),
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  );
                },
              ),
            ],
          ),
          endDrawer: const DownloaderSettingsDrawer(),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.images.isEmpty) const DropZone(),
                  if (state.images.isNotEmpty) ...[
                    ElevatedButton(
                      onPressed: cubit.deleteAllFiles,
                      child: const Text('Clear'),
                    ),
                    const SizedBox(height: 50),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: state.images.entries.map(
                        (e) {
                          return Stack(
                            children: [
                              Container(
                                clipBehavior: Clip.hardEdge,
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.memory(e.value, fit: BoxFit.cover),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () => cubit.deleteFile(
                                  fileName: e.key,
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: cubit.downloadAllImages,
                      child: const Text('Export'),
                    ),
                  ],
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
