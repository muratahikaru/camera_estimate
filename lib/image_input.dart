import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

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
    Tflite.close();
    try {
      await Tflite.loadModel(
        model: 'assets/posenet_mv1_075_float_from_checkpoints.tflite',
      );
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  Future poseEstimation(File imageFile) async {
    final imageByte = await imageFile.readAsBytes();
    image = await decodeImageFromList(imageByte);

    List recognition = await Tflite.runPoseNetOnImage(
      path: imageFile.path,
      imageMean: 125.0,
      imageStd: 125.0,
      numResults: 2,
      threshold: 0.7,
      nmsRadius: 10,
      asynch: true,
    );
  }
}
