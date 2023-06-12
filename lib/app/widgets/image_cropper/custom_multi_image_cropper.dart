import 'dart:io';
import 'package:flutter/material.dart';

import 'custom_image_cropper_service.dart';

/// Method [startCropping] open new screen where all selected images crop at
/// single click. Parameter [pixelRatio] define the quality of crop image and
/// parameter [aspectRatio] is ratio of image in which image will crop.

class CustomMultiImageCrop {
  static startCropping(
      {required BuildContext context,
      required List<File> files,
      bool alwaysShowGrid = false,
      double? pixelRatio,
      Color? activeColor,
      required Function callBack}) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomMultiImageCropService(
                  files: files,
                  pixelRatio: pixelRatio,
                  activeColor: activeColor,
                  alwaysShowGrid: alwaysShowGrid,
                ))).then((value) {
      if (value != null) {
        callBack(value);
      }
    });
  }
}
