import 'dart:convert';
import 'package:FungiScan/components/search_result_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, dynamic> _allMushrooms = {};
  List<MapEntry<String, dynamic>> _filteredResults = [];
  bool _isLoading = true;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _loadMushroomDatabase();
  }

  Future<void> _loadMushroomDatabase() async {
    try {
      final rawJson = await rootBundle.loadString("assets/mushroom_info.json");
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _allMushrooms = data;
        _filteredResults = data.entries.take(8).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading mushroom database: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _search(String query) {
    setState(() {
      _query = query.trim().toLowerCase();

      if (_query.isEmpty) {
        _filteredResults = _allMushrooms.entries.take(8).toList();
        return;
      }

      _filteredResults = _allMushrooms.entries.where((entry) {
        final meta = entry.value["search_metadata"];
        if (meta == null) return false;

        final common = meta["common_name"]?.toString().toLowerCase() ?? "";
        final scientific = meta["scientific_name"]?.toString().toLowerCase() ?? "";
        final keywords = (meta["keywords"] as List<dynamic>?)
            ?.map((e) => e.toString().toLowerCase())
            .toList() ??
            [];

        return common.contains(_query) ||
            scientific.contains(_query) ||
            keywords.any((k) => k.contains(_query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text("Search", style: TextStyle(color: colorScheme.onSurface)),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Search mushrooms...",
                filled: true,
                fillColor: colorScheme.tertiary, 
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredResults.isEmpty
                ? Center(
              child: Text(
                'No results found.',
                style: textTheme.bodyLarge
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.05,
              ),
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final entry = _filteredResults[index];
                final id = entry.key;
                final data = entry.value;

                return SearchResultItem(
                    id: id,
                    data: data
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
