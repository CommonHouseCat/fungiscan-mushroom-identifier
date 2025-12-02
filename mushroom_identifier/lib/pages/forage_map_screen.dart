import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class ForageMapScreen extends StatefulWidget {
  const ForageMapScreen({super.key});

  @override
  State<ForageMapScreen> createState() => _ForageMapScreenState();
}

class _ForageMapScreenState extends State<ForageMapScreen> {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();
  LatLng? userLocation;
  bool loading = true;
  Timer? _debounceTimer;

  final List<String> speciesList = ["All Species", "Only Mushrooms"];
  List<Marker> mushroomMarkers = [];
  late String selectedMonth;
  String selectedRadius = "5";
  String selectedLimit = "20";
  String selectedSpecies = "Only Mushrooms";

  void _animateToUserLocation() {
    if (userLocation == null) return;
    _mapController.moveAndRotate(
      userLocation!,
      13.5,
      0,
    );
  }

  @override
  void initState() {
    super.initState();
    const monthAbbreviations = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    selectedMonth = monthAbbreviations[DateTime.now().month - 1];
    _loadFilterPreferences().then((_) {
      initLocation();
    });
  }

  Future<void> _loadFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selectedRadius = prefs.getString('forage_radius') ?? "5";
        selectedLimit = prefs.getString('forage_limit') ?? "20";
        selectedSpecies = prefs.getString('forage_species') ?? "Only Mushrooms";
      });
    }
  }

  // Save preferences whenever user applies filters
  Future<void> _saveFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('forage_radius', selectedRadius);
    await prefs.setString('forage_limit', selectedLimit);
    await prefs.setString('forage_species', selectedSpecies);
  }

  // -------------------------------------------------------------
  // LOCATION
  // -------------------------------------------------------------
  Future<void> initLocation() async {
    final permission = await _handlePermission();
    if (!mounted) return;
    if (!permission) {
      setState(() => loading = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    userLocation = LatLng(pos.latitude, pos.longitude);

    await fetchMushrooms();
    if (!mounted) return;

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

    String taxonFilter = "";
    if (selectedSpecies == "Only Mushrooms") {
      taxonFilter = "taxon_id=47170&"; // Fungi
    }

    String monthFilter = selectedMonth == "All"
        ? ""
        : "month=${_monthNumber(selectedMonth)}&";

    final url =
        "https://api.inaturalist.org/v1/observations?"
        "$taxonFilter"
        "$monthFilter"
        "lat=${userLocation!.latitude}&"
        "lng=${userLocation!.longitude}&"
        "radius=$selectedRadius&"
        "per_page=$selectedLimit";

    try {
      final res = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (res.statusCode != 200) {
        _showApiError("Cannot connect to API. Please try again later.");
        return;
      }

      final json = jsonDecode(res.body);
      final List results = json["results"];
      mushroomMarkers.clear();

      for (var r in results) {
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

      if (mounted) setState(() {});

    } catch (e) {
      if (!mounted) return;

      final msg = e is http.ClientException
          ? "No internet. Please try again later."
          : "Cannot connect to API. Please try again later.";

      _showApiError(msg);
    }
  }

  void _showApiError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                loading = true;
              });
              fetchMushrooms().then((_) {
                if (mounted) setState(() => loading = false);
              });
            },
            child: const Text("Retry"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }


  int _monthNumber(String m) {
    const months = {
      "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6, "Jul": 7,
      "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12,
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

    final inatUrl = item["uri"] as String?;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              common,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              species,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

            if (imageUrl == null)
              Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
              ),

            const SizedBox(height: 20),

            Text("Observed on: ${item["observed_on"] ?? 'Unknown'}"),
            const SizedBox(height: 8),

            if (inatUrl != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context,).colorScheme.tertiary.withValues(alpha: 0.9),
                  elevation: 5,
                ),
                onPressed: () async {
                  final uri = Uri.parse(inatUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text("Open Full Observation"),
              ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context,).colorScheme.tertiary.withValues(alpha: 0.9),
                elevation: 5,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // FILTER SHEET
  // -------------------------------------------------------------
  void showFilterSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  "Filter Observations",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Month
                DropdownButtonFormField<String>(
                  initialValue: selectedMonth,
                  decoration: const InputDecoration(
                    labelText: "Month",
                    border: OutlineInputBorder(),
                  ),
                  items:
                    [
                      "All", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedMonth = v!);
                    setState(() => selectedMonth = v!);
                  },
                ),
                const SizedBox(height: 16),

                // Radius
                DropdownButtonFormField<String>(
                  initialValue: selectedRadius,
                  decoration: const InputDecoration(
                    labelText: "Search Radius",
                    suffixText: " km",
                    border: OutlineInputBorder(),
                  ),
                  items: ["5", "10", "20", "50"]
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text("$e km")),
                      )
                      .toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedRadius = v!);
                    setState(() => selectedRadius = v!);
                  },
                ),
                const SizedBox(height: 16),

                // Limit
                DropdownButtonFormField<String>(
                  initialValue: selectedLimit,
                  decoration: const InputDecoration(
                    labelText: "Max Results",
                    suffixText: " Species",
                    border: OutlineInputBorder(),
                  ),
                  items: ["5", "10", "15", "20", "50", "100", "200"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedLimit = v!);
                    setState(() => selectedLimit = v!);
                  },
                ),
                const SizedBox(height: 16),

                // Species
                DropdownButtonFormField<String>(
                  initialValue: selectedSpecies,
                  decoration: const InputDecoration(
                    labelText: "Show",
                    border: OutlineInputBorder(),
                  ),
                  items: speciesList
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setSheetState(() => selectedSpecies = v!);
                    setState(() => selectedSpecies = v!);
                  },
                ),

                const SizedBox(height: 32),

                // Full-width Apply Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context,).colorScheme.tertiary.withValues(alpha: 0.9),
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    // Cancel any pending request
                    _debounceTimer?.cancel();

                    // Start a new 600ms debounce
                    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
                      await _saveFilterPreferences();

                      // Safely pop only if still mounted
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      setState(() {
                        mushroomMarkers.clear();
                        loading = true; // Optional: show spinner during refresh
                      });

                      await fetchMushrooms();

                      if (mounted) {
                      setState(() => loading = false);
                      }
                    });
                  },
                  child: const Text(
                    "Apply Filters",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userLocation == null) {
      return const Scaffold(
        body: Center(child: Text("Cannot find user location!")),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text("Forage Map", style: TextStyle(color: colorScheme.onSurface)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => showFilterSheet(context),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 62.0),
        child: FloatingActionButton(
          onPressed: _animateToUserLocation,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.my_location),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: PopupScope(
        popupController: _popupController,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLocation!,
            initialZoom: 12,
            onTap: (_, _) => _popupController.hideAllPopups(),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
              userAgentPackageName: "vn.vinh.fungiScan",
            ),
        
            MarkerLayer(
              markers: [
                Marker(
                  width: 50,
                  height: 50,
                  point: userLocation!,
                  child: const Icon(
                    Icons.person_pin_circle,
                    size: 45,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
        
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 120,
                size: const Size(40, 40),
                markers: mushroomMarkers,
                builder: (context, markers) {
                  return FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.red,
                    onPressed: null,
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
