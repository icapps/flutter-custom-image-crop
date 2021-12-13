import 'package:flutter/material.dart';

class InvertedClipper extends CustomClipper<Path> {
  final Path _path;

  InvertedClipper(Path path, double width, double height)
      : _path = Path.from(path)
          ..addRect(Rect.fromLTWH(0.0, 0.0, width, height))
          ..fillType = PathFillType.evenOdd;

  @override
  Path getClip(Size size) => _path;

  @override
  bool shouldReclip(covariant InvertedClipper oldClipper) =>
      oldClipper._path != _path;
}
