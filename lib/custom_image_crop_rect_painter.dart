import 'package:flutter/material.dart';

class InvertedCircleClipper extends CustomClipper<Path> {
  final double width;

  InvertedCircleClipper(this.width);

  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(
        new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: width,
        ),
      )
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(InvertedCircleClipper oldClipper) => width != oldClipper.width;
}
