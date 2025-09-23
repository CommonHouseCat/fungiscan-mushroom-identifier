import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'inference_result_screen.dart';

class InferenceScreen extends StatefulWidget {
  final String imagePath;

  const InferenceScreen({super.key, required this.imagePath});

  @override
  State<InferenceScreen> createState() => _InferenceScreenState();
}

class _InferenceScreenState extends State<InferenceScreen> {
  late ClassificationModel _efficientNetModel;
  late ClassificationModel _mobilenetModel;
  late List<String> _labels;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeModelsAndRun();
  }

  Future<void> _initializeModelsAndRun() async {
    try {
      // Load labels
      final labelsRaw = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsRaw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      // Load models once
      _mobilenetModel = await PytorchLite.loadClassificationModel(
        "assets/models/mushroom_mobilenetv2.pt",
        224,
        224,
        _labels.length,
      );

      _efficientNetModel = await PytorchLite.loadClassificationModel(
        "assets/models/mushroom_efficientnet_lite2.pt",
        224,
        224,
        _labels.length,
      );

      // Run inference on the provided image
      await _runInference(widget.imagePath);
    } catch (e, st) {
      debugPrint("Model init error: $e\n$st");
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _runInference(String imagePath) async {
    try {
      final Uint8List imageBytes = await File(imagePath).readAsBytes();

      final List<double>? mobileNetOutput = await _mobilenetModel.getImagePredictionListProbabilities(imageBytes);
      final List<double>? efficientNetOutput = await _efficientNetModel.getImagePredictionListProbabilities(imageBytes);

      if (mobileNetOutput == null || efficientNetOutput == null) {
        throw Exception('One of the models returned null probabilities');
      }

      if (mobileNetOutput.length != efficientNetOutput.length) {
        throw Exception(
            'Model output size mismatch: ${mobileNetOutput.length} vs ${efficientNetOutput.length}');
      }

      // Soft voting (average probabilities)
      final int len = mobileNetOutput.length;
      final List<double> avg = List<double>.filled(len, 0.0);
      for (int i = 0; i < len; i++) {
        avg[i] = (mobileNetOutput[i] + efficientNetOutput[i]) / 2;
      }

      // Find top prediction
      int maxIndex = 0;
      double maxValue = avg[0];
      for (int i = 1; i < avg.length; i++) {
        if (avg[i] > maxValue) {
          maxValue = avg[i];
          maxIndex = i;
        }
      }

      final predictedLabel =
      (maxIndex < _labels.length) ? _labels[maxIndex] : 'Class $maxIndex';
      final confidencePercent = (maxValue * 100).toStringAsFixed(2);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InferenceResultScreen(
            imagePath: imagePath,
            predictedClass: predictedLabel,
            predictedIndex: maxIndex,
            confidence: confidencePercent,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint("Inference error: $e\n$st");
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Running inference")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Error: $_error", textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}
