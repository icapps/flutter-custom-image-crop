import 'package:custom_image_crop/custom_image_crop_data.dart';
import 'package:flutter/material.dart';

class CustomImageCropController {
  final listeners = <CustomImageCropListener>[];

  RawImage onCropImage() => listeners.map((e) => e.onCropImage()).firstWhere((element) => element != null, orElse: () => null);

  CropImageData get cropImageData => listeners.map((e) => e.data).firstWhere((element) => element != null, orElse: () => null);

  void addListener(CustomImageCropListener listener) {
    listeners.add(listener);
  }

  void removeListener(CustomImageCropListener listener) {
    listeners.remove(listener);
  }

  void notifyListeners() => addTransition(CropImageData());

  void dispose() {
    listeners.clear();
  }

  void addTransition(CropImageData transition) {
    listeners.forEach((e) => e.addTransition(transition));
  }

  void setData(CropImageData data) {
    listeners.forEach((e) => e.setData(data));
  }

  void rotateImage({double angle, double angleIncrease}) {
    assert(angle != null && angleIncrease != 0);
    notifyListeners();
  }

  void translateImage({double dx, double dy, double x, double y, Offset translation, Offset position}) {
    notifyListeners();
  }

  void scaleImage({double scale, double dscale}) {
    notifyListeners();
  }
}

mixin CustomImageCropListener {
  CropImageData data = CropImageData(scale: 1);

  void addTransition(CropImageData transition);

  void setData(CropImageData transition);

  RawImage onCropImage();
}
