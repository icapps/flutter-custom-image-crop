library custom_image_crop;

import 'dart:math';

import 'package:custom_image_crop/custom_image_crop_controller.dart';
import 'package:custom_image_crop/custom_image_crop_data.dart';
import 'package:custom_image_crop/custom_image_crop_rect_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:gesture_x_detector/gesture_x_detector.dart';

class CustomImageCrop extends StatefulWidget {
  final ImageProvider image;
  final CustomImageCropController cropController;
  final Color color;

  const CustomImageCrop({
    Key key,
    this.image,
    this.cropController,
    this.color = const Color.fromRGBO(0, 0, 0, 0.5),
  }) : super(key: key);

  @override
  _CustomImageCropState createState() => _CustomImageCropState();
}

class _CustomImageCropState extends State<CustomImageCrop> with CustomImageCropListener {
  CustomImageCropController controller;
  CropImageData dataTransitionStart;
  double minScale = 1;
  double maxScale = 1;

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
    // Display image
    // Display grayed out area (Optional color?)
    // Draw line (Optional custom method?, Optional other shapes?)
    // Zoom functionality with non-zoom border
    // Rotate image
    // Move image
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cropWidth = min(width, height) / 3;
    minScale = 1.1;
    maxScale = 2;
    return XGestureDetector(
      onMoveStart: onMoveStart,
      onMoveUpdate: onMoveUpdate,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
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
            child: new ClipPath(
              clipper: new InvertedCircleClipper(cropWidth),
              child: new Container(
                color: widget.color,
              ),
            ),
          )
        ],
      ),
    );
  }

  void onScaleStart(_) {
    dataTransitionStart = null; // Reset for update
  }

  void onScaleUpdate(ScaleEvent event) {
    print("$data");
    if (dataTransitionStart != null) {
      addTransition(dataTransitionStart - CropImageData(scale: event.scale, angle: event.rotationAngle));
    }
    dataTransitionStart = CropImageData(scale: event.scale, angle: event.rotationAngle);
  }

  void onMoveStart(_) {
    dataTransitionStart = null; // Reset for update
  }

  void onMoveUpdate(MoveEvent event) {
    print("$data");
    addTransition(CropImageData(x: event.delta.dx, y: event.delta.dy));
  }

  @override
  RawImage onCropImage() {
    return null;
  }

  @override
  void addTransition(CropImageData transition) {
    setState(() {
      data += transition;
      if (data.scale > maxScale) {
        data.scale = maxScale;
      } else if (data.scale < minScale) {
        data.scale = minScale;
      }
    });
  }

  @override
  void setData(CropImageData transition) {
    setState(() {
      data = transition;
    });
  }
}
