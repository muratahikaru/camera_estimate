import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageInput extends StatefulWidget {
  final Function onSelectImage;

  ImageInput(this.onSelectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  final picker = ImagePicker();
  bool loading = true;

  Map<int, dynamic>? keyPoints;
  ui.Image? image;

  Future<void> _takePicture() async {
    setState(() {
      loading = true;
    });

    final imageFile = await picker.pickImage(
      source: ImageSource.camera
    );

    if (imageFile == null) {
      return;
    }
    poseEstimation(File(imageFile.path));
  }

  Future<void> _getImageFromGallery() async {
    setState(() {
      loading = true;
    });

    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imageFile == null) {
      return;
    }

    poseEstimation(File(imageFile.path));
  }

  static Future loadModel() async {

  }
}
