import 'package:flutter/material.dart';

class SolidCropPathPainter extends CustomPainter {
  static const strokeWidth = 4.0;
  final Path _path;
  final _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  SolidCropPathPainter(this._path);

  static CustomPaint drawPath(Path path) =>
      CustomPaint(painter: SolidCropPathPainter(path));

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(_path, _paint);

  @override
  bool shouldRepaint(covariant SolidCropPathPainter oldPainter) =>
      oldPainter._path != _path;
}
