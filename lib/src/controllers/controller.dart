import 'package:custom_image_crop/src/models/model.dart';
import 'package:flutter/material.dart';

class CustomImageCropController {
  final listeners = <CustomImageCropListener>[];

  Future<MemoryImage?> onCropImage() =>
      listeners.map((e) => e.onCropImage()).first;

  CropImageData? get cropImageData => listeners.map((e) => e.data).first;

  void addListener(CustomImageCropListener listener) => listeners.add(listener);

  void removeListener(CustomImageCropListener listener) =>
      listeners.remove(listener);

  void notifyListeners() => addTransition(CropImageData());

  void dispose() => listeners.clear();

  void addTransition(CropImageData transition) =>
      listeners.forEach((e) => e.addTransition(transition));

  void reset() => setData(CropImageData());

  void setData(CropImageData data) => listeners.forEach((e) => e.setData(data));
}

mixin CustomImageCropListener {
  CropImageData data = CropImageData(scale: 1);

  void addTransition(CropImageData transition);

  void setData(CropImageData transition);

  Future<MemoryImage?> onCropImage();
}
