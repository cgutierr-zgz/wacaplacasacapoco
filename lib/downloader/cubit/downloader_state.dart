part of 'downloader_cubit.dart';

enum DownloadSizes {
  small(size: (200, 200)),
  medium(size: (300, 300));

  const DownloadSizes({required this.size});
  final (int, int) size;

  String get fileSuffix => switch (this) {
        DownloadSizes.small => '_small',
        DownloadSizes.medium => '_medium'
      };
}

class DownloaderState {
  const DownloaderState({
    required this.images,
    required this.blurHashMode,
    required this.downloadBlurHashImages,
    required this.maintainAspectRatio,
    required this.downloadOriginalImage,
  });

  final Map<String, Uint8List> images;
  final (int, int) blurHashMode;
  final bool downloadBlurHashImages;
  final bool maintainAspectRatio;
  final bool downloadOriginalImage;

  static const initialState = DownloaderState(
    images: {},
    blurHashMode: (3, 3),
    downloadBlurHashImages: false,
    maintainAspectRatio: false,
    downloadOriginalImage: false,
  );

  DownloaderState copyWith({
    Map<String, Uint8List>? images,
    (int, int)? blurHashMode,
    bool? downloadBlurHashImages,
    bool? maintainAspectRatio,
    bool? downloadOriginalImage,
  }) {
    return DownloaderState(
      images: images ?? this.images,
      blurHashMode: blurHashMode ?? this.blurHashMode,
      downloadBlurHashImages:
          downloadBlurHashImages ?? this.downloadBlurHashImages,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      downloadOriginalImage:
          downloadOriginalImage ?? this.downloadOriginalImage,
    );
  }
}
