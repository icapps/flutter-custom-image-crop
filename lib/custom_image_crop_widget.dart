import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:custom_image_crop/controller.dart';
import 'package:custom_image_crop/model.dart';
import 'package:custom_image_crop/inverted_clipper.dart';
import 'package:custom_image_crop/dotted_path_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

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
    this.shape = CustomCropShape.Square,
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
    // getUiImage(widget.image);
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

  // Future<void> getUiImage(ImageProvider imageProvide) async {
  //   Completer<ImageInfo> completer = Completer();
  //   imageProvide.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
  //     completer.complete(info);
  //   }));
  //   ImageInfo imageInfo = await completer.future;
  //   final ByteData assetImageByteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  //   final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(assetImageByteData.buffer.asUint8List());
  //   final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(buffer);
  //   ui.Codec codec = await descriptor.instantiateCodec();
  //   ui.FrameInfo frameInfo = await codec.getNextFrame();
  //   imageAsUIImage = frameInfo.image;
  // }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageListener);
    controller?.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final cropWidth = min(width, height) * widget.cropPercentage;
    if (imageAsUIImage == null) {
      return Center(child: CircularProgressIndicator());
    }
    final defaultScale = min(imageAsUIImage.width / cropWidth, imageAsUIImage.height / cropWidth);
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
                  ..translate(-width / 2, -height / 2),
                child: Container(
                  width: width,
                  height: height,
                  child: Center(
                    child: Image(
                      image: widget.image,
                      fit: BoxFit.contain,
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
  Future<MemoryImage> onCropImage() async {
    if (imageAsUIImage == null) {
      return null;
    }
    final cropWidth = (min(width, height) * widget.cropPercentage).floor();
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    // final matrix4Clip = Matrix4.diagonal3(vector_math.Vector3.all(1))..translate(cropWidth / 2, cropWidth / 2);
    final clipPath = Path.from(path); //..transform(matrix4Clip.storage);
    final defaultScale = min(imageAsUIImage.width / cropWidth, imageAsUIImage.height / cropWidth);
    final scale = data.scale * defaultScale / 2;
    final matrix4Image = Matrix4.diagonal3(vector_math.Vector3(1, 1, 0))
      ..translate(data.x + cropWidth / 2, data.y + cropWidth / 2)
      ..scale(scale)
      ..rotateZ(data.angle);
    // ..translate(data.x + cropWidth / 2, data.y + cropWidth / 2);
    final bgPaint = Paint()
      ..color = widget.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropWidth.toDouble()), bgPaint);
    canvas.save();
    final paint = Paint()..isAntiAlias = false;
    print('$data');
    canvas.transform(matrix4Image.storage);
    canvas.drawImage(imageAsUIImage, Offset(-imageAsUIImage.width / 2, -imageAsUIImage.height / 2), paint);
    // canvas.clipPath(clipPath);
    canvas.restore();
    ui.Picture picture = pictureRecorder.endRecording();
    ui.Image image = await picture.toImage(cropWidth, cropWidth);

    // Optionally remove magenta from image by evaluating every pixel
    // See https://github.com/brendan-duncan/image/blob/master/lib/src/transform/copy_crop.dart

    ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return MemoryImage(bytes.buffer.asUint8List());
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
    data.scale = data.scale.clamp(0.1, 10.0);
    return true;
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
