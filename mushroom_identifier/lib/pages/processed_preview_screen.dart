import 'dart:io';
import 'package:flutter/material.dart';

class ProcessedPreviewScreen extends StatelessWidget {
  final String imagePath;

  const ProcessedPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processed Image")),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
