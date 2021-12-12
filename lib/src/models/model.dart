import 'dart:math';

class CropImageData {
  double x;
  double y;
  double angle;
  double scale;

  CropImageData({this.x = 0, this.y = 0, this.angle = 0, this.scale = 1});

  CropImageData operator +(CropImageData other) => CropImageData(
      x: x + other.x,
      y: y + other.y,
      angle: (angle + other.angle) % (2 * pi),
      scale: scale * other.scale);

  CropImageData operator -(CropImageData other) => CropImageData(
      x: x - other.x,
      y: y - other.y,
      angle: (angle - other.angle) % (2 * pi),
      scale: other.scale / scale);

  String toString() => "{x: $x, y: $y, angle: $angle, scale: $scale}";
}
