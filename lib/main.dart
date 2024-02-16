import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:wacaplacasacapoco/downloader_cubit.dart';
import 'package:wacaplacasacapoco/drop_zone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorage.webStorageDirectory);

  runApp(
    BlocProvider(
      create: (_) => DownloaderCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: ImageResizer(),
        debugShowCheckedModeBanner: false,
      );
}

class ImageResizer extends StatefulWidget {
  const ImageResizer({super.key});

  @override
  State<ImageResizer> createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  final blurHashController = TextEditingController();
  late final DownloaderCubit cubit;
  final FocusNode bhFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    cubit = context.read<DownloaderCubit>();
    blurHashController.text =
        "${cubit.state.blurHashMode.$1},${cubit.state.blurHashMode.$2}";
  }

  @override
  void dispose() {
    blurHashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloaderCubit, SapatitoState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Image Resizer'),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                );
              }),
            ],
          ),
          endDrawer: Drawer(
            child: Column(
              children: [
                const Text("Settings"),
                const Text("BlurHash"),
                TextField(
                  focusNode: bhFocusNode,
                  controller: blurHashController,
                  onSubmitted: (value) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    try {
                      final split = value.split(",");
                      final vector2 =
                          (int.parse(split.first), int.parse(split.last));
                      cubit.updateBlurHash(vector2);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green),
                              Text(
                                "Actualizado a $vector2",
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              Text(
                                "El valor debe ser tal que: \"2,3\" o \"5,5\"",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    bhFocusNode.requestFocus();
                  },
                ),
                const Text(
                  "Esto es para que probando diferentes settings veas cual te mola mas",
                ),
                SwitchListTile(
                  value: state.downloadBlurHashImages,
                  title: const Text("Download BlurHash Images"),
                  onChanged: (_) => cubit.toggleDownloadBlurHashImages(),
                ),
                const Text("Download sizes"),
                Text(state.downloadSizes.toString()),
                const Text(
                  "Si necesitas editar esto pide a carlos que te actualize esto y asi lo puedes cambiar tu y añadir los sizes que necesites, ahora me da pereza ;)",
                ),
              ],
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.images.isEmpty) const DropZone(),
                  if (state.images.isNotEmpty) ...[
                    ElevatedButton(
                      child: const Text("Clear"),
                      onPressed: () => cubit.deleteAllFiles(),
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
                      child: const Text("Export"),
                      onPressed: () => cubit.downloadAllImages(),
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
