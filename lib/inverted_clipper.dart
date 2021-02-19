import 'package:flutter/material.dart';

class InvertedClipper extends CustomClipper<Path> {
  Path path;

  InvertedClipper(Path _path, double width, double height) {
    path = Path.from(_path)
      ..addRect(Rect.fromLTWH(0.0, 0.0, width, height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(InvertedClipper oldClipper) => false;
}
