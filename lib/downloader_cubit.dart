import 'dart:developer';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image/image.dart' as img;

typedef Vector2 = (int x, int y);

class SapatitoState {
  const SapatitoState({
    required this.images,
    required this.downloadSizes,
    required this.blurHashMode,
    required this.downloadBlurHashImages,
  });

  final Map<String, Uint8List> images;
  final List<Vector2> downloadSizes;
  final Vector2 blurHashMode;
  final bool downloadBlurHashImages;

  SapatitoState copyWith({
    Map<String, Uint8List>? images,
    List<Vector2>? downloadSizes,
    Vector2? blurHashMode,
    bool? downloadBlurHashImages,
  }) {
    return SapatitoState(
      images: images ?? this.images,
      downloadSizes: downloadSizes ?? this.downloadSizes,
      blurHashMode: blurHashMode ?? this.blurHashMode,
      downloadBlurHashImages:
          downloadBlurHashImages ?? this.downloadBlurHashImages,
    );
  }
}

class DownloaderCubit extends HydratedCubit<SapatitoState> {
  DownloaderCubit()
      : super(
          const SapatitoState(
            images: {},
            downloadSizes: [
              (250, 250),
              (700, 700),
              (1200, 1200),
            ],
            blurHashMode: (3, 3),
            downloadBlurHashImages: false,
          ),
        );

  final images = Map<String, Uint8List>;

  void updateBlurHash((int x, int y) vector2) {
    final newState = state.copyWith(blurHashMode: vector2);
    emit(newState);
  }

  void toggleDownloadBlurHashImages() {
    final newState =
        state.copyWith(downloadBlurHashImages: !state.downloadBlurHashImages);
    emit(newState);
  }

  bool addFile({required String fileName, required Uint8List fileContent}) {
    if (!state.images.containsKey(fileName)) {
      final images = {...state.images, fileName: fileContent};
      final newState = state.copyWith(images: images);
      emit(newState);
      return true;
    }
    return false;
  }

  void deleteAllFiles() {
    for (final file in state.images.entries) {
      deleteFile(fileName: file.key);
    }
  }

  void deleteFile({required String fileName}) {
    if (state.images.containsKey(fileName)) {
      final images = {...state.images}..remove(fileName);
      final newState = state.copyWith(images: images);
      emit(newState);

      emit(newState);
    }
  }

  Future<void> downloadAllImages() async {
    for (final file in state.images.entries) {
      await _downloadImage(fileName: file.key, fileContent: file.value);
    }
  }

  Future<void> _downloadImage({
    required String fileName,
    required Uint8List fileContent,
  }) async {
    final blurHash = await BlurHash.encode(
      fileContent,
      state.blurHashMode.$1,
      state.blurHashMode.$2,
    );
    // ? download to a folder/zip ? idk :) :P :D ;)

    // MARK: Blurhash TXT
    final url = html.Url.createObjectUrlFromBlob(html.Blob([blurHash]));
    html.AnchorElement(href: url)
      ..setAttribute("download", "${fileName}_blurhash.txt")
      ..click();

    // MARK: Images
    for (final size in state.downloadSizes) {
      final name = "${size.$1}x${size.$2}_$fileName";

      try {
        if (state.downloadBlurHashImages) {
          final blurImage = await BlurHash.decode(blurHash, size.$1, size.$2);

          final blob = html.Blob([blurImage]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute("download", "image_$size.png")
            ..click();
        }

        img.Image image = img.decodeImage(fileContent)!;
        img.Image resized = img.copyResize(
          image,
          width: size.$1,
          height: size.$2,
        );

        final blob = html.Blob([img.encodePng(resized)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "image_$size.png")
          ..click();
      } catch (e) {
        log("Error downloading $name: $e");
      }
    }
  }

  @override
  SapatitoState? fromJson(Map<String, dynamic> json) {
    try {
      //final images = Map<String, Uint8List>.from(json['images']);
      final downloadSizes = (json['downloadSizes'] as List<dynamic>)
          .map((e) => (e[0], e[1]))
          .toList();
      final blurHashMode = (json['blurHashMode'][0], json['blurHashMode'][1]);
      final downloadBlurHashImages = json['downloadBlurHashImages'] as bool;

      return SapatitoState(
        images: {},
        downloadSizes: List.generate(downloadSizes.length, (index) {
          final item = downloadSizes[index];
          return (item.$1, item.$2);
        }),
        blurHashMode: blurHashMode as (int, int),
        downloadBlurHashImages: downloadBlurHashImages,
      );
    } catch (e) {
      log("$e");
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SapatitoState state) {
    try {
      final List<List<int>> sizes =
          state.downloadSizes.map((e) => [e.$1, e.$2]).toList();

      return {
        //'images': state.images,
        'downloadSizes': sizes,
        'blurHashMode': [state.blurHashMode.$1, state.blurHashMode.$2],
        'downloadBlurHashImages': state.downloadBlurHashImages,
      };
    } catch (e) {
      log("no guardamos bien brodi $e");
      return null;
    }
  }
}
