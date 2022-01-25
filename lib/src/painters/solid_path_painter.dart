import 'package:flutter/material.dart';

/// Draw a solid path around the given path
class SolidCropPathPainter extends CustomPainter {
  static const _strokeWidth = 4.0;
  final Path _path;
  final _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = _strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Draw a solid path around the given path
  SolidCropPathPainter(this._path);

  /// Return a CustomPaint widget with the current CustomPainter
  static CustomPaint drawPath(Path path) =>
      CustomPaint(painter: SolidCropPathPainter(path));

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(_path, _paint);

  @override
  bool shouldRepaint(covariant SolidCropPathPainter oldPainter) =>
      oldPainter._path != _path;
}
