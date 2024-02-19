// ignore_for_file: avoid_dynamic_calls

import 'dart:developer';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

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

  void toggleMaintainAspectRatio() {
    final newState =
        state.copyWith(maintainAspectRatio: !state.maintainAspectRatio);
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
    final nameWithoutExtension = p.basenameWithoutExtension(fileName);
    final ext = p.extension(fileName).toLowerCase();

    _downloadItem(
      blobParts: [blurHash],
      fileName: '$nameWithoutExtension.txt',
    );

    final image = img.decodeImage(fileContent)!;
    /* MARK: OG image
    _downloadItem(
      blobParts: [img.encodePng(image)],
      fileName: '${fileName}_og.png',
    );
    */

    for (final value in DownloadSizes.values) {
      final name = '$nameWithoutExtension${value.fileSuffix}';

      try {
        if (state.downloadBlurHashImages) {
          final blurImage = await BlurHash.decode(
            blurHash,
            value.size.$1,
            value.size.$2,
          );
          _downloadItem(
            blobParts: [blurImage],
            fileName: '${nameWithoutExtension}_blurhash.png',
          );
        }

        final resized = img.copyResize(
          image,
          width: value.size.$1,
          height: value.size.$2,
          maintainAspect: state.maintainAspectRatio,
        );
        List<dynamic> blobParts;
        if (ext case '.png') {
          // || '.apng') {
          blobParts = img.encodePng(resized);
        } else {
          blobParts = img.encodeJpg(resized);
        }
        _downloadItem(
          blobParts: [blobParts],
          fileName: '$name$ext',
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
      ..setAttribute('download', fileName.replaceAll(" ", "_").toLowerCase())
      ..click();
    //html.Url.revokeObjectUrl(url);
  }

  @override
  DownloaderState? fromJson(Map<String, dynamic> json) {
    try {
      //final images = Map<String, Uint8List>.from(json['images']);
      final blurHashMode = (json['blurHashMode'][0], json['blurHashMode'][1]);

      return DownloaderState(
        images: {},
        blurHashMode: blurHashMode as (int, int),
        downloadBlurHashImages: json['downloadBlurHashImages'] as bool,
        maintainAspectRatio: json['maintainAspectRatio'] as bool,
      );
    } catch (e) {
      log('Could not load state. [$e]');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DownloaderState state) {
    try {
      return {
        //'images': state.images,
        'blurHashMode': [state.blurHashMode.$1, state.blurHashMode.$2],
        'downloadBlurHashImages': state.downloadBlurHashImages,
        'maintainAspectRatio': state.maintainAspectRatio,
      };
    } catch (e) {
      log('Could not save state. [$e]');
      return null;
    }
  }
}
