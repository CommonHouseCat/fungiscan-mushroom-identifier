import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class InferenceResultScreen extends StatelessWidget {
  final String predictedClass;
  final int predictedIndex;
  final String confidence;

  const InferenceResultScreen({
    super.key,
    required this.predictedClass,
    required this.predictedIndex,
    required this.confidence,
  });

  Future<Uint8List?> _getCachedImage() async {
    final box = Hive.box('cache');
    return box.get('edited_image') as Uint8List?;
  }

  Future<void> _cleanup() async {
    final box = Hive.box('cache');
    box.delete('edited_image');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _getCachedImage(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (bytes == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inference Result')),
            body: const Center(child: Text('No cached image found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Inference Result'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await _cleanup();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  predictedClass,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Class index: $predictedIndex',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  'Confidence: $confidence',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await _cleanup();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
