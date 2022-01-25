import 'dart:math';

/// The data that handles the transformation of the cropped image.
class CropImageData {
  /// Horizontal translation of the cropped image
  double x;

  /// Vertical translation of the cropped image
  double y;

  /// The rotation of the cropped image
  double angle;

  /// The scale of the cropped image
  double scale;

  /// The data that handles the transformation of the cropped image.
  CropImageData({this.x = 0, this.y = 0, this.angle = 0, this.scale = 1});

  /// When adding two data objects, the translation is added, the rotation is added and the scale is multiplied.
  CropImageData operator +(CropImageData other) => CropImageData(
      x: x + other.x,
      y: y + other.y,
      angle: (angle + other.angle) % (2 * pi),
      scale: scale * other.scale);

  /// When subtracting two data objects, the translation is subtracted, the rotation is subtracted and the scale is divided.
  CropImageData operator -(CropImageData other) => CropImageData(
      x: x - other.x,
      y: y - other.y,
      angle: (angle - other.angle) % (2 * pi),
      scale: other.scale / scale);

  /// Representation of the data as a string.
  String toString() => "{x: $x, y: $y, angle: $angle, scale: $scale}";
}
