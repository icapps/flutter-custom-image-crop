import 'dart:ui';

import 'package:flutter/material.dart';

class CropPathPainter extends CustomPainter {
  Path path;

  CropPathPainter({this.path});

  static Widget drawPath(Path path) => CustomPaint(painter: CropPathPainter(path: path));

  Paint _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    Path dashPath = Path();

    double dashWidth = 10.0;
    double dashSpace = 5.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
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
  bool shouldRepaint(_) => false;
}
