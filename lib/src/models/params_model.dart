/// Params used to display crop screen.
class CropFitParams {
  /// The size of actual crop area.
  final double cropSize;

  /// The size of crop area to show on screen.
  final double cropSizeToPaint;

  /// The scale used to adjust display of the image based on 'CustomImageFit' type.
  final double additionalScale;

  CropFitParams(this.cropSize, this.cropSizeToPaint, this.additionalScale);
}

/// Params used to crop image.
class OnCropParams {
  /// The size of actual crop area.
  final double cropSize;

  /// The translate scale used to crop the image based on 'CustomImageFit' type.
  final double translateScale;

  /// Is used to crop the image based on 'CustomImageFit' type.
  final double scale;

  OnCropParams(this.cropSize, this.translateScale, this.scale);
}
