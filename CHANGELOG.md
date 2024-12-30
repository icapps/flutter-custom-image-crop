## [0.1.1] - 2024-12-30

- Fixed issues with imagefit and forceInsideCropArea resulting in crops outside the crop area and/or wrong crops

## [0.1.0] - 2024-12-30

- Added maskShape so you can crop using a different mask than for visualisation (e.g. circle mask for visualisation, but square mask for cropping)
- Added imageFilter and imageFilterBlendMode so you can add filters like blur the image outside the crop area (for example ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0))
- Fixed issue with aspectratio < 1 resulting in a to big cropSizeHeight
- [Possibly breaking] Added outlineStrokeWidth and outlineColor to CustomImageCrop to customize the outline of the crop shape, if you provided custom drawPath method, you will need to add these to the method, but you do not need to use them if you don't want to customize the outline from the CustomImageCrop widget

## [0.0.13] - 2023-10-26

- Added forceInsideCropArea, whether image area must cover clip path. Default is false

## [0.0.12] - 2023-09-08

- Fixed issues with Ratio and CustomImageCrop
- Added fillCropSpace as CustomImageFit

## [0.0.11] - 2023-09-01

- Added clipShapeOnCrop to prevent clipping the image to the crop shape

## [0.0.10] - 2023-08-17

- Added didupdateWidget check to fix issues with updated images

## [0.0.9] - 2023-08-10

- Added borderRadius

## [0.0.8] - 2023-08-10

- Added pathPaint to customize the crop border style

## [0.0.7] - 2023-08-09

- Added Ratio as new shape and arguments

## [0.0.6]

- Added new param to CustomImageCrop for new image fit types

## [0.0.5]

- Added canRotate
- Added customProgressIndicator
- Added canScale
- Added canMove

## [0.0.4]

- Added documentation

## [0.0.3]

- Fixed issue where cropped image's size depends on screen size used
- Fixed issue where cropped image's quality is worse than original image
- Updated to flutter 2.8.0

## [0.0.2]

- Updated docs

## [0.0.1]

- Added custom crop
- Added Cicrle and Square crop shapes
- Added Solid and Dotted painters for crop border
