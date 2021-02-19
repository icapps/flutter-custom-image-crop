library custom_image_crop;

import 'dart:math';
import 'dart:ui';

import 'package:custom_image_crop/custom_image_crop_controller.dart';
import 'package:custom_image_crop/custom_image_crop_data.dart';
import 'package:custom_image_crop/custom_image_crop_clipper.dart';
import 'package:custom_image_crop/custom_image_crop_path_example.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:gesture_x_detector/gesture_x_detector.dart';

class CustomImageCrop extends StatefulWidget {
  final ImageProvider image;
  final CustomImageCropController cropController;
  final Color backgroundColor;
  final Color overlayColor;
  final Function(double) path;
  final CustomCropShape shape;
  final double cropPercentage;
  final Widget Function(Path) drawPath;

  const CustomImageCrop({
    Key key,
    this.image,
    this.cropController,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.backgroundColor = Colors.white,
    this.path,
    this.shape = CustomCropShape.Square,
    this.cropPercentage = 0.8,
    this.drawPath = CropPathPainter.drawPath,
  }) : super(key: key);

  @override
  _CustomImageCropState createState() => _CustomImageCropState();
}

class _CustomImageCropState extends State<CustomImageCrop> with CustomImageCropListener {
  CustomImageCropController controller;
  CropImageData dataTransitionStart;
  Path path;
  double width, height;

  @override
  void initState() {
    controller?.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    controller?.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final cropWidth = min(width, height) * widget.cropPercentage;
    path = getPath(cropWidth, width, height);
    return XGestureDetector(
      onMoveStart: onMoveStart,
      onMoveUpdate: (details) => onMoveUpdate(details, path),
      onScaleStart: onScaleStart,
      onScaleUpdate: (details) => onScaleUpdate(details, path),
      child: Container(
        width: width,
        height: height,
        color: widget.backgroundColor,
        child: Stack(
          children: [
            Positioned(
              left: data.x + width / 2,
              top: data.y + height / 2,
              child: Transform(
                transform: Matrix4.diagonal3(vector_math.Vector3(data.scale, data.scale, 0))
                  ..rotateZ(data.angle)
                  ..translate(-width / 2, -height / 2),
                child: Container(
                  width: width,
                  height: height,
                  child: Center(
                    child: Image(
                      image: widget.image,
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: ClipPath(
                clipper: InvertedClipper(path, width, height),
                child: Container(
                  color: widget.overlayColor,
                ),
              ),
            ),
            if (widget.drawPath != null) ...{
              widget.drawPath(path),
            },
          ],
        ),
      ),
    );
  }

  void onScaleStart(_) {
    dataTransitionStart = null; // Reset for update
  }

  void onScaleUpdate(ScaleEvent event, Path path) {
    if (dataTransitionStart != null) {
      addTransition(dataTransitionStart - CropImageData(scale: event.scale, angle: event.rotationAngle));
    }
    dataTransitionStart = CropImageData(scale: event.scale, angle: event.rotationAngle);
  }

  void onMoveStart(_) {
    dataTransitionStart = null; // Reset for update
  }

  void onMoveUpdate(MoveEvent event, Path path) {
    addTransition(CropImageData(x: event.delta.dx, y: event.delta.dy));
  }

  Path getPath(double cropWidth, double width, double height) {
    if (widget.path != null) {
      return widget.path(cropWidth);
    }
    switch (widget.shape) {
      case CustomCropShape.Circle:
        return Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(width / 2, height / 2),
              radius: cropWidth / 2,
            ),
          );
      default:
        return Path()
          ..addRect(
            Rect.fromCenter(
              center: Offset(width / 2, height / 2),
              width: cropWidth,
              height: cropWidth,
            ),
          );
    }
  }

  @override
  RawImage onCropImage() {
    return null;
  }

  @override
  void addTransition(CropImageData transition) {
    setState(() {
      if (dataAllowed(data + transition)) {
        data += transition;
      }
    });
  }

  bool dataAllowed(CropImageData data) {
    // For now, this will do. The idea is that we create
    // a path from the data and check if when we combine
    // that with the crop path that the resulting path
    // overlap the hole (crop). So we check if all pixels
    // from the crop contain pixels from the original image
    return (data.scale < 2 && data.scale > 0.5);
  }

  @override
  void setData(CropImageData newData) {
    setState(() {
      if (dataAllowed(newData)) {
        data = newData;
      }
    });
  }
}

enum CustomCropShape {
  Circle,
  Square,
}
