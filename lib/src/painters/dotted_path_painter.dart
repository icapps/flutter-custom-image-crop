import 'package:flutter/material.dart';

class DottedCropPathPainter extends CustomPainter {
  static const dashWidth = 10.0;
  static const dashSpace = 5.0;
  static const strokeWidth = 4.0;
  final Path _path;
  final _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  DottedCropPathPainter(this._path);

  static CustomPaint drawPath(Path path) =>
      CustomPaint(painter: DottedCropPathPainter(path));

  @override
  void paint(Canvas canvas, Size size) {
    final dashPath = Path();
    var distance = 0.0;
    for (final pathMetric in _path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, _paint);
  }

  @override
  bool shouldRepaint(covariant DottedCropPathPainter oldClipper) =>
      oldClipper._path != _path;
}
