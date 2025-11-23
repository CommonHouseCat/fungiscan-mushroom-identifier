import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ForageMapScreen extends StatefulWidget {
  const ForageMapScreen({super.key});

  @override
  State<ForageMapScreen> createState() => _ForageMapScreenState();
}

class _ForageMapScreenState extends State<ForageMapScreen> {
  LatLng? userLocation;
  bool loading = true;

  Map<String, dynamic> mushroomDB = {};
  final List<String> speciesList = ["All Species", "Only Mushrooms"];
  String selectedSpecies = "Only Mushrooms";

  List<Marker> mushroomMarkers = [];
  List<dynamic> mushroomRawData = [];

  String selectedRadius = "10";
  String selectedLimit = "10";
  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    const monthAbbreviations = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    selectedMonth = monthAbbreviations[DateTime.now().month - 1];
    initLocation();
  }

  // -------------------------------------------------------------
  // LOCATION
  // -------------------------------------------------------------
  Future<void> initLocation() async {
    final permission = await _handlePermission();
    if (!permission) {
      setState(() => loading = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    userLocation = LatLng(pos.latitude, pos.longitude);

    await fetchMushrooms();

    setState(() => loading = false);
  }

  Future<bool> _handlePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // -------------------------------------------------------------
  // iNATURALIST API CALL
  // -------------------------------------------------------------
  Future<void> fetchMushrooms() async {
    if (userLocation == null) return;

    // Build taxon filter
    String taxonFilter = "";
    if (selectedSpecies == "Only Mushrooms") {
      taxonFilter = "taxon_id=47170&"; // Fungi
    }

    // Month filter
    String monthFilter =
    selectedMonth == "All" ? "" : "month=${_monthNumber(selectedMonth)}&";

    final url =
        "https://api.inaturalist.org/v1/observations?"
        "$taxonFilter"
        "$monthFilter"
        "lat=${userLocation!.latitude}&"
        "lng=${userLocation!.longitude}&"
        "radius=$selectedRadius&"
        "per_page=$selectedLimit";

    final res = await http.get(Uri.parse(url));

    if (!mounted) return;

    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load observations")),
      );
      return;
    }

    final json = jsonDecode(res.body);

    final List results = json["results"];

    mushroomMarkers.clear();
    mushroomRawData = results;

    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      if (r["geojson"] == null) continue;

      final coords = r["geojson"]["coordinates"];
      if (coords.length < 2) continue;

      final lng = coords[0];
      final lat = coords[1];

      mushroomMarkers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () => showSpeciesDetail(r),
            child: const Icon(Icons.location_on, color: Colors.red, size: 32),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  int _monthNumber(String m) {
    const months = {
      "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4,
      "May": 5, "Jun": 6, "Jul": 7, "Aug": 8,
      "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12
    };
    return months[m] ?? 1;
  }

  // -------------------------------------------------------------
  // SHOW MARKER DETAILS
  // -------------------------------------------------------------
  void showSpeciesDetail(dynamic item) {
    final species = item["taxon"]?["name"] ?? "Unknown";
    final common = item["taxon"]?["preferred_common_name"] ?? "Unknown";
    final imageUrl = item["photos"] != null && item["photos"].isNotEmpty
        ? item["photos"][0]["url"].toString().replaceAll("square", "medium")
        : null;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(common, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(species, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),

            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl, height: 150),
              ),

            const SizedBox(height: 10),

            Text("Observed on: ${item["observed_on"] ?? 'Unknown'}"),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userLocation == null) {
      return const Scaffold(
        body: Center(child: Text("Cannot find user location!")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forage Map"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => showFilterSheet(context),
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation!,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
            userAgentPackageName: "vn.vinh.fungiScan",
          ),
          MarkerLayer(markers: [
            Marker(
              width: 50,
              height: 50,
              point: userLocation!,
              child: const Icon(Icons.person_pin_circle,
                  size: 45, color: Colors.blue),
            ),
            ...mushroomMarkers
          ])
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // FILTER SHEET
  // -------------------------------------------------------------
  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 50,
              right: 50,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Safe for keyboard
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Filter options", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),

                // month
                DropdownButton<String>(
                  value: selectedMonth,
                  items: [
                    "All",
                    "Jan", "Feb", "Mar", "Apr",
                    "May", "Jun", "Jul", "Aug",
                    "Sep", "Oct", "Nov", "Dec"
                  ].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedMonth = v!);
                    setState(() => selectedMonth = v!);
                  },
                ),

                // radius
                DropdownButton<String>(
                  value: selectedRadius,
                  items: ["5", "10", "20", "50"].map((e) {
                    return DropdownMenuItem(
                        value: e, child: Text("$e km radius"));
                  }).toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedRadius = v!);
                    setState(() => selectedRadius = v!);
                  },
                ),

                // limit
                DropdownButton<String>(
                  value: selectedLimit,
                  items: ["5", "10", "15", "20"].map((e) {
                    return DropdownMenuItem(
                        value: e, child: Text("$e mushrooms"));
                  }).toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedLimit = v!);
                    setState(() => selectedLimit = v!);
                  },
                ),

                // species
                DropdownButton<String>(
                  value: selectedSpecies,
                  items: speciesList.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedSpecies = v!);
                    setState(() => selectedSpecies = v!);
                  },
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.9),
                    elevation: 5
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await fetchMushrooms();
                  },
                  child: const Text("Apply"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
