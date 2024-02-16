part of 'downloader_cubit.dart';

class DownloaderState {
  const DownloaderState({
    required this.images,
    required this.downloadSizes,
    required this.blurHashMode,
    required this.downloadBlurHashImages,
  });

  final Map<String, Uint8List> images;
  final List<(int, int)> downloadSizes;
  final (int, int) blurHashMode;
  final bool downloadBlurHashImages;

  static const initialState = DownloaderState(
    images: {},
    downloadSizes: [
      (250, 250),
      (700, 700),
      (1200, 1200),
    ],
    blurHashMode: (3, 3),
    downloadBlurHashImages: false,
  );

  DownloaderState copyWith({
    Map<String, Uint8List>? images,
    List<(int, int)>? downloadSizes,
    (int, int)? blurHashMode,
    bool? downloadBlurHashImages,
  }) {
    return DownloaderState(
      images: images ?? this.images,
      downloadSizes: downloadSizes ?? this.downloadSizes,
      blurHashMode: blurHashMode ?? this.blurHashMode,
      downloadBlurHashImages:
          downloadBlurHashImages ?? this.downloadBlurHashImages,
    );
  }
}
