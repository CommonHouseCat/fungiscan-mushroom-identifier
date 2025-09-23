import 'dart:io';
import 'package:flutter/material.dart';

class InferenceResultScreen extends StatelessWidget {
  final String imagePath;
  final String predictedClass;
  final int predictedIndex;
  final String confidence;

  const InferenceResultScreen({
    super.key,
    required this.imagePath,
    required this.predictedClass,
    required this.predictedIndex,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inference Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(predictedClass,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Class index: $predictedIndex',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Confidence: $confidence%',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            // placeholder for next step (firebase lookup / details)
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
