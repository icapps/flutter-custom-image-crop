import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import 'package:custom_image_crop/src/controller.dart';
import 'package:custom_image_crop/src/dotted_path_painter.dart';
import 'package:custom_image_crop/src/inverted_clipper.dart';
import 'package:custom_image_crop/src/model.dart';

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
    @required this.image,
    Key key,
    this.cropController,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.backgroundColor = Colors.white,
    this.path,
    this.shape = CustomCropShape.Circle,
    this.cropPercentage = 0.8,
    this.drawPath = DottedCropPathPainter.drawPath,
  }) : super(key: key);

  @override
  _CustomImageCropState createState() => _CustomImageCropState(cropController);
}

class _CustomImageCropState extends State<CustomImageCrop> with CustomImageCropListener {
  CustomImageCropController controller;
  CropImageData dataTransitionStart;
  Path path;
  double width, height;
  ui.Image imageAsUIImage;
  ImageStream _imageStream;
  ImageStreamListener _imageListener;

  _CustomImageCropState(this.controller);

  @override
  void initState() {
    controller?.addListener(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  void _getImage({bool force = false}) {
    final oldImageStream = _imageStream;
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    if (_imageStream.key != oldImageStream?.key || force) {
      oldImageStream?.removeListener(_imageListener);
      _imageListener = ImageStreamListener(_updateImage);
      _imageStream.addListener(_imageListener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      imageAsUIImage = imageInfo.image;
    });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageListener);
    controller?.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (imageAsUIImage == null) {
      return Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        width = constraints.maxWidth;
        height = constraints.maxHeight;
        final cropWidth = min(width, height) * widget.cropPercentage;
        final defaultScale = min(imageAsUIImage.width, imageAsUIImage.height) / cropWidth;
        final scale = data.scale * defaultScale;
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
                    transform: Matrix4.diagonal3(vector_math.Vector3(scale, scale, 0))
                      ..rotateZ(data.angle)
                      ..translate(-imageAsUIImage.width / 2, -imageAsUIImage.height / 2),
                    child: Image(
                      image: widget.image,
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
      },
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
  Future<MemoryImage> onCropImage() async {
    if (imageAsUIImage == null) {
      return null;
    }
    final cropWidth = min(width, height) * widget.cropPercentage;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final defaultScale = min(imageAsUIImage.width, imageAsUIImage.height) / cropWidth;
    final scale = data.scale * defaultScale;
    final clipPath = Path.from(getPath(cropWidth, cropWidth, cropWidth));
    final matrix4Image = Matrix4.diagonal3(vector_math.Vector3(1, 1, 0))
      ..translate(data.x + cropWidth / 2, data.y + cropWidth / 2)
      ..scale(scale)
      ..rotateZ(data.angle);
    final imagePaint = Paint()..isAntiAlias = false;
    final bgPaint = Paint()
      ..color = widget.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, cropWidth, cropWidth), bgPaint);
    canvas.save();
    canvas.clipPath(clipPath);
    canvas.transform(matrix4Image.storage);
    canvas.drawImage(imageAsUIImage, Offset(-imageAsUIImage.width / 2, -imageAsUIImage.height / 2), imagePaint);
    canvas.restore();

    // Optionally remove magenta from image by evaluating every pixel
    // See https://github.com/brendan-duncan/image/blob/master/lib/src/transform/copy_crop.dart

    // final bytes = await compute(computeToByteData, <String, dynamic>{'pictureRecorder': pictureRecorder, 'cropWidth': cropWidth});

    ui.Picture picture = pictureRecorder.endRecording();
    ui.Image image = await picture.toImage(cropWidth.floor(), cropWidth.floor());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return MemoryImage(bytes.buffer.asUint8List());
  }

  @override
  void addTransition(CropImageData transition) {
    setState(() {
      data += transition;
      // For now, this will do. The idea is that we create
      // a path from the data and check if when we combine
      // that with the crop path that the resulting path
      // overlap the hole (crop). So we check if all pixels
      // from the crop contain pixels from the original image
      data.scale = data.scale.clamp(0.1, 10.0);
    });
  }

  @override
  void setData(CropImageData newData) {
    setState(() {
      data = newData;
      // The same check should happen (once available) as in addTransition
      data.scale = data.scale.clamp(0.1, 10.0);
    });
  }
}

enum CustomCropShape {
  Circle,
  Square,
}

Future<ByteData> computeToByteData(Map<String, dynamic> data) async {
  ui.PictureRecorder pictureRecorder = data['pictureRecorder'];
  double cropWidth = data['cropWidth'];
  ui.Picture picture = pictureRecorder.endRecording();
  ui.Image image = await picture.toImage(cropWidth.floor(), cropWidth.floor());
  return await image.toByteData(format: ui.ImageByteFormat.png);
}
