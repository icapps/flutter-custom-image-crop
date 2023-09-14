/// Params used to display crop screen.
class CropFitParams {
  /// The width of displayed crop area.
  final double cropSizeWidth;

  /// The height of displayed crop area.
  final double cropSizeHeight;

  /// The scale used to adjust display of the image based on 'CustomImageFit' type.
  final double additionalScale;

  CropFitParams({
    required this.cropSizeWidth,
    required this.cropSizeHeight,
    required this.additionalScale,
  });
}

/// Params used to crop image.
class OnCropParams {
  /// The width of actual crop area.
  final double cropSizeWidth;

  /// The height of actual crop area.
  final double cropSizeHeight;

  /// The translate scale used to crop the image based on 'CustomImageFit' type.
  final double translateScale;

  /// Is used to crop the image based on 'CustomImageFit' type.
  final double scale;

  OnCropParams({
    required this.cropSizeWidth,
    required this.cropSizeHeight,
    required this.translateScale,
    required this.scale,
  });
}
