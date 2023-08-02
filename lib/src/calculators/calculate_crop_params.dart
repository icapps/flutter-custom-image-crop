import 'dart:math';

import 'package:custom_image_crop/src/models/params_model.dart';
import 'package:custom_image_crop/src/widgets/custom_image_crop_widget.dart';

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
      final cropSize = min(screenWidth, screenHeight) * cropPercentage;
      final cropSizeToPaint = cropSize;
      final defaultScale = cropSize / max(imageWidth, imageHeight);

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);

    case CustomImageFit.fillCropWidth:
      final cropSize = screenWidth * cropPercentage;
      final cropSizeToPaint = cropSize;
      final defaultScale = cropSize / imageWidth;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillCropHeight:
      final cropSize = screenHeight * cropPercentage;
      final cropSizeToPaint = cropSize;
      final defaultScale = cropSize / imageHeight;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fitVisibleSpace:
      late final double cropSize;
      late final double cropSizeToPaint;
      late final double defaultScale;
      cropSizeToPaint = min(screenWidth, screenHeight) * cropPercentage;

      if (screenHeight < screenWidth) {
        cropSize = screenHeight;
        defaultScale = screenHeight / imageHeight;
      } else {
        cropSize = screenWidth;
        defaultScale = screenWidth / imageWidth;
      }

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillVisibleSpace:
      late final double cropSize;
      late final double cropSizeToPaint;
      late final double defaultScale;
      cropSizeToPaint = min(screenWidth, screenHeight) * cropPercentage;

      if (screenHeight > screenWidth) {
        cropSize = screenHeight;
        defaultScale = screenHeight / imageHeight;
      } else {
        cropSize = screenWidth;
        defaultScale = screenWidth / imageWidth;
      }

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillVisibleHeight:
      final cropSize = screenHeight;
      final cropSizeToPaint = min(screenWidth, screenHeight) * cropPercentage;
      final defaultScale = screenHeight / imageHeight;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
    case CustomImageFit.fillVisiblelWidth:
      final cropSize = screenWidth;
      final cropSizeToPaint = min(screenWidth, screenHeight) * cropPercentage;
      final defaultScale = screenWidth / imageWidth;

      return CropFitParams(cropSize, cropSizeToPaint, defaultScale);
  }
}
