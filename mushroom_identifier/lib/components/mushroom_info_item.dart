import 'package:flutter/material.dart';
import '../pages/mushroom_information_screen.dart';
import '../services/database_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class MushroomInfoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onToggleBookmark;

  const MushroomInfoItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onCopy,
    required this.onToggleBookmark,
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
    final Uint8List? imageBytes =
        item[DatabaseService.columnImage] as Uint8List?;

    String mushroomName = 'Unknown Mushroom';
    final dynamic basicInfo = item[DatabaseService.columnBasicInfo];

    if (basicInfo != null && basicInfo is String) {
      try {
        final Map<String, dynamic> parsedBasicInfo = jsonDecode(basicInfo);
        mushroomName =
            parsedBasicInfo['common_name'] as String? ?? 'Unknown Mushroom';
      } catch (e) {
        debugPrint('Error parsing JSON in MushroomInfoItem: $e');
        mushroomName = 'Error Reading Name';
      }
    }

    return Card(
      color: colorScheme.tertiary,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTap: () => _onItemTap(context),
              child: imageBytes != null
                  ? Image.memory(
                imageBytes,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/sample/error.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mushroomName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 18,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            item[DatabaseService.columnIsBookMark] == 1
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: colorScheme.onSurface,
                            size: 24,
                          ),
                          onPressed: onToggleBookmark,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurface,
                          size: 20,
                        ),
                        padding: const EdgeInsets.only(left: 16.0),
                        onSelected: (value) =>
                            value == 'delete' ? onDelete() : onCopy(),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'copy',
                            child: ListTile(
                              leading: Icon(
                                Icons.copy,
                                color: colorScheme.onSurface,
                                size: 20,
                              ),
                              title: Text(
                                'Copy',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              title: Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
