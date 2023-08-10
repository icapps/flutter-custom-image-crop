import 'package:flutter/material.dart';

/// Draw a dotted path around the given path
class DottedCropPathPainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Path _path;
  final Paint pathPaint;

  /// Draw a dotted path around the given path
  DottedCropPathPainter(
    this._path, {
    this.dashWidth = 10.0,
    this.dashSpace = 5.0,
    required this.pathPaint,
  });

  /// Return a CustomPaint widget with the current CustomPainter
  static CustomPaint drawPath(Path path, {Paint? pathPaint}) {
    if (pathPaint != null) {
      return CustomPaint(
        painter: DottedCropPathPainter(path, pathPaint: pathPaint),
      );
    } else {
      return CustomPaint(
        painter: DottedCropPathPainter(
          path,
          pathPaint: Paint()
            ..color = Colors.white
            ..strokeWidth = 4.0
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round,
        ),
      );
    }
  }

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
    canvas.drawPath(dashPath, pathPaint);
  }

  @override
  bool shouldRepaint(covariant DottedCropPathPainter oldClipper) =>
      oldClipper._path != _path;
}
