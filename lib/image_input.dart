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

  late Map<int, dynamic> keyPoints;
  late ui.Image image;

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

    List? recognition = await Tflite.runPoseNetOnImage(
      path: imageFile.path,
      imageMean: 125.0,
      imageStd: 125.0,
      numResults: 2,
      threshold: 0.7,
      nmsRadius: 10,
      asynch: true,
    );

    if (recognition!.isNotEmpty ) {
      setState(() {
        keyPoints = Map<int, dynamic>.from(recognition[0]['keypoints']);
      });
    } else {
      keyPoints = {};
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            loading
              ? Container (
                  width: 380,
                  height: 500,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                child: const Text(
                  'No Image Taken',
                  textAlign: TextAlign.center,
                ),
            )
                : FittedBox(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: CirclePainter(keyPoints, image),
                )
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('カメラ'),
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.black),
                      )
                    ),
                    onPressed: _takePicture,
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリー'),
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.black)
                      )
                    ),
                    onPressed: _getImageFromGallery,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  late final Map params;
  late final ui.Image image;

  CirclePainter(this.params, this.image);

  @override
  void paint(ui.Canvas canvas, Size size) {
    final paint = Paint();
    if (image != null) {
      canvas.drawImage(image, ui.Offset(0, 0), paint);
    }
    paint.color = Colors.red;
    if (params.isNotEmpty) {
      params.forEach((index, params) {
        canvas.drawCircle(
          Offset(size.width * params['x'], size.height * params['y']),
          10,
          paint
        );
      });
      print("Done!");
    }
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) => false;
}
