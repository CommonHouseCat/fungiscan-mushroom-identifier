import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'processed_preview_screen.dart';

class ImageEditorScreen extends StatefulWidget {
  final String imagePath;

  const ImageEditorScreen({super.key, required this.imagePath});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _cropKey = GlobalKey();
  double _rotation = 0;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateZoom);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateZoom);
    _controller.dispose();
    super.dispose();
  }

  void _updateZoom() {
    setState(() {
      _zoom = _controller.value.getMaxScaleOnAxis();
    });
  }

  void _rotateLeft() {
    setState(() {
      _rotation = (_rotation - 90) % 360;
    });
  }

  void _rotateRight() {
    setState(() {
      _rotation = (_rotation + 90) % 360;
    });
  }

  Future<void> _save() async {
    RenderRepaintBoundary boundary = _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    img.Image edited = img.decodePng(pngBytes)!;
    img.Image resized = img.copyResize(edited, width: 224, height: 224);
    final dir = await getTemporaryDirectory();
    final outPath = '${dir.path}/processed.png';
    await File(outPath).writeAsBytes(img.encodePng(resized));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessedPreviewScreen(imagePath: outPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final cropSize = math.min(constraints.maxWidth, availableHeight);
          return SizedBox(
            width: double.infinity,
            height: availableHeight,
            child: Center(
              child: SizedBox(
                width: cropSize,
                height: cropSize,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      key: _cropKey,
                      child: ClipRect(
                        child: InteractiveViewer(
                          transformationController: _controller,
                          minScale: 0.5,
                          maxScale: 5.0,
                          child: Transform.rotate(
                            angle: _rotation * math.pi / 180,
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Stack(
                        children: [
                          Positioned(
                            left: cropSize / 3,
                            top: 0,
                            bottom: 0,
                            child: Container(width: 1, color: Colors.white.withValues()),
                            // child: Container(width: 1, color: Colors.white.withOpacity(0.5)),
                          ),
                          Positioned(
                            left: cropSize * 2 / 3,
                            top: 0,
                            bottom: 0,
                            child: Container(width: 1, color: Colors.white.withValues()),
                          ),
                          Positioned(
                            top: cropSize / 3,
                            left: 0,
                            right: 0,
                            child: Container(width: 1, color: Colors.white.withValues()),
                          ),
                          Positioned(
                            top: cropSize * 2 / 3,
                            left: 0,
                            right: 0,
                            child: Container(width: 1, color: Colors.white.withValues()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.rotate_left), onPressed: _rotateLeft),
            Text('${(_zoom * 100).toInt()}%'),
            IconButton(icon: const Icon(Icons.rotate_right), onPressed: _rotateRight),
          ],
        ),
      ),
    );
  }
}