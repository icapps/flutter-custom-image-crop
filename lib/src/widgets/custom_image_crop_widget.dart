import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:custom_image_crop/src/calculators/calculate_crop_fit_params.dart';
import 'package:custom_image_crop/src/calculators/calculate_on_crop_params.dart';
import 'package:custom_image_crop/src/clippers/inverted_clipper.dart';
import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

/// An image cropper that is customizable.
/// You can rotate, scale and translate either
/// through gestures or a controller
class CustomImageCrop extends StatefulWidget {
  /// Output crop image size (357809764)
  final Size? cropOutSize;

  /// The image to crop
  final ImageProvider image;

  /// The controller that handles the cropping and
  /// changing of the cropping area
  final CustomImageCropController cropController;

  /// The color behind the cropping area
  final Color backgroundColor;

  /// The color in front of the cropped area
  final Color overlayColor;

  /// The shape of the cropping area.
  /// Possible values:
  /// - [CustomCropShape.Circle] Crop area will be circular.
  /// - [CustomCropShape.Square] Crop area will be a square.
  /// - [CustomCropShape.Ratio] Crop area will have a specified aspect ratio.
  final CustomCropShape shape;

  /// Ratio of the cropping area.
  /// If [shape] is set to [CustomCropShape.Ratio], this property is required.
  /// For example, to create a square crop area, use [Ratio(width: 1, height: 1)].
  /// To create a rectangular crop area with a 16:9 aspect ratio, use [Ratio(width: 16, height: 9)].
  final Ratio? ratio;

  /// How to fit image inside visible space
  final CustomImageFit imageFit;

  /// The percentage of the available area that is
  /// reserved for the cropping area
  final double cropPercentage;

  /// The path drawer of the border see [DottedCropPathPainter],
  /// [SolidPathPainter] for more details or how to implement a
  /// custom one
  final CustomPaint Function(Path, {Paint? pathPaint}) drawPath;

  /// Custom paint options for drawing the cropping border.
  ///
  /// If [paint] is provided, it will be used for customizing the appearance
  /// of the cropping border.
  ///
  /// If [paint] is not provided, default values will be used:
  /// - Color: [Colors.white]
  /// - Stle [PaintingStyle.stroke]
  /// - Stroke Join [StrokeJoin.round]
  /// - Stroke Width: 4.0
  final Paint? pathPaint;

  /// The radius for rounded corners of the cropping area (only applicable to rounded rectangle shapes).
  final double borderRadius;

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

  /// Whether to clip the area outside of the path when cropping
  /// By default, the value is `true`
  final bool clipShapeOnCrop;

  /// Whether image area must cover clip path
  /// By default, the value is `false`
  /// If use CustomCropShape.circle, the cropped image may have white blank.
  final bool forceInsideCropArea;

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
    this.shape = CustomCropShape.Circle,
    this.imageFit = CustomImageFit.fitCropSpace,
    this.cropPercentage = 0.8,
    this.drawPath = DottedCropPathPainter.drawPath,
    this.pathPaint,
    this.canRotate = true,
    this.canScale = true,
    this.canMove = true,
    this.clipShapeOnCrop = true,
    this.customProgressIndicator,
    this.ratio,
    this.borderRadius = 0,
    Paint? imagePaintDuringCrop,
    this.forceInsideCropArea = false,
    this.cropOutSize,
    Key? key,
  })  : this.imagePaintDuringCrop = imagePaintDuringCrop ??
            (Paint()..filterQuality = FilterQuality.high),
        assert(
          !(shape == CustomCropShape.Ratio && ratio == null),
          "If shape is set to Ratio, ratio should not be null.",
        ),
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

  @override
  void didUpdateWidget(CustomImageCrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _getImage();
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
        final cropFitParams = calculateCropFitParams(
          cropPercentage: widget.cropPercentage,
          imageFit: widget.imageFit,
          imageHeight: image.height,
          imageWidth: image.width,
          screenHeight: _height,
          screenWidth: _width,
          aspectRatio: (widget.ratio?.width ?? 1) / (widget.ratio?.height ?? 1),
        );
        final scale = data.scale * cropFitParams.additionalScale;
        _path = _getPath(
          cropWidth: cropFitParams.cropSizeWidth,
          cropHeight: cropFitParams.cropSizeHeight,
          width: _width,
          height: _height,
          borderRadius: widget.borderRadius,
        );
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
                widget.drawPath(_path, pathPaint: widget.pathPaint),
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
      widget.cropController.addTransition(
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

    widget.cropController
        .addTransition(CropImageData(x: event.delta.dx, y: event.delta.dy));
  }

  Rect _getInitialImageRect() {
    assert(_imageAsUIImage != null);
    final image = _imageAsUIImage!;
    final cropFitParams = calculateCropFitParams(
      cropPercentage: widget.cropPercentage,
      imageFit: widget.imageFit,
      imageHeight: image.height,
      imageWidth: image.width,
      screenHeight: _height,
      screenWidth: _width,
      aspectRatio: (widget.ratio?.width ?? 1) / (widget.ratio?.height ?? 1),
    );
    final initialWidth = _imageAsUIImage!.width * cropFitParams.additionalScale;
    final initialHeight =
        _imageAsUIImage!.height * cropFitParams.additionalScale;
    return Rect.fromLTWH(
      (_width - initialWidth) / 2,
      (_height - initialHeight) / 2,
      initialWidth,
      initialHeight,
    );
  }

  void _correctTransition(CropImageData transition, VoidCallback callback) {
    if (!widget.forceInsideCropArea || _imageAsUIImage == null) {
      callback();
      return;
    }
    final startX = data.x;
    final startY = data.y;
    callback();
    final pathRect = _path.getBounds();
    final initialImageRect = _getInitialImageRect();
    bool isContainPath = _isContainPath(initialImageRect, pathRect, data.scale);
    bool isRotated = data.angle != 0;

    if (isContainPath) {
      return;
    }

    if (transition.x != 0 || transition.y != 0) {
      if (isRotated) {
        _addTransitionInternal(
            CropImageData(x: startX - data.x, y: startY - data.y));
      } else {
        final imageRect = _getImageRect(initialImageRect, data.scale);
        double deltaX = min(pathRect.left - imageRect.left, 0);
        deltaX = pathRect.right > imageRect.right
            ? pathRect.right - imageRect.right
            : deltaX;
        double deltaY = min(pathRect.top - imageRect.top, 0);
        deltaY = pathRect.bottom > imageRect.bottom
            ? pathRect.bottom - imageRect.bottom
            : deltaY;
        _addTransitionInternal(CropImageData(x: deltaX, y: deltaY));
      }
      return;
    }
    double minEdgeHalf =
        min(initialImageRect.width, initialImageRect.height) / 2;
    double adaptScale = _calculateScaleAfterRotate(
        pathRect, data.scale, initialImageRect, minEdgeHalf);
    _addTransitionInternal(CropImageData(scale: adaptScale / data.scale));
  }

  Rect _getImageRect(Rect initialImageRect, double currentScale) {
    final diffScale = (1 - currentScale) / 2;
    final left =
        initialImageRect.left + diffScale * initialImageRect.width + data.x;
    final top =
        initialImageRect.top + diffScale * initialImageRect.height + data.y;
    Rect imageRect = Rect.fromLTWH(
        left,
        top,
        currentScale * initialImageRect.width,
        currentScale * initialImageRect.height);
    return imageRect;
  }

  double _getDistanceBetweenPointAndLine(
      Offset point, Offset lineStart, Offset lineEnd) {
    if (lineEnd.dy == lineStart.dy) {
      return (point.dy - lineStart.dy).abs();
    }
    if (lineEnd.dx == lineStart.dx) {
      return (point.dx - lineStart.dx).abs();
    }
    double line1Slop =
        (lineEnd.dy - lineStart.dy) / (lineEnd.dx - lineStart.dx);
    double line1Delta = lineEnd.dy - lineEnd.dx * line1Slop;
    double line2Slop = -1 / line1Slop;
    double line2Delta = point.dy - point.dx * line2Slop;
    double crossPointX = (line2Delta - line1Delta) / (line1Slop - line2Slop);
    double crossPointY = line1Slop * crossPointX + line1Delta;
    return (Offset(crossPointX, crossPointY) - point).distance;
  }

  bool _isContainPath(
      Rect initialImageRect, Rect pathRect, double currentScale) {
    final imageRect = _getImageRect(initialImageRect, currentScale);
    Offset topLeft, topRight, bottomLeft, bottomRight;
    final rad = atan(imageRect.height / imageRect.width);
    final len =
        sqrt(pow(imageRect.width / 2, 2) + pow(imageRect.height / 2, 2));
    bool isRotated = data.angle != 0;

    if (isRotated) {
      final clockAngle = rad + data.angle;
      final counterClockAngle = rad - data.angle;
      final cosClockValue = len * cos(clockAngle);
      final sinClockValue = len * sin(clockAngle);
      final cosCounterClockValue = len * cos(counterClockAngle);
      final sinCounterClockValue = len * sin(counterClockAngle);
      bottomRight = imageRect.center.translate(cosClockValue, sinClockValue);
      topRight = imageRect.center
          .translate(cosCounterClockValue, -sinCounterClockValue);
      topLeft = imageRect.center.translate(-cosClockValue, -sinClockValue);
      bottomLeft = imageRect.center
          .translate(-cosCounterClockValue, sinCounterClockValue);
    } else {
      bottomRight = imageRect.bottomRight;
      topRight = imageRect.topRight;
      topLeft = imageRect.topLeft;
      bottomLeft = imageRect.bottomLeft;
    }

    if (widget.shape == CustomCropShape.Circle) {
      final anchor = max(pathRect.width, pathRect.height) / 2;
      final pathCenter = pathRect.center;
      return _getDistanceBetweenPointAndLine(pathCenter, topLeft, topRight) >=
              anchor &&
          _getDistanceBetweenPointAndLine(pathCenter, topRight, bottomRight) >=
              anchor &&
          _getDistanceBetweenPointAndLine(
                  pathCenter, bottomLeft, bottomRight) >=
              anchor &&
          _getDistanceBetweenPointAndLine(pathCenter, topLeft, bottomLeft) >=
              anchor;
    }

    if (isRotated) {
      Path imagePath = Path()
        ..moveTo(topLeft.dx, topLeft.dy)
        ..lineTo(topRight.dx, topRight.dy)
        ..lineTo(bottomRight.dx, bottomRight.dy)
        ..lineTo(bottomLeft.dx, bottomLeft.dy)
        ..close();
      return imagePath.contains(pathRect.topLeft) &&
          imagePath.contains(pathRect.topRight) &&
          imagePath.contains(pathRect.bottomLeft) &&
          imagePath.contains(pathRect.bottomRight);
    } else {
      return imageRect.contains(pathRect.topLeft) &&
          imageRect.contains(pathRect.topRight) &&
          imageRect.contains(pathRect.bottomLeft) &&
          imageRect.contains(pathRect.bottomRight);
    }
  }

  double _calculateScaleAfterRotate(Rect pathRect, double startScale,
      Rect initialImageRect, double minEdgeHalf) {
    final imageCenter = initialImageRect.center.translate(data.x, data.y);
    final topLeftDistance = (pathRect.topLeft - imageCenter).distance;
    final topRightDistance = (pathRect.topRight - imageCenter).distance;
    final bottomLeftDistance = (pathRect.bottomLeft - imageCenter).distance;
    final bottomRightDistance = (pathRect.bottomRight - imageCenter).distance;
    final maxDistance = max(
        max(max(topLeftDistance, topRightDistance), bottomLeftDistance),
        bottomRightDistance);
    double endScale = maxDistance / minEdgeHalf;

    if (startScale >= endScale) {
      return endScale;
    }

    ///use binary search to find best scale which just contain path.
    ///Also, we can use imageCenter、imageLine(longest one) and path vertex to calculate.
    double step = 1 / minEdgeHalf;

    while ((endScale - startScale).abs() > step) {
      double midScale = (endScale + startScale) / 2;

      if (_isContainPath(initialImageRect, pathRect, midScale)) {
        endScale = midScale;
      } else {
        startScale = midScale + step;
      }
    }
    return endScale;
  }

  Path _getPath({
    required double cropWidth,
    required double cropHeight,
    required double width,
    required double height,
    required double borderRadius,
    bool clipShape = true,
  }) {
    if (!clipShape) {
      return Path()
        ..addRect(
          Rect.fromCenter(
            center: Offset(width / 2, height / 2),
            width: cropWidth,
            height: cropHeight,
          ),
        );
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
      case CustomCropShape.Ratio:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(width / 2, height / 2),
                width: cropWidth,
                height: cropHeight,
              ),
              Radius.circular(borderRadius),
            ),
          );
      default:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(width / 2, height / 2),
                width: cropWidth,
                height: cropHeight,
              ),
              Radius.circular(borderRadius),
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
      aspectRatio: (widget.ratio?.width ?? 1) / (widget.ratio?.height ?? 1),
    );
    final clipPath = Path.from(_getPath(
      cropWidth: onCropParams.cropSizeWidth,
      cropHeight: onCropParams.cropSizeHeight,
      width: onCropParams.cropSizeWidth,
      height: onCropParams.cropSizeHeight,
      borderRadius: widget.borderRadius,
      clipShape: widget.clipShapeOnCrop,
    ));
    final matrix4Image = Matrix4.diagonal3(vector_math.Vector3.all(1))
      ..translate(
        onCropParams.translateScale * data.x + onCropParams.cropSizeWidth / 2,
        onCropParams.translateScale * data.y + onCropParams.cropSizeHeight / 2,
      )
      ..scale(onCropParams.scale)
      ..rotateZ(data.angle);
    final bgPaint = Paint()
      ..color = widget.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        onCropParams.cropSizeWidth,
        onCropParams.cropSizeHeight,
      ),
      bgPaint,
    );
    canvas.save();

    if (widget.cropOutSize != null) {
      Matrix4 mat1 = Matrix4.diagonal3(vector_math.Vector3.all(1))
        ..scale(widget.cropOutSize!.width / onCropParams.cropSizeWidth,
            widget.cropOutSize!.height / onCropParams.cropSizeHeight);
      canvas.transform(mat1.storage);
    }

    canvas.clipPath(clipPath);
    canvas.transform(matrix4Image.storage);
    canvas.drawImage(
      _imageAsUIImage!,
      Offset(-imageWidth / 2, -imageHeight / 2),
      widget.imagePaintDuringCrop,
    );
    canvas.restore();

    // Optionally remove magenta from image by evaluating every pixel
    // See https://github.com/brendan-duncan/image/blob/master/lib/src/transform/copy_crop.dart

    // final bytes = await compute(computeToByteData, <String, dynamic>{'pictureRecorder': pictureRecorder, 'cropWidth': cropWidth});

    ui.Picture picture = pictureRecorder.endRecording();
    ui.Image image = await picture.toImage(
      widget.cropOutSize?.width.floor() ?? onCropParams.cropSizeWidth.floor(),
      widget.cropOutSize?.height.floor() ?? onCropParams.cropSizeHeight.floor(),
    );

    // Adding compute would be preferrable. Unfortunately we cannot pass an ui image to this.
    // A workaround would be to save the image and load it inside of the isolate
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes == null ? null : MemoryImage(bytes.buffer.asUint8List());
  }

  void _addTransitionInternal(CropImageData transition) {
    setData(data + transition);
  }

  @override
  void addTransition(CropImageData transition) {
    _correctTransition(transition, () {
      _addTransitionInternal(transition);
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
  Ratio,
}

enum CustomImageFit {
  fillCropSpace,
  fitCropSpace,
  fillCropWidth,
  fillCropHeight,
  fitVisibleSpace,
  fillVisibleSpace,
  fillVisibleHeight,
  fillVisibleWidth,
}
