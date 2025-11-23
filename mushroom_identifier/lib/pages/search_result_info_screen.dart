import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultInfoScreen extends StatelessWidget {
  final String mushroomId;
  final Map<String, dynamic> mushroomData;

  const SearchResultInfoScreen({
    super.key,
    required this.mushroomId,
    required this.mushroomData,
  });

  void _openWiki(BuildContext context) async {
    final url = mushroomData["search_metadata"]?["wikipedia_url"];
    if (url == null) return;

    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildBox(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = mushroomData["search_metadata"] ?? {};
    final basic = mushroomData["basic_info"] ?? {};

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text(
          basic["common_name"] ?? "Mushroom Info",
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_new, color: colorScheme.onSurface),
            onPressed: () => _openWiki(context),
            tooltip: "Open Wikipedia",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: meta["image"] != null
                  ? Image.network(
                meta["image"],
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                "assets/sample/error.jpg",
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            /// BASIC INFO
            _buildSectionTitle(context, "Basic Information"),
            const SizedBox(height: 8),
            _buildBox(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Common Name: ${basic["common_name"] ?? "N/A"}"),
                  Text("Scientific Name: ${basic["scientific_name"] ?? "N/A"}"),
                  Text("Edibility: ${basic["edibility"] ?? "N/A"}"),
                  Text("Toxicity Level: ${basic["toxicity_level"] ?? "N/A"}"),
                  Text("Habitat: ${basic["habitat"] ?? "N/A"}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PHYSICAL CHARACTERISTICS
            _buildSectionTitle(context, "Physical Characteristics"),
            const SizedBox(height: 8),
            _buildBox(
              context,
              Text(mushroomData["physical_characteristics"] ?? "N/A"),
            ),

            const SizedBox(height: 20),

            /// LOOK ALIKE
            _buildSectionTitle(context, "Look-Alike"),
            const SizedBox(height: 8),
            _buildBox(
              context,
              Text(mushroomData["look_alike"] ?? "N/A"),
            ),

            const SizedBox(height: 20),

            /// USAGES
            _buildSectionTitle(context, "Usages"),
            const SizedBox(height: 8),
            _buildBox(
              context,
              Text(mushroomData["usages"] ?? "N/A"),
            ),

            const SizedBox(height: 20),

            /// Safety Tips
            _buildSectionTitle(context, "Safety Tips"),
            const SizedBox(height: 8),
            _buildBox(
              context,
              Text(mushroomData["safety_tips"] ?? "N/A"),
            ),
          ],
        ),
      ),
    );
  }
}
