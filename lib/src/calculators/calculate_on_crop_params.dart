part of 'package:custom_image_crop/src/widgets/custom_image_crop_widget.dart';

/// Returns params to use for cropping image.
OnCropParams caclulateOnCropParams({
  required double screenWidth,
  required double screenHeight,
  required double cropPercentage,
  required double dataScale,
  required int imageWidth,
  required int imageHeight,
  required CustomImageFit imageFit,
}) {
  /// 'uiSize' is the size of the ui screen
  /// 'cropSize' is the size of the area to crop
  /// 'translateScale' is the scale used to adjust x and y coodinates of the crop area
  /// 'scale' is used to adjust image scale

  switch (imageFit) {
    case CustomImageFit.fitCropSpace:
      final uiSize = min(screenWidth, screenHeight);
      final cropSize = max(imageWidth, imageHeight).toDouble();
      final translateScale = cropSize / (uiSize * cropPercentage);
      final scale = dataScale;

      return OnCropParams(cropSize, translateScale, scale);

    case CustomImageFit.fillCropWidth:
      final uiSize = screenWidth;
      final cropSize = imageWidth.toDouble();
      final translateScale = cropSize / (uiSize * cropPercentage);
      final scale = dataScale;

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillCropHeight:
      final uiSize = screenHeight;
      final cropSize = imageHeight.toDouble();
      final translateScale = cropSize / (uiSize * cropPercentage);
      final scale = dataScale;

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fitVisibleSpace:
      late final double uiSize;
      late final double cropSize;
      late final double translateScale;
      late final double scale;

      if (screenHeight < screenWidth) {
        uiSize = screenHeight;
        cropSize = imageHeight.toDouble();
        translateScale = cropSize / uiSize / cropPercentage * (screenHeight / screenWidth);
        scale = dataScale / cropPercentage * (screenHeight / screenWidth);
      } else {
        uiSize = screenWidth;
        cropSize = imageWidth.toDouble();
        translateScale = cropSize / uiSize / cropPercentage;
        scale = dataScale / cropPercentage;
      }

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillVisibleSpace:
      late final double uiSize;
      late final double cropSize;
      late final double translateScale;
      late final double scale;

      if (screenHeight > screenWidth) {
        uiSize = screenHeight;
        cropSize = imageHeight.toDouble();
        translateScale = cropSize / uiSize / cropPercentage * (screenHeight / screenWidth);
        scale = dataScale / cropPercentage * (screenHeight / screenWidth);
      } else {
        uiSize = screenWidth;
        cropSize = imageWidth.toDouble();
        translateScale = cropSize / uiSize / cropPercentage;
        scale = dataScale / cropPercentage;
      }

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillVisibleHeight:
      final uiSize = screenHeight;
      final cropSize = imageHeight.toDouble();
      final translateScale = cropSize / uiSize / cropPercentage * (screenHeight / screenWidth);
      final scale = dataScale / cropPercentage * (screenHeight / screenWidth);

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillVisiblelWidth:
      final uiSize = screenWidth;
      final cropSize = imageWidth.toDouble();
      final translateScale = cropSize / uiSize / cropPercentage;
      final scale = dataScale / cropPercentage;

      return OnCropParams(cropSize, translateScale, scale);
  }
}
