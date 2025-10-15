import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:mushroom_identifier/pages/inference_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  bool _processing = false;

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
    if(_processing) return;
    setState(() {
      _processing = true;
    });
    try {
      // capture from UI
      RenderRepaintBoundary boundary = _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // decode & write to file for inference upload
      img.Image edited = img.decodePng(pngBytes)!;
      final dir = await getTemporaryDirectory();
      final outPath = '${dir.path}/processed.png';
      await File(outPath).writeAsBytes(img.encodePng(edited));

      // store PNG bytes in Hive for later display
      final box = Hive.box('cache');
      box.put('edited_image', pngBytes);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InferenceScreen(
            imagePath: outPath,
            serverUrl: dotenv.env['SERVER_URL'] ?? (throw Exception('SERVER_URL not found in .env')),
          ),
        ),
      );
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.check, color: colorScheme.onSurface),
              onPressed: _save,
          ),
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
                            child: Container(
                              width: 1,
                              color: Colors.white.withValues(),
                            ),
                          ),
                          Positioned(
                            left: cropSize * 2 / 3,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 1,
                              color: Colors.white.withValues(),
                            ),
                          ),
                          Positioned(
                            top: cropSize / 3,
                            left: 0,
                            right: 0,
                            child: Container(
                              width: 1,
                              color: Colors.white.withValues(),
                            ),
                          ),
                          Positioned(
                            top: cropSize * 2 / 3,
                            left: 0,
                            right: 0,
                            child: Container(
                              width: 1,
                              color: Colors.white.withValues(),
                            ),
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
        color: colorScheme.tertiary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.rotate_left, color: colorScheme.onSurface),
              onPressed: _rotateLeft,
            ),
            Text('${(_zoom * 100).toInt()}%'),
            IconButton(
              icon: Icon(Icons.rotate_right, color: colorScheme.onSurface),
              onPressed: _rotateRight,
            ),
          ],
        ),
      ),
    );
  }
}
