import 'dart:math';

import 'package:custom_image_crop/src/models/params_model.dart';
import 'package:custom_image_crop/src/widgets/custom_image_crop_widget.dart';

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
      } else {
        uiSize = screenWidth;
        cropSize = imageWidth.toDouble();
      }

      scale = dataScale / cropPercentage;
      translateScale = cropSize / uiSize / cropPercentage;

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillVisibleSpace:
      final heightToWidthRatio = (screenHeight / screenWidth);
      late final double uiSize;
      late final double cropSize;
      late final double translateScale;
      late final double scale;

      if (screenHeight > screenWidth) {
        uiSize = screenHeight;
        cropSize = imageHeight.toDouble();
        translateScale = cropSize / uiSize / cropPercentage * heightToWidthRatio;
        scale = dataScale / cropPercentage * heightToWidthRatio;
      } else {
        uiSize = screenWidth;
        cropSize = imageWidth.toDouble();
        translateScale = cropSize / uiSize / cropPercentage / heightToWidthRatio;
        scale = dataScale / cropPercentage / heightToWidthRatio;
      }

      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillVisibleHeight:
      final heightToWidthRatio = (screenHeight / screenWidth);
      final uiSize = screenHeight;
      final cropSize = imageHeight.toDouble();
      late final double translateScale;
      late final double scale;
      if (screenWidth > screenHeight) {
        translateScale = cropSize / uiSize / cropPercentage;
        scale = dataScale / cropPercentage;
      } else {
        translateScale = cropSize / uiSize / cropPercentage * heightToWidthRatio;
        scale = dataScale / cropPercentage * heightToWidthRatio;
      }
      return OnCropParams(cropSize, translateScale, scale);
    case CustomImageFit.fillVisiblelWidth:
      final heightToWidthRatio = (screenHeight / screenWidth);
      final uiSize = screenWidth;
      final cropSize = imageWidth.toDouble();
      late final double translateScale;
      late final double scale;
      if (screenWidth > screenHeight) {
        translateScale = cropSize / uiSize / cropPercentage / heightToWidthRatio;
        scale = dataScale / cropPercentage / heightToWidthRatio;
      } else {
        translateScale = cropSize / uiSize / cropPercentage;
        scale = dataScale / cropPercentage;
      }

      return OnCropParams(cropSize, translateScale, scale);
  }
}
