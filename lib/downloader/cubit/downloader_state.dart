part of 'downloader_cubit.dart';

enum DownloadSizes {
  s(size: (200, 200)),
  m(size: (300, 300));

  const DownloadSizes({required this.size});
  final (int, int) size;

  String get fileSuffix => '_${name.toUpperCase()}';
}

class DownloaderState {
  const DownloaderState({
    required this.images,
    required this.blurHashMode,
    required this.downloadBlurHashImages,
  });

  final Map<String, Uint8List> images;
  final (int, int) blurHashMode;
  final bool downloadBlurHashImages;

  static const initialState = DownloaderState(
    images: {},
    blurHashMode: (3, 3),
    downloadBlurHashImages: false,
  );

  DownloaderState copyWith({
    Map<String, Uint8List>? images,
    (int, int)? blurHashMode,
    bool? downloadBlurHashImages,
  }) {
    return DownloaderState(
      images: images ?? this.images,
      blurHashMode: blurHashMode ?? this.blurHashMode,
      downloadBlurHashImages:
          downloadBlurHashImages ?? this.downloadBlurHashImages,
    );
  }
}
