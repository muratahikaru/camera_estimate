import 'package:camera/camera.dart';
import './keypoints.dart';
import 'package:tflite/tflite.dart';

class PredictionResult {
  final DateTime timestamp;
  final KeyPoints keyPoints;
  final Duration duration;

  const PredictionResult(this.timestamp, this.keyPoints, this.duration);
}

class Predictor {
  bool _initialized = false;
  bool _busy = false;

  Predictor();

  bool get ready => _initialized && !_busy;

  Future<void> init() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
    );
    _initialized = true;
  }

  Future<PredictionResult?> predict(CameraImage image) async {
    if (!_initialized) {
      throw Exception("Model is not loaded");
    } else if (_busy) {
      throw ResourceIsBusy();
    }
    _busy = true;
    print("---------------------");
    print(_busy);
    print("--------------------");
    final ts = DateTime.now();
    try {
      var res = await Tflite.runPoseNetOnFrame(
        bytesList: image.planes.map((plane) {return plane.bytes;}).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        numResults: 1,
      );
      if (res == null) {
        print("---------------------");
        print("自分あほnann");
        print("--------------------");
        throw Exception("Invalid prediction result");
      } else if (res.isEmpty) {
        print("---------------------");
        print(res);
        print("--------------------");
        return null;
      }
      final kp = KeyPoints.fromPoseNet(res[0]);
      print("んげーーーーーーーーー");
      print(kp);
      print("--------------------");
      return PredictionResult(ts, kp, DateTime.now().difference(ts));
    } catch (e) {
      rethrow;
    } finally {
      _busy = false;
      print("---------------------");
      print(_busy);
      print("--------------------");
    }
  }
}

class ResourceIsBusy extends Error {
  @override
  String toString() => "Resource is busy";
}
