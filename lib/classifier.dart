import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  Classifier() {
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print("Error while loading model: $e");
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').map((e) => e.trim()).toList();
      print('Labels loaded successfully: ${_labels.length} labels');
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  List<List<List<List<double>>>> processImage(File image) {
    final rawImage = img.decodeImage(image.readAsBytesSync())!;
    final resizedImage = img.copyResize(rawImage, width: 224, height: 224);

    List<List<List<List<double>>>> input = List.generate(
      1,
      (batch) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              (img.getRed(pixel) / 255.0),
              (img.getGreen(pixel) / 255.0),
              (img.getBlue(pixel) / 255.0),
            ];
          },
        ),
      ),
    );

    return input;
  }

  Future<List<dynamic>> classifyImage(File image) async {
    var input = processImage(image);
    var output = List.generate(1, (index) => List.filled(127, 0.0));

    try {
      _interpreter.run(input, output);
    } catch (e) {
      print("Error while running inference: $e");
      return ["Error", "0"];
    }

    final probabilities = output[0];
    int maxIndex = probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

    return [_labels[maxIndex], probabilities[maxIndex]];
  }
}
