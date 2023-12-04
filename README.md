# custom_image_crop

An Image cropper that is customizable

[![pub package](https://img.shields.io/pub/v/custom_image_crop.svg)](https://pub.dartlang.org/packages/custom_image_crop)
[![Build Status](https://app.travis-ci.com/icapps/flutter-custom-image-crop.svg?branch=main)](https://app.travis-ci.com/icapps/flutter-custom-image-crop)
[![Coverage Status](https://coveralls.io/repos/github/icapps/flutter-custom-image-crop/badge.svg?branch=main)](https://coveralls.io/github/icapps/flutter-custom-image-crop?branch=main)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

<img src="https://github.com/icapps/flutter-custom-image-crop/blob/main/example/screenshots/customimagecrop.gif?raw=true" alt="customcropcircle" height="320"/> <img src="https://github.com/icapps/flutter-custom-image-crop/blob/main/example/screenshots/customcropsquare.png?raw=true" alt="customcropsquare" height="320"/> <img src="https://github.com/icapps/flutter-custom-image-crop/blob/main/example/screenshots/customcropcircle.png?raw=true" alt="customcropcircle" height="320"/>

# CustomImageCrop

```dart
CustomImageCrop(
  cropController: controller,
  image: const AssetImage('assets/test.png'),
),
```

You can provide the image using any Imageprovider.

## Parameters

### required image

The image that needs to be cropped

### cropController

The controller used to adjust the image and crop it.

### overlayColor

The color above the image that will be cropped

### backgroundColor

The color behind the image. This color will also be used when there are gaps/empty space after the cropping

### shape

The shape of the cropping path.

### maskShape

The shape of the UI masking.

### cropPercentage

How big the crop should be in regards to the width and height available to the cropping widget.

### drawPath

How the border of the crop should be painted. default DottedCropPathPainter.drawPath and SolidCropPathPainter.drawPath are provided, but you can create/provide any CustomPaint.

### pathPaint
Custom painting for the crop area border style.

### canRotate

Whether to allow the image to be rotated.

### customProgressIndicator

Custom widget for progress indicator.

### ratio

Ratio of the cropping area.
If ` shape`` is set to  `CustomCropShape.Ratio`, this property is required.
For example, to create a square crop area, use `[`Ratio(width: 1, height: 1)`.
To create a rectangular crop area with a 16:9 aspect ratio, use `[`Ratio(width: 16, height: 9)`.

### borderRadius
The radius for rounded corners of the cropping area.

### forceInsideCropArea
Whether image area must cover clip path.


# Controller Methods

## addTransition

`void addTransition(CropImageData transition)`

Add the position, angle and scale to the current state. This can be used to adjust the image with sliders, buttons, etc.

## setData

`void setData(CropImageData data)`

Set the position, angle and scale to the specified values. This can be used to center the image by pressing a button for example.

## reset

`void reset()`

Reset the image to its default state

## onCropImage

`Future<MemoryImage> onCropImage()`

Crops the image in its current state, this will return a MemoryImage that contains the cropped image

# Example

See example/lib

```dart
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CustomImageCropController controller;

  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        brightness: Brightness.dark,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomImageCrop(
              cropController: controller,
              image: const AssetImage('assets/test.png'), // Any Imageprovider will work, try with a NetworkImage for example...
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: controller.reset),
              IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => controller.addTransition(CropImageData(scale: 1.33))),
              IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => controller.addTransition(CropImageData(scale: 0.75))),
              IconButton(icon: const Icon(Icons.rotate_left), onPressed: () => controller.addTransition(CropImageData(angle: -pi / 4))),
              IconButton(icon: const Icon(Icons.rotate_right), onPressed: () => controller.addTransition(CropImageData(angle: pi / 4))),
              IconButton(
                icon: const Icon(Icons.crop),
                onPressed: () async {
                  final image = await controller.onCropImage();
                  if (image != null) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ResultScreen(image: image)));
                  }
                },
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
```
