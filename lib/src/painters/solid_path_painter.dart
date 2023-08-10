import 'package:flutter/material.dart';

/// Draw a solid path around the given path
class SolidCropPathPainter extends CustomPainter {
  static const _strokeWidth = 4.0;
  final Path _path;
  final Paint pathPaint;

  /// Draw a solid path around the given path
  SolidCropPathPainter(this._path, this.pathPaint);

  /// Return a CustomPaint widget with the current CustomPainter
  static CustomPaint drawPath(Path path, {Paint? pathPaint}) {
    if (pathPaint != null) {
      return CustomPaint(
        painter: SolidCropPathPainter(path, pathPaint),
      );
    } else {
      return CustomPaint(
        painter: SolidCropPathPainter(
          path,
          Paint()
            ..color = Colors.white
            ..strokeWidth = _strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(_path, pathPaint);

  @override
  bool shouldRepaint(covariant SolidCropPathPainter oldPainter) =>
      oldPainter._path != _path;
}
