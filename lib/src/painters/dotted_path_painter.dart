import 'package:flutter/material.dart';

/// Draw a dotted path around the given path
class DottedCropPathPainter extends CustomPainter {
  static const _dashWidth = 10.0;
  static const _dashSpace = 5.0;
  static const _strokeWidth = 4.0;
  final Path _path;
  final _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = _strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Draw a dotted path around the given path
  DottedCropPathPainter(this._path);

  /// Return a CustomPaint widget with the current CustomPainter
  static CustomPaint drawPath(Path path) =>
      CustomPaint(painter: DottedCropPathPainter(path));

  @override
  void paint(Canvas canvas, Size size) {
    final dashPath = Path();
    var distance = 0.0;
    for (final pathMetric in _path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + _dashWidth),
          Offset.zero,
        );
        distance += _dashWidth;
        distance += _dashSpace;
      }
    }
    canvas.drawPath(dashPath, _paint);
  }

  @override
  bool shouldRepaint(covariant DottedCropPathPainter oldClipper) =>
      oldClipper._path != _path;
}
