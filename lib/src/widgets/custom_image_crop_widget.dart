import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import 'package:custom_image_crop/src/controllers/controller.dart';
import 'package:custom_image_crop/src/painters/dotted_path_painter.dart';
import 'package:custom_image_crop/src/clippers/inverted_clipper.dart';
import 'package:custom_image_crop/src/models/model.dart';
import 'package:custom_image_crop/src/calculators/calculate_crop_params.dart';
import 'package:custom_image_crop/src/calculators/calculate_on_crop_params.dart';

/// An image cropper that is customizable.
/// You can rotate, scale and translate either
/// through gestures or a controller
class CustomImageCrop extends StatefulWidget {
  /// The image to crop
  final ImageProvider image;

  /// The controller that handles the cropping and
  /// changing of the cropping area
  final CustomImageCropController cropController;

  /// The color behind the cropping area
  final Color backgroundColor;

  /// The color in front of the cropped area
  final Color overlayColor;

  /// The shape of the cropping area
  final CustomCropShape shape;

  /// How to fit image inside visible space
  final CustomImageFit imageFit;

  /// The percentage of the available area that is
  /// reserved for the cropping area
  final double cropPercentage;

  /// The path drawer of the border see [DottedCropPathPainter],
  /// [SolidPathPainter] for more details or how to implement a
  /// custom one
  final CustomPaint Function(Path) drawPath;

  /// Whether to allow the image to be rotated.
  final bool canRotate;

  /// Determines whether scaling gesture is disabled.
  ///
  /// By default, scaling is enabled.
  /// Set [canScale] to `false` to disable scaling.
  final bool canScale;

  /// Determines whether moving gesture overlay is disabled.
  ///
  /// By default, moving is enabled.
  /// Set [canMove] to `false` to disable move.
  final bool canMove;

  /// The paint used when drawing an image before cropping
  final Paint imagePaintDuringCrop;

  /// This widget is used to specify a custom progress indicator
  final Widget? customProgressIndicator;

  /// Allows to clips the area outside of the path
  /// By default `false`
  final bool clipToShape;

  /// A custom image cropper widget
  ///
  /// Uses a `CustomImageCropController` to crop the image.
  /// With the controller you can rotate, translate and/or
  /// scale with buttons and sliders. This can also be
  /// achieved with gestures
  ///
  /// Use a `shape` with `CustomCropShape.Circle` or
  /// `CustomCropShape.Square`
  ///
  /// You can increase the cropping area using `cropPercentage`
  ///
  /// Change the cropping border by changing `drawPath`,
  /// we've provided two default painters as inspiration
  /// `DottedCropPathPainter.drawPath` and
  /// `SolidCropPathPainter.drawPath`
  CustomImageCrop({
    required this.image,
    required this.cropController,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.backgroundColor = Colors.white,
    this.shape = CustomCropShape.circle,
    this.imageFit = CustomImageFit.fitCropSpace,
    this.cropPercentage = 0.8,
    this.drawPath = DottedCropPathPainter.drawPath,
    this.canRotate = true,
    this.canScale = true,
    this.canMove = true,
    this.clipToShape = false,
    this.customProgressIndicator,
    Paint? imagePaintDuringCrop,
    Key? key,
  })  : this.imagePaintDuringCrop = imagePaintDuringCrop ??
            (Paint()..filterQuality = FilterQuality.high),
        super(key: key);

  @override
  _CustomImageCropState createState() => _CustomImageCropState();
}

class _CustomImageCropState extends State<CustomImageCrop>
    with CustomImageCropListener {
  CropImageData? _dataTransitionStart;
  late Path _path;
  late double _width, _height;
  ui.Image? _imageAsUIImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    widget.cropController.addListener(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  void _getImage() {
    final oldImageStream = _imageStream;
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    if (_imageStream?.key != oldImageStream?.key) {
      if (_imageListener != null) {
        oldImageStream?.removeListener(_imageListener!);
      }
      _imageListener = ImageStreamListener(_updateImage);
      _imageStream?.addListener(_imageListener!);
    }
  }

  void _updateImage(ImageInfo imageInfo, _) {
    setState(() {
      _imageAsUIImage = imageInfo.image;
    });
  }

  @override
  void dispose() {
    if (_imageListener != null) {
      _imageStream?.removeListener(_imageListener!);
    }
    widget.cropController.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _imageAsUIImage;
    if (image == null) {
      return Center(
        child: widget.customProgressIndicator ?? CircularProgressIndicator(),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        _height = constraints.maxHeight;
        final cropParams = calculateCropParams(
          cropPercentage: widget.cropPercentage,
          imageFit: widget.imageFit,
          imageHeight: image.height,
          imageWidth: image.width,
          screenHeight: _height,
          screenWidth: _width,
        );
        final scale = data.scale * cropParams.additionalScale;
        _path = _getPath(cropParams.cropSizeToPaint, _width, _height);
        return XGestureDetector(
          onMoveStart: onMoveStart,
          onMoveUpdate: onMoveUpdate,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          child: Container(
            width: _width,
            height: _height,
            color: widget.backgroundColor,
            child: Stack(
              children: [
                Positioned(
                  left: data.x + _width / 2,
                  top: data.y + _height / 2,
                  child: Transform(
                    transform: Matrix4.diagonal3(
                        vector_math.Vector3(scale, scale, scale))
                      ..rotateZ(data.angle)
                      ..translate(-image.width / 2, -image.height / 2),
                    child: Image(
                      image: widget.image,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: ClipPath(
                    clipper: InvertedClipper(_path, _width, _height),
                    child: Container(
                      color: widget.overlayColor,
                    ),
                  ),
                ),
                widget.drawPath(_path),
              ],
            ),
          ),
        );
      },
    );
  }

  void onScaleStart(_) {
    _dataTransitionStart = null; // Reset for update
  }

  void onScaleUpdate(ScaleEvent event) {
    final scale =
        widget.canScale ? event.scale : (_dataTransitionStart?.scale ?? 1.0);

    final angle = widget.canRotate ? event.rotationAngle : 0.0;

    if (_dataTransitionStart != null) {
      addTransition(
        _dataTransitionStart! -
            CropImageData(
              scale: scale,
              angle: angle,
            ),
      );
    }
    _dataTransitionStart = CropImageData(
      scale: scale,
      angle: angle,
    );
  }

  void onMoveStart(_) {
    _dataTransitionStart = null; // Reset for update
  }

  void onMoveUpdate(MoveEvent event) {
    if (!widget.canMove) return;

    addTransition(CropImageData(x: event.delta.dx, y: event.delta.dy));
  }

  Path _getPath(double cropWidth, double width, double height) {
    switch (widget.shape) {
      case CustomCropShape.circle:
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

  Path _getSavePath(double cropWidth, double width, double height) {
    if (widget.shape == CustomCropShape.circle && widget.clipToShape) {
      return Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(width / 2, height / 2),
            radius: cropWidth / 2,
          ),
        );
    } else {
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
  Future<MemoryImage?> onCropImage() async {
    if (_imageAsUIImage == null) {
      return null;
    }
    final imageWidth = _imageAsUIImage!.width;
    final imageHeight = _imageAsUIImage!.height;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final onCropParams = caclulateOnCropParams(
      cropPercentage: widget.cropPercentage,
      imageFit: widget.imageFit,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      screenHeight: _height,
      screenWidth: _width,
      dataScale: data.scale,
    );
    final clipPath = Path.from(_getSavePath(
        onCropParams.cropSize, onCropParams.cropSize, onCropParams.cropSize));
    final matrix4Image = Matrix4.diagonal3(vector_math.Vector3.all(1))
      ..translate(
          onCropParams.translateScale * data.x + onCropParams.cropSize / 2,
          onCropParams.translateScale * data.y + onCropParams.cropSize / 2)
      ..scale(onCropParams.scale)
      ..rotateZ(data.angle);
    final bgPaint = Paint()
      ..color = widget.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, onCropParams.cropSize, onCropParams.cropSize),
        bgPaint);
    canvas.save();
    canvas.clipPath(clipPath);
    canvas.transform(matrix4Image.storage);
    canvas.drawImage(_imageAsUIImage!,
        Offset(-imageWidth / 2, -imageHeight / 2), widget.imagePaintDuringCrop);
    canvas.restore();

    // Optionally remove magenta from image by evaluating every pixel
    // See https://github.com/brendan-duncan/image/blob/master/lib/src/transform/copy_crop.dart

    // final bytes = await compute(computeToByteData, <String, dynamic>{'pictureRecorder': pictureRecorder, 'cropWidth': cropWidth});

    ui.Picture picture = pictureRecorder.endRecording();
    ui.Image image = await picture.toImage(
        onCropParams.cropSize.floor(), onCropParams.cropSize.floor());

    // Adding compute would be preferrable. Unfortunately we cannot pass an ui image to this.
    // A workaround would be to save the image and load it inside of the isolate
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes == null ? null : MemoryImage(bytes.buffer.asUint8List());
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
  circle,
  square,
}

enum CustomImageFit {
  fitCropSpace,
  fillCropWidth,
  fillCropHeight,
  fitVisibleSpace,
  fillVisibleSpace,
  fillVisibleHeight,
  fillVisiblelWidth,
}
