import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class MushroomInformationScreen extends StatelessWidget {
  final Map<String, dynamic> mushroomData;

  const MushroomInformationScreen({super.key, required this.mushroomData});

  String _parseJsonField(String? jsonString, String key, [String defaultValue = 'N/A']) {
    if (jsonString == null || jsonString.isEmpty) return defaultValue;
    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      return parsed[key] as String? ?? defaultValue;
    } catch (e) {
      debugPrint("Error parsing JSON in MushroomInformationScreen: $e");
      return defaultValue;
    }
  }

  Widget _buildInfoBox({required BuildContext context, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              title.isNotEmpty ? '$title: $content' : content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? imageBytes = mushroomData[DatabaseService.columnImage] as Uint8List?;
    final double confidenceScore = (mushroomData[DatabaseService.columnConfidenceScore] as num?)?.toDouble() ?? 0.0;
    final String basicInfoJson = mushroomData[DatabaseService.columnBasicInfo] as String? ?? '{}';
    final String physicalCharacteristics = mushroomData[DatabaseService.columnPhysicalCharacteristics] as String? ?? 'N/A';
    final String lookAlike = mushroomData[DatabaseService.columnLookAlike] as String? ?? 'N/A';
    final String usages = mushroomData[DatabaseService.columnUsages] as String? ?? 'N/A';
    final String safetyTips = mushroomData[DatabaseService.columnSafetyTips] as String? ?? 'N/A';
    final String mushroomName = _parseJsonField(basicInfoJson, 'common_name');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text(mushroomName, style: TextStyle(color: colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  )
                : Image.asset(
                    'assets/sample/error.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confidence Score: ${confidenceScore * 100}%',
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text('Basic Information',style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            _buildInfoBox(
              context: context,
              children: [
                _buildBulletPoint('Mushroom Name', _parseJsonField(basicInfoJson, 'common_name')),
                _buildBulletPoint('Scientific Name', _parseJsonField(basicInfoJson, 'scientific_name')),
                _buildBulletPoint('Edibility', _parseJsonField(basicInfoJson, 'edibility')),
                _buildBulletPoint('Toxicity Level', _parseJsonField(basicInfoJson, 'toxicity_level')),
                _buildBulletPoint('Habitat', _parseJsonField(basicInfoJson, 'habitat')),
              ],
            ),
            const SizedBox(height: 16),
            Text('Physical Characteristics', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            _buildInfoBox(context: context, children: [_buildBulletPoint('', physicalCharacteristics)]),
            const SizedBox(height: 16),
            Text('Look Alike', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            _buildInfoBox(context: context, children: [_buildBulletPoint('', lookAlike)]),
            const SizedBox(height: 16),
            Text('Usages', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            _buildInfoBox(context: context, children: [_buildBulletPoint('', usages)]),
            const SizedBox(height: 16),
            Text('Safety Tips', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            _buildInfoBox(context: context, children: [_buildBulletPoint('', safetyTips)]),
          ],
        ),
      ),
    );
  }
}