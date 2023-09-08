import 'dart:math';

import 'package:custom_image_crop/src/models/params_model.dart';
import 'package:custom_image_crop/src/widgets/custom_image_crop_widget.dart';

/// Returns params to use for cropping image.
OnCropParams caclulateOnCropParams({
  required double screenWidth,
  required double screenHeight,
  required double cropPercentage,
  required double dataScale,
  required double aspectRatio,
  required int imageWidth,
  required int imageHeight,
  required CustomImageFit imageFit,
}) {
  /// the size of the area to crop (width and/or height depending on the aspect ratio)
  final double cropSizeMax;

  /// the scale used to adjust x and y coodinates of the crop area
  final double translateScale;

  /// used to adjust image scale
  final double scale;

  /// Temp variable used to calculate the translateScale
  final double uiSize;

  switch (imageFit) {
    case CustomImageFit.fillCropSpace:
      if (screenWidth > screenHeight * aspectRatio) {
        uiSize = screenHeight;
        cropSizeMax = imageHeight.toDouble();
      } else {
        uiSize = screenWidth;
        cropSizeMax = imageWidth.toDouble();
      }
      translateScale = cropSizeMax / (uiSize * cropPercentage);
      scale = dataScale;
      break;

    case CustomImageFit.fitCropSpace:
      if (screenWidth > screenHeight * aspectRatio) {
        uiSize = screenHeight;
        cropSizeMax = imageWidth.toDouble() / aspectRatio;
      } else {
        uiSize = screenWidth;
        cropSizeMax = imageHeight.toDouble() * aspectRatio;
      }
      translateScale = cropSizeMax / (uiSize * cropPercentage);
      scale = dataScale;
      break;

    case CustomImageFit.fillCropWidth:
      uiSize = screenWidth;
      cropSizeMax = imageWidth / min(1, aspectRatio);
      translateScale = cropSizeMax / (uiSize * cropPercentage);
      scale = dataScale;
      break;

    case CustomImageFit.fillCropHeight:
      uiSize = screenHeight;
      cropSizeMax = imageHeight * max(1, aspectRatio);
      translateScale = cropSizeMax / (uiSize * cropPercentage);
      scale = dataScale;
      break;

    case CustomImageFit.fitVisibleSpace:
      final double uiSize;
      if (screenHeight * aspectRatio < screenWidth) {
        uiSize = screenHeight;
        cropSizeMax = imageHeight.toDouble();
      } else {
        uiSize = screenWidth;
        cropSizeMax = imageWidth.toDouble();
      }
      scale = dataScale / cropPercentage;
      translateScale = cropSizeMax / uiSize / cropPercentage;
      break;

    case CustomImageFit.fillVisibleSpace:
      final heightToWidthRatio = (screenHeight / screenWidth);

      if (screenHeight * aspectRatio > screenWidth) {
        uiSize = screenHeight;
        cropSizeMax = imageHeight.toDouble();
        translateScale =
            cropSizeMax / uiSize / cropPercentage * heightToWidthRatio;
        scale = dataScale / cropPercentage * heightToWidthRatio;
      } else {
        uiSize = screenWidth;
        cropSizeMax = imageWidth.toDouble();
        translateScale =
            cropSizeMax / uiSize / cropPercentage / heightToWidthRatio;
        scale = dataScale / cropPercentage / heightToWidthRatio;
      }
      break;

    case CustomImageFit.fillVisibleHeight:
      final heightToWidthRatio = (screenHeight / screenWidth);
      uiSize = screenHeight;
      cropSizeMax = imageHeight.toDouble();
      if (screenWidth > screenHeight * aspectRatio) {
        translateScale = cropSizeMax / uiSize / cropPercentage;
        scale = dataScale / cropPercentage;
      } else {
        translateScale =
            cropSizeMax / uiSize / cropPercentage * heightToWidthRatio;
        scale = dataScale / cropPercentage * heightToWidthRatio;
      }
      break;

    case CustomImageFit.fillVisiblelWidth:
      final heightToWidthRatio = (screenHeight / screenWidth);
      uiSize = screenWidth;
      cropSizeMax = imageWidth.toDouble();
      if (screenWidth > screenHeight * aspectRatio) {
        translateScale =
            cropSizeMax / uiSize / cropPercentage / heightToWidthRatio;
        scale = dataScale / cropPercentage / heightToWidthRatio;
      } else {
        translateScale = cropSizeMax / uiSize / cropPercentage;
        scale = dataScale / cropPercentage;
      }
      break;
  }

  final double cropSizeWidth;
  final double cropSizeHeight;
  if (aspectRatio > 1) {
    cropSizeWidth = cropSizeMax;
    cropSizeHeight = cropSizeWidth / aspectRatio;
  } else {
    cropSizeHeight = cropSizeMax;
    cropSizeWidth = cropSizeHeight * aspectRatio;
  }
  return OnCropParams(
    cropSizeHeight: cropSizeHeight,
    cropSizeWidth: cropSizeWidth,
    translateScale: translateScale,
    scale: scale,
  );
}
