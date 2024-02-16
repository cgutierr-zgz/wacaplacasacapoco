// ignore_for_file: avoid_dynamic_calls

import 'dart:developer';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image/image.dart' as img;

part 'downloader_state.dart';

class DownloaderCubit extends HydratedCubit<DownloaderState> {
  DownloaderCubit() : super(DownloaderState.initialState);

  void updateBlurHash({int? x, int? y}) {
    final newState = state.copyWith(
      blurHashMode: (x ?? state.blurHashMode.$1, y ?? state.blurHashMode.$2),
    );
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
    // TODO: Download to folder/zip (?)

    _downloadItem(
      blobParts: [blurHash],
      fileName: '${fileName}_blurhash.txt',
    );

    for (final size in state.downloadSizes) {
      final name = '${size.$1}x${size.$2}_$fileName';

      try {
        if (state.downloadBlurHashImages) {
          final blurImage = await BlurHash.decode(blurHash, size.$1, size.$2);

          _downloadItem(
            blobParts: [blurImage],
            fileName: '${name}_blurhash.png',
          );
        }

        final image = img.decodeImage(fileContent)!;
        final resized = img.copyResize(
          image,
          width: size.$1,
          height: size.$2,
        );
        _downloadItem(
          blobParts: [img.encodePng(resized)],
          fileName: '$name.png',
        );
      } catch (e) {
        log('Error downloading $name: $e');
      }
    }
  }

  void _downloadItem({
    required List<dynamic> blobParts,
    required String fileName,
  }) {
    final blob = html.Blob(blobParts);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
  }

  void addDownloadSize({required int x, required int y}) {
    final newSize = (x, y);
    final newSizes = [...state.downloadSizes, newSize];
    //final newState = state.copyWith(downloadSizes: newSizes);
    final newState = state.copyWith(downloadSizes: [(200, 200), (500, 500)]);
    emit(newState);
  }

  void removeDownloadSize(int index) {
    if (index >= 0 && index < state.downloadSizes.length) {
      final newSizes = List<(int, int)>.from(state.downloadSizes)
        ..removeAt(index);
      final newState = state.copyWith(downloadSizes: newSizes);
      emit(newState);
    }
  }

  @override
  DownloaderState? fromJson(Map<String, dynamic> json) {
    try {
      //final images = Map<String, Uint8List>.from(json['images']);
      final downloadSizes = (json['downloadSizes'] as List<dynamic>)
          .map((e) => (e[0], e[1]))
          .toList();
      final blurHashMode = (json['blurHashMode'][0], json['blurHashMode'][1]);
      final downloadBlurHashImages = json['downloadBlurHashImages'] as bool;

      return DownloaderState(
        images: {},
        downloadSizes: List.generate(downloadSizes.length, (index) {
          final item = downloadSizes[index];
          return (item.$1, item.$2);
        }),
        blurHashMode: blurHashMode as (int, int),
        downloadBlurHashImages: downloadBlurHashImages,
      );
    } catch (e) {
      log('Could not load state. [$e]');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DownloaderState state) {
    try {
      final sizes = state.downloadSizes.map((e) => [e.$1, e.$2]).toList();

      return {
        //'images': state.images,
        'downloadSizes': sizes,
        'blurHashMode': [state.blurHashMode.$1, state.blurHashMode.$2],
        'downloadBlurHashImages': state.downloadBlurHashImages,
      };
    } catch (e) {
      log('Could not save state. [$e]');
      return null;
    }
  }
}
