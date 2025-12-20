import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../components/button_component.dart';
import '../components/theme_toggle_button.dart';
import '../configs/themes/theme_provider.dart';
import 'image_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> _openGallery() async {
    var status = await Permission.photos.request();
    if(status.isGranted) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if(image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageEditorScreen(imagePath: image.path),
          ),
        );
      }
    }
    else if (status.isPermanentlyDenied) {
      _openAppSettings();
    }
  }

  Future<void> _openCamera() async {
    var status = await Permission.camera.request();
    if(status.isGranted) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (!mounted) return;
      if(image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageEditorScreen(imagePath: image.path),
          ),
        );
      }
    }
    else if (status.isPermanentlyDenied) {
      _openAppSettings();
    }
  }

  void _openAppSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('Please enable permissions in app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text(
          'Mushroom Identifier',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          ThemeToggleButtonWidget(
            isDarkMode: themeProvider.isDarkMode,
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pick an image from gallery or take a picture to identify mushrooms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 80),

            ButtonComponent(
              label: "Gallery",
              fontSize: 20,
              icon: Icons.image,
              iconColor: Colors.black,
              iconSize: 20,
              onPressed: _openGallery,
              width: 300,
              height: 150,
              borderWidth: 2.0,
            ),

            const SizedBox(height: 20),

            Divider(
              height: 20,
              color: Colors.grey,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 20),

            ButtonComponent(
              label: "Camera",
              fontSize: 20,
              icon: Icons.camera,
              iconColor: Colors.black,
              iconSize: 20,
              onPressed: _openCamera,
              width: 300,
              height: 150,
              borderWidth: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
