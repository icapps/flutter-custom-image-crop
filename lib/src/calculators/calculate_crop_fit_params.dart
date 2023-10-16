import 'dart:math';

import 'package:custom_image_crop/src/models/params_model.dart';
import 'package:custom_image_crop/src/widgets/custom_image_crop_widget.dart';

/// Returns params to use for displaying crop screen.
CropFitParams calculateCropFitParams({
  required double screenWidth,
  required double screenHeight,
  required double cropPercentage,
  required int imageWidth,
  required int imageHeight,
  required CustomImageFit imageFit,
  required double aspectRatio,
}) {
  /// the width of the area to crop
  final double cropSizeWidth;

  /// the height of the area to crop
  final double cropSizeHeight;

  /// used to adjust image scale
  final double defaultScale;

  switch (imageFit) {
    case CustomImageFit.fillCropSpace:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
        defaultScale =
            cropSizeWidth * max(imageWidth / imageHeight, 1.0) / imageWidth;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
        defaultScale =
            cropSizeHeight * max(imageHeight / imageWidth, 1.0) / imageHeight;
      }
      break;

    case CustomImageFit.fitCropSpace:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
        defaultScale = cropSizeHeight / imageHeight;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
        defaultScale = cropSizeWidth / imageWidth;
      }
      break;

    case CustomImageFit.fillCropWidth:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
      }
      defaultScale = cropSizeWidth / imageWidth;
      break;

    case CustomImageFit.fillCropHeight:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
      }
      defaultScale = cropSizeHeight / imageHeight;
      break;

    case CustomImageFit.fitVisibleSpace:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
        defaultScale = screenWidth / imageWidth;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
        defaultScale = screenHeight / imageHeight;
      }
      break;

    case CustomImageFit.fillVisibleSpace:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
        defaultScale = screenHeight / imageHeight;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
        defaultScale = screenWidth / imageWidth;
      }
      break;

    case CustomImageFit.fillVisibleHeight:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
      }
      defaultScale = screenHeight / imageHeight;
      break;

    case CustomImageFit.fillVisibleWidth:
      if (screenWidth <= screenHeight * aspectRatio) {
        cropSizeWidth = screenWidth * cropPercentage;
        cropSizeHeight = cropSizeWidth / aspectRatio;
      } else {
        cropSizeHeight = screenHeight * cropPercentage;
        cropSizeWidth = cropSizeHeight * aspectRatio;
      }
      defaultScale = screenWidth / imageWidth;
      break;
  }

  return CropFitParams(
    cropSizeWidth: cropSizeWidth,
    cropSizeHeight: cropSizeHeight,
    additionalScale: defaultScale,
  );
}
