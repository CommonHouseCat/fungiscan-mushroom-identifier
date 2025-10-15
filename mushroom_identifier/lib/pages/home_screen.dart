import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/button_component.dart';
import '../components/theme_toggle_button.dart';
import 'image_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- State Variables (kept in HomeScreen for now) ---
  bool _isDarkMode = false;

  // --- Methods to Toggle State (kept in HomeScreen for now) ---
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

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

  // Open app settings if permission is  denied
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mushroom Identifier'),
        centerTitle: false,
        actions: <Widget>[
          ThemeToggleButtonWidget(
            isDarkMode: _isDarkMode,
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pick an image from gallery or take a picture to identify mushrooms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            ButtonComponent(
              label: "Gallery",
              fontSize: 20,
              icon: Icons.image,
              iconColor: Colors.black,
              iconSize: 20,
              onPressed: _openGallery,
              width: 300,
              height: 150,
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
            ),
          ],
        ),
      ),
    );
  }
}
