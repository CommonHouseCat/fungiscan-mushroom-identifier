import 'package:flutter/material.dart';
import '../pages/mushroom_information_screen.dart';
import '../services/database_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class MushroomInfoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const MushroomInfoItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onCopy,
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
    final colorScheme = Theme.of(context).colorScheme;
    final Uint8List? imageBytes = item[DatabaseService.columnImage] as Uint8List?;

    String mushroomName = 'Unknown Mushroom';
    final dynamic basicInfo = item[DatabaseService.columnBasicInfo];

    if (basicInfo != null && basicInfo is String) {
      try {
        final Map<String, dynamic> parsedBasicInfo = jsonDecode(basicInfo);
        mushroomName = parsedBasicInfo['common_name'] as String? ?? 'Unknown Mushroom';
      } catch (e) {
        debugPrint('Error parsing JSON in MushroomInfoItem: $e');
        mushroomName = 'Error Reading Name';
      }
    }

    return Card(
      color: colorScheme.tertiary,
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
                child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    )
                  : Image.asset(
                      'assets/sample/error.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    mushroomName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    } else if (value == 'copy') {
                      onCopy();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'copy',
                      child: ListTile(
                        leading: Icon(Icons.copy, color: colorScheme.onSurface),
                        title: Text('Copy', style: TextStyle(color: colorScheme.onSurface)),
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
