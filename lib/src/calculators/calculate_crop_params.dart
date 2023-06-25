part of 'package:custom_image_crop/src/widgets/custom_image_crop_widget.dart';

/// Returns params to use for displaing crop screen.
CropFitParams calculateCropParams({
  required double screenWidth,
  required double screenHeight,
  required double cropPercentage,
  required int imageWidth,
  required int imageHeight,
  required CustomImageFit imageFit,
}) {
  /// 'cropSize' is the size of the full crop area
  /// 'cropSizeToPaint' is the size of the crop area highlighted in ui
  /// 'defaultScale' is used to adjust image scale

  switch (imageFit) {
    case CustomImageFit.fitCropSpace:
      final cropSize = min(screenWidth, screenHeight);
      final cropSizeToPaint = cropSize;
      final defaultScale = (cropSize * cropPercentage) / max(imageWidth, imageHeight);

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);

    case CustomImageFit.fillCropWidth:
      final cropSize = screenWidth;
      final cropSizeToPaint = cropSize;
      final defaultScale = (cropSize * cropPercentage) / imageWidth;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillCropHeight:
      final cropSize = screenHeight;
      final cropSizeToPaint = cropSize;
      final defaultScale = (cropSize * cropPercentage) / imageHeight;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fitVisibleSpace:
      late final double cropSize;
      late final double cropSizeToPaint;
      late final double defaultScale;

      if (screenHeight < screenWidth) {
        cropSize = screenHeight;
        cropSizeToPaint = screenWidth * cropPercentage;
        defaultScale = screenHeight / imageHeight;
      } else {
        cropSize = screenWidth;
        cropSizeToPaint = cropSize * cropPercentage;
        defaultScale = screenWidth / imageWidth;
      }

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillVisibleSpace:
      late final double cropSize;
      late final double cropSizeToPaint;
      late final double defaultScale;

      if (screenHeight > screenWidth) {
        cropSize = screenHeight;
        cropSizeToPaint = screenWidth * cropPercentage;
        defaultScale = screenHeight / imageHeight;
      } else {
        cropSize = screenWidth;
        cropSizeToPaint = cropSize * cropPercentage;
        defaultScale = screenWidth / imageWidth;
      }

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillVisibleHeight:
      final cropSize = screenHeight;
      final cropSizeToPaint = screenWidth * cropPercentage;
      final defaultScale = screenHeight / imageHeight;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillVisiblelWidth:
      final cropSize = screenWidth;
      final cropSizeToPaint = cropSize * cropPercentage;
      final defaultScale = screenWidth / imageWidth;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
  }
}
