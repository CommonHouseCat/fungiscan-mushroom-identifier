import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/mushroom_info_item.dart';
import '../services/database_service.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DatabaseService _databaseService;
  List<Map<String, dynamic>> _mushroomInfoHistory = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _sortType = 'Date';


  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadSortPreference();
    _fetchMushroomInfoHistory();
  }

  void _sortHistory() {
    _mushroomInfoHistory.sort((a, b) {
      final aBookmark = a[DatabaseService.columnIsBookMark] == 1;
      final bBookmark = b[DatabaseService.columnIsBookMark] == 1;

      if (aBookmark != bBookmark) {
        return bBookmark ? 1 : -1;
      }

      if (_sortType == 'Name') {
        final aName = _extractName(a[DatabaseService.columnBasicInfo]);
        final bName = _extractName(b[DatabaseService.columnBasicInfo]);
        return aName.compareTo(bName);
      } else {
        final aDate = DateTime.parse(a[DatabaseService.columnDateOfCreation]);
        final bDate = DateTime.parse(b[DatabaseService.columnDateOfCreation]);
        return bDate.compareTo(aDate);
      }
    });
  }


  String _extractName(String? basicInfo) {
    if (basicInfo == null) return '';
    try {
      final map = jsonDecode(basicInfo);
      return map['common_name'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSort = prefs.getString('sortType');
    if (savedSort != null && mounted) {
      setState(() {
        _sortType = savedSort;
      });
    }
  }

  Future<void> _toggleBookmark(int id, int index) async {
    try {
      // Find actual item by ID to prevent wrong toggling after sorting
      final int itemIndex = _mushroomInfoHistory.indexWhere(
              (item) => item[DatabaseService.columnId] == id);
      if (itemIndex == -1) return; // safety check

      final currentState =
          _mushroomInfoHistory[itemIndex][DatabaseService.columnIsBookMark] == 1;

      // Update database first
      await _databaseService.toggleBookmark(id, currentState);

      // Update in-memory list safely
      setState(() {
        _mushroomInfoHistory[itemIndex] = {
          ..._mushroomInfoHistory[itemIndex],
          DatabaseService.columnIsBookMark: currentState ? 0 : 1,
        };

        // Ensure bookmarked items always appear first
        _mushroomInfoHistory.sort((a, b) {
          final int aBookmark = a[DatabaseService.columnIsBookMark] ?? 0;
          final int bBookmark = b[DatabaseService.columnIsBookMark] ?? 0;
          if (aBookmark != bBookmark) return bBookmark - aBookmark;
          final aDate =
          DateTime.parse(a[DatabaseService.columnDateOfCreation]);
          final bDate =
          DateTime.parse(b[DatabaseService.columnDateOfCreation]);
          return bDate.compareTo(aDate);
        });
      });
    } catch (e) {
      debugPrint("Error toggling bookmark: $e");
    }
  }

  Future<void> _fetchMushroomInfoHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _databaseService.getAllMushroomsInfo();
      if (mounted) {
        setState(() {
          _mushroomInfoHistory = List<Map<String, dynamic>>.from(data);
          _sortHistory();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching mushroom info history: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching mushroom info history: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMushroom(int id, int indexInList) async {
    try {
      if (mounted) {
        final newList = List<Map<String, dynamic>>.from(_mushroomInfoHistory);
        newList.removeAt(indexInList);
        setState(() {
          _mushroomInfoHistory = newList;
        });
      }
      await _databaseService.deleteMushroomInfo(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mushroom entry deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting mushroom: $e");
      if (mounted) {
        _fetchMushroomInfoHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete entry: $e. Please refresh.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyMushroom(Map<String, dynamic> mushroom) async {
    try {
      final buffer = StringBuffer()
        ..writeln('🧠 Confidence Score: ${((mushroom[DatabaseService.columnConfidenceScore] as double) * 100).toStringAsFixed(2)}%')
        ..writeln('\n📘 Basic Information:')
        ..writeln(mushroom[DatabaseService.columnBasicInfo])
        ..writeln('\n🧩 Physical Characteristics:')
        ..writeln(mushroom[DatabaseService.columnPhysicalCharacteristics])
        ..writeln('\n🔍 Look-Alike:')
        ..writeln(mushroom[DatabaseService.columnLookAlike])
        ..writeln('\n🍄 Usages:')
        ..writeln(mushroom[DatabaseService.columnUsages])
        ..writeln('\n⚠️ Safety Tips:')
        ..writeln(mushroom[DatabaseService.columnSafetyTips]);

      await Clipboard.setData(ClipboardData(text: buffer.toString()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mushroom information copied to clipboard.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying mushroom info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMushroomInfoHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
              child: Text('Retry',style: TextStyle(color: colorScheme.onPrimary)),
            ),
          ],
        ),
      );
    }

    if (_mushroomInfoHistory.isEmpty) {
      return Center(
        child: Text(
          'No mushroom entries found.',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0,16.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Sort by:',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(width: 8.0),
              DropdownButton<String>(
                  value: _sortType,
                  items: [
                    DropdownMenuItem(value: 'Date', child: Text('Date', style: TextStyle(color: colorScheme.onSurface))),
                    DropdownMenuItem(value: 'Name', child: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('sortType', value);

                    setState(() {
                      _sortType = value;
                      _sortHistory();
                    });
                  }
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: _mushroomInfoHistory.length,
            itemBuilder: (context, index) {
              final item = _mushroomInfoHistory[index];
              final int? itemId = item[DatabaseService.columnId] as int?;
              if (itemId == null) {
                return const ListTile(title: Text('Error: Invalid ID'));
              }

              return MushroomInfoItem(
                key: ValueKey(itemId),
                item: item,
                onDelete: () => _deleteMushroom(itemId, index),
                onCopy: () => _copyMushroom(item),
                onToggleBookmark: () => _toggleBookmark(itemId, index),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text(
          "History",
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _isLoading ? null : _fetchMushroomInfoHistory,
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
