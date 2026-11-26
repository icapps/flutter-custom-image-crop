import 'dart:math';
import 'dart:ui' as ui;

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Size of the crop widget in every test. With the default cropPercentage
/// of 0.8, square and circle crop areas are 320 x 320, and a 1200 x 800
/// image is shown at 480 x 320 when the scale is 1.
const _widgetSize = Size(400, 400);

/// Serves an already decoded image synchronously, so tests do not have to
/// wait for real image decoding.
class _TestImageProvider extends ImageProvider<_TestImageProvider> {
  _TestImageProvider(this.image);

  final ui.Image image;

  @override
  Future<_TestImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_TestImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    _TestImageProvider key,
    ImageDecoderCallback decode,
  ) =>
      OneFrameImageStreamCompleter(
        SynchronousFuture<ImageInfo>(ImageInfo(image: image.clone())),
      );
}

class _CropSetup {
  const _CropSetup(
    this.description, {
    required this.imageWidth,
    required this.imageHeight,
    required this.shape,
    required this.cropSize,
    this.ratio,
  });

  final String description;
  final int imageWidth;
  final int imageHeight;
  final CustomCropShape shape;
  final Ratio? ratio;

  /// The crop area the widget is expected to draw for [_widgetSize].
  final Size cropSize;
}

Future<CustomImageCropController> _pumpCrop(
  WidgetTester tester,
  _CropSetup setup, {
  bool forceInsideCropArea = true,
}) async {
  final image = await tester.runAsync(
    () => createTestImage(width: setup.imageWidth, height: setup.imageHeight),
  );
  final controller = CustomImageCropController();
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox.fromSize(
          size: _widgetSize,
          child: CustomImageCrop(
            image: _TestImageProvider(image!),
            cropController: controller,
            shape: setup.shape,
            ratio: setup.ratio,
            forceInsideCropArea: forceInsideCropArea,
          ),
        ),
      ),
    ),
  );
  return controller;
}

Future<void> _addTransition(
  WidgetTester tester,
  CustomImageCropController controller,
  CropImageData transition,
) async {
  controller.addTransition(transition);
  await tester.pump();
}

/// Checks, against the image as it is actually rendered, that every point
/// on the outline of the crop area lies on the image.
void _expectCropAreaCovered(WidgetTester tester, _CropSetup setup) {
  final imageBox = tester.renderObject<RenderBox>(find.byType(RawImage));
  final center = tester.getCenter(find.byType(CustomImageCrop));
  final halfWidth = setup.cropSize.width / 2;
  final halfHeight = setup.cropSize.height / 2;

  final outline = <Offset>[];
  if (setup.shape == CustomCropShape.Circle) {
    for (var degrees = 0; degrees < 360; degrees++) {
      final radians = degrees * pi / 180;
      outline.add(center + Offset(cos(radians), sin(radians)) * halfWidth);
    }
  } else {
    outline.addAll([
      center + Offset(-halfWidth, -halfHeight),
      center + Offset(halfWidth, -halfHeight),
      center + Offset(halfWidth, halfHeight),
      center + Offset(-halfWidth, halfHeight),
    ]);
  }

  // Allows for floating point rounding only, far below one pixel.
  const tolerance = 1e-6;
  for (final point in outline) {
    final local = imageBox.globalToLocal(point);
    final reason = 'crop area point $point lies outside the image';
    expect(
      local.dx,
      inInclusiveRange(-tolerance, imageBox.size.width + tolerance),
      reason: reason,
    );
    expect(
      local.dy,
      inInclusiveRange(-tolerance, imageBox.size.height + tolerance),
      reason: reason,
    );
  }
}

const _landscapeSquare = _CropSetup(
  'square crop, landscape image',
  imageWidth: 1200,
  imageHeight: 800,
  shape: CustomCropShape.Square,
  cropSize: Size(320, 320),
);

const _portraitSquare = _CropSetup(
  'square crop, portrait image',
  imageWidth: 800,
  imageHeight: 1200,
  shape: CustomCropShape.Square,
  cropSize: Size(320, 320),
);

const _landscapeCircle = _CropSetup(
  'circle crop, landscape image',
  imageWidth: 1200,
  imageHeight: 800,
  shape: CustomCropShape.Circle,
  cropSize: Size(320, 320),
);

final _wideRatio = _CropSetup(
  '16:9 crop, landscape image',
  imageWidth: 1200,
  imageHeight: 800,
  shape: CustomCropShape.Ratio,
  ratio: Ratio(width: 16, height: 9),
  cropSize: Size(320, 180),
);

final _tallRatio = _CropSetup(
  '3:4 crop, portrait image',
  imageWidth: 800,
  imageHeight: 1200,
  shape: CustomCropShape.Ratio,
  ratio: Ratio(width: 3, height: 4),
  cropSize: Size(240, 320),
);

void main() {
  group('forceInsideCropArea', () {
    testWidgets(
        'zooming out after panning to an edge shrinks the image '
        'to the smallest scale that covers the crop area', (tester) async {
      final controller = await _pumpCrop(tester, _landscapeSquare);

      await _addTransition(tester, controller, CropImageData(scale: 3));
      await _addTransition(tester, controller, CropImageData(x: 5000, y: 5000));
      for (var i = 0; i < 30; i++) {
        await _addTransition(tester, controller, CropImageData(scale: 0.9));
      }

      final data = controller.cropImageData!;
      expect(data.scale, closeTo(1, 1e-9));
      // The image's left edge rests on the crop area's left edge.
      expect(data.x, closeTo(80, 1e-9));
      expect(data.y, closeTo(0, 1e-9));
      _expectCropAreaCovered(tester, _landscapeSquare);
    });

    testWidgets('panning stops where the image edge meets the crop edge',
        (tester) async {
      final controller = await _pumpCrop(tester, _landscapeSquare);

      await _addTransition(tester, controller, CropImageData(x: 5000));
      expect(controller.cropImageData!.x, closeTo(80, 1e-9));

      await _addTransition(tester, controller, CropImageData(x: -10000));
      expect(controller.cropImageData!.x, closeTo(-80, 1e-9));

      await _addTransition(tester, controller, CropImageData(y: 5000));
      expect(controller.cropImageData!.y, closeTo(0, 1e-9));
      expect(controller.cropImageData!.scale, 1);
    });

    testWidgets(
        'rotating enlarges the image only as much as '
        'the rotated crop area needs', (tester) async {
      final controller = await _pumpCrop(tester, _landscapeSquare);

      await _addTransition(tester, controller, CropImageData(angle: pi / 4));

      // A 320 x 320 crop area turned 45 degrees spans 320 * sqrt(2) in
      // image space, and the image is 320 high at scale 1.
      final data = controller.cropImageData!;
      expect(data.scale, closeTo(sqrt2, 1e-9));
      expect(data.x, closeTo(0, 1e-9));
      expect(data.y, closeTo(0, 1e-9));
      _expectCropAreaCovered(tester, _landscapeSquare);
    });

    testWidgets('a circle crop area cannot be panned off the image',
        (tester) async {
      final controller = await _pumpCrop(tester, _landscapeCircle);

      await _addTransition(tester, controller, CropImageData(x: 5000, y: 3000));

      expect(controller.cropImageData!.x, closeTo(80, 1e-9));
      expect(controller.cropImageData!.y, closeTo(0, 1e-9));
      _expectCropAreaCovered(tester, _landscapeCircle);
    });

    for (final setup in [
      _landscapeSquare,
      _portraitSquare,
      _landscapeCircle,
      _wideRatio,
      _tallRatio,
    ]) {
      testWidgets(
          'the image keeps covering the crop area while panning, zooming '
          'and rotating (${setup.description})', (tester) async {
        final controller = await _pumpCrop(tester, setup);
        final random = Random(1);

        for (var step = 0; step < 1000; step++) {
          final CropImageData transition;
          switch (random.nextInt(3)) {
            case 0:
              transition = CropImageData(
                x: (random.nextDouble() - 0.5) * 300,
                y: (random.nextDouble() - 0.5) * 300,
              );
              break;
            case 1:
              transition =
                  CropImageData(scale: 0.7 + random.nextDouble() * 0.6);
              break;
            default:
              transition = CropImageData(
                angle: (random.nextDouble() - 0.5) * 0.6,
              );
          }
          await _addTransition(tester, controller, transition);
          _expectCropAreaCovered(tester, setup);
        }
      });
    }
  });

  testWidgets('without forceInsideCropArea, transitions are applied unchanged',
      (tester) async {
    final controller = await _pumpCrop(
      tester,
      _landscapeSquare,
      forceInsideCropArea: false,
    );

    await _addTransition(
      tester,
      controller,
      CropImageData(x: 5000, y: -5000, scale: 0.2, angle: 1),
    );

    final data = controller.cropImageData!;
    expect(data.x, 5000);
    expect(data.y, -5000);
    expect(data.scale, 0.2);
    expect(data.angle, 1);
  });
}
