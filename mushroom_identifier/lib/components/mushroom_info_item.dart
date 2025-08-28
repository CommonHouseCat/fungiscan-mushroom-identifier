import 'package:flutter/material.dart';
import '../pages/mushroom_information_screen.dart';
import '../services/database_service.dart';
import 'dart:convert';

class MushroomInfoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const MushroomInfoItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onCopy,
    required this.onShare,
  });

  void _onItemTap(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MushroomInformationScreen(mushroomData: item),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath = item[DatabaseService.columnImagePath] as String? ?? 'assets/sample/error.jpg';

    String mushroomName = 'Unknown Mushroom';
    final dynamic basicInfo = item[DatabaseService.columnBasicInfo];

    if (basicInfo != null && basicInfo is String) {
      try {
        final Map<String, dynamic> parsedBasicInfo = jsonDecode(basicInfo);
        mushroomName = parsedBasicInfo['name'] as String? ?? 'Unknown Mushroom';
      } catch (e) {
        print("Error decoding basic_info JSON in MushroomInfoItem: $e");
        mushroomName = 'Error Reading Name';
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _onItemTap(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                // Image
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/sample/error.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              // Mushroom name
              children: [
                Text(
                  mushroomName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                const Spacer(),
                // Popup menu button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    } else if (value == 'copy') {
                      onCopy();
                    } else if (value == 'share') {
                      onShare();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'copy',
                      child: ListTile(
                        leading: Icon(Icons.copy, color: Colors.black),
                        title: Text('Copy', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: ListTile(
                        leading: Icon(Icons.share, color: Colors.black),
                        title: Text('Share', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
