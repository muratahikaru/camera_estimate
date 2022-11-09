import 'dart:async';
import 'package:camera/camera.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

List<CameraDescription> cams = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cams = await availableCameras();
  } on CameraException catch(e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = 'Muscle Training Support';
    return MaterialApp(
      title: title,
      home: SquatCamPage(title: title, cameras: cams),
    );
  }
}

class SquatCamPage extends StatefulWidget {
  final String title;
  final List<CameraDescription> cameras;
  final bool _showDebugMsg = true;
  const SquatCamPage({Key? key, required this.title, required this.cameras}) : super(key: key);
}