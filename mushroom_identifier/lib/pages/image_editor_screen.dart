import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'inference_screen.dart';

class ImageEditorScreen extends StatefulWidget {
  final String imagePath;

  const ImageEditorScreen({super.key, required this.imagePath});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  File? _editedFile;

  Future<void> _startEditing() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 95,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Edit Image",
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
        ),
        IOSUiSettings(
          title: "Edit Image",
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    final tempDir = await getTemporaryDirectory();
    final outputPath =
        "${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final file = File(outputPath);
    final bytes = await cropped.readAsBytes();
    await file.writeAsBytes(bytes);

    final box = Hive.box('cache');
    await box.put('edited_image', bytes);

    setState(() {
      _editedFile = file;
    });

    _goToInference(outputPath);
  }

  void _goToInference(String outPath) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InferenceScreen(
          imagePath: outPath,
          serverUrl: dotenv.env['SERVER_URL'] ??
              (throw Exception("SERVER_URL missing")),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayFile = _editedFile ?? File(widget.imagePath);

    return Scaffold(
      appBar: AppBar(title: const Text("Image Editor")),
      body: Center(child: Image.file(displayFile)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text("Edit & Continue"),
          onPressed: _startEditing,
        ),
      ),
    );
  }
}
