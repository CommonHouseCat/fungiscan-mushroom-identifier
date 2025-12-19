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
    final url = mushroomData["search_metadata"]?["wikipedia_url"] as String?;
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Wikipedia link")),
        );
      }
    }
  }

  // Reusable info box
  Widget _buildInfoBox({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Consistent bullet point style — larger font, bold titles
  Widget _buildBulletPoint(String title, String content, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    if (content.isEmpty || content == "N/A") content = "Not specified";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, height: 1.4, color: textColor,),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: "$title: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basic = mushroomData["basic_info"] ?? {};
    final meta = mushroomData["search_metadata"];
    final String? imageUrl = meta?["image"];

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text(
          basic["common_name"] ?? "Mushroom Details",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/error.jpg',
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  'assets/error.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Basic Information
            Text("Basic Information", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoBox(
              context: context,
              children: [
                _buildBulletPoint("Common Name", basic["common_name"] ?? "N/A", context),
                _buildBulletPoint("Scientific Name", basic["scientific_name"] ?? "N/A", context),
                _buildBulletPoint("Edibility", basic["edibility"] ?? "N/A", context),
                _buildBulletPoint("Toxicity Level", basic["toxicity_level"] ?? "N/A", context),
                _buildBulletPoint("Habitat", basic["habitat"] ?? "N/A", context),
              ],
            ),

            const SizedBox(height: 24),

            // Physical Characteristics
            Text("Physical Characteristics", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoBox(
              context: context,
              children: [
                _buildBulletPoint("", mushroomData["physical_characteristics"]?.toString() ?? "N/A", context),
              ],
            ),

            const SizedBox(height: 24),

            // Look-Alike
            Text("Look-Alike Species", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoBox(
              context: context,
              children: [
                _buildBulletPoint("", mushroomData["look_alike"]?.toString() ?? "N/A", context),
              ],
            ),

            const SizedBox(height: 24),

            // Usages
            Text("Culinary & Medicinal Uses", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoBox(
              context: context,
              children: [
                _buildBulletPoint("", mushroomData["usages"]?.toString() ?? "N/A", context),
              ],
            ),

            const SizedBox(height: 24),

            // Safety Tips
            Text("Safety Tips", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoBox(
              context: context,
              children: [
                _buildBulletPoint("", mushroomData["safety_tips"]?.toString() ?? "N/A", context),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}