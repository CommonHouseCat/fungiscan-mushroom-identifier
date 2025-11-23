import 'package:flutter/material.dart';
import '../pages/search_result_info_screen.dart';

class SearchResultItem extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;

  const SearchResultItem({
    super.key,
    required this.id,
    required this.data,
  });

  void _onTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultInfoScreen(
          mushroomId: id,
          mushroomData: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final meta = data["search_metadata"];
    final String name = meta?["common_name"] ?? "Unknown Mushroom";
    final String? imageUrl = meta?["image"];

    return Card(
      color: colorScheme.tertiary,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Expanded(
              flex: 7,
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
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

            // TEXT
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
