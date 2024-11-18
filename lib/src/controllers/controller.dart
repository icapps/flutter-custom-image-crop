import 'package:custom_image_crop/src/models/model.dart';
import 'package:flutter/material.dart';

/// The controller that handles the cropping and
/// changing of the cropping area
class CustomImageCropController {
  /// Listener for the cropping area changes
  final listeners = <CustomImageCropListener>[];

  /// Crop the image
  Future<MemoryImage?> onCropImage({Size? outSize}) =>
      listeners.map((e) => e.onCropImage(outSize: outSize)).first;

  /// The data that handles the transformation of the cropped image.
  CropImageData? get cropImageData => listeners.map((e) => e.data).first;

  /// Add a new listener for the cropping area changes
  void addListener(CustomImageCropListener listener) => listeners.add(listener);

  /// Remove a listener for the cropping area changes
  void removeListener(CustomImageCropListener listener) =>
      listeners.remove(listener);

  /// Notify all listeners for the cropping area changes
  void notifyListeners() => addTransition(CropImageData());

  void dispose() => listeners.clear();

  /// Move the cropping area using the given translation
  void addTransition(CropImageData transition) =>
      listeners.forEach((e) => e.addTransition(transition));

  /// Reset the cropping area
  void reset() => setData(CropImageData());

  /// Update the cropping area
  void setData(CropImageData data) => listeners.forEach((e) => e.setData(data));
}

mixin CustomImageCropListener {
  /// The data that handles the transformation of the cropped image.
  var data = CropImageData(scale: 1);

  /// Move the cropping area using the given translation
  void addTransition(CropImageData transition);

  /// Update the cropping area
  void setData(CropImageData transition);

  /// Crop the image
  Future<MemoryImage?> onCropImage({Size? outSize});
}
