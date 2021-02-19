import 'dart:ui';

import 'package:flutter/material.dart';

class SolidCropPathPainter extends CustomPainter {
  Path path;

  SolidCropPathPainter({this.path});

  static Widget drawPath(Path path) => CustomPaint(painter: SolidCropPathPainter(path: path));

  Paint _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(path, _paint);

  @override
  bool shouldRepaint(_) => false;
}
