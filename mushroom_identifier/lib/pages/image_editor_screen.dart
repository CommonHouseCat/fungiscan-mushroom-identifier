import 'package:flutter/material.dart';
import 'dart:io';

class ImageEditorScreen extends StatelessWidget {
  final String imagePath;

  const ImageEditorScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Failed to load image');
          },
        ),
      ),
    );
  }
}