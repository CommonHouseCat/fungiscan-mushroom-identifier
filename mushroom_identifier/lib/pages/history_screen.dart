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
    _loadSortPreference().then((_) {
      _fetchMushroomInfoHistory();
    });
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('history_sort_type') ?? 'Date';
    if (mounted) setState(() => _sortType = saved);
  }

  Future<void> _saveSortPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('history_sort_type', value);
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
          _isLoading = false;
        });
        _sortHistory();
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

  Future<void> _toggleBookmark(int id, int index) async {
    try {
      final int itemIndex = _mushroomInfoHistory.indexWhere(
        (item) => item[DatabaseService.columnId] == id,
      );
      if (itemIndex == -1) return;

      final currentState =
          _mushroomInfoHistory[itemIndex][DatabaseService.columnIsBookMark] ==
          1;
      await _databaseService.toggleBookmark(id, currentState);
      setState(() {
        _mushroomInfoHistory[itemIndex] = {
          ..._mushroomInfoHistory[itemIndex],
          DatabaseService.columnIsBookMark: currentState ? 0 : 1,
        };
        _mushroomInfoHistory.sort((a, b) {
          final int aBookmark = a[DatabaseService.columnIsBookMark] ?? 0;
          final int bBookmark = b[DatabaseService.columnIsBookMark] ?? 0;
          if (aBookmark != bBookmark) return bBookmark - aBookmark;
          final aDate = DateTime.parse(a[DatabaseService.columnDateOfCreation]);
          final bDate = DateTime.parse(b[DatabaseService.columnDateOfCreation]);
          return bDate.compareTo(aDate);
        });
      });
    } catch (e) {
      debugPrint("Error toggling bookmark: $e");
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
          SnackBar(
            content: const Text('Mushroom entry deleted.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2, microseconds: 100),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2, microseconds: 100),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _copyMushroom(Map<String, dynamic> mushroom) async {
    try {
      final buffer = StringBuffer()
        ..writeln(
          '🧠 Confidence Score: ${((mushroom[DatabaseService.columnConfidenceScore] as double) * 100).toStringAsFixed(2)}%',
        )
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
    } catch (e) {
      debugPrint('Error copying mushroom info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2, microseconds: 100),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showSortSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              "Sort History",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            RadioGroup<String>(
              groupValue: _sortType,
              onChanged: (val) => _applySort(val!) ,
              child: Column(
                children: <Widget>[
                  RadioListTile<String>(
                    value: 'Date',
                    title: Text(
                      "Date (Newest First)",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      "Most recent scans appear first",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),

                  RadioListTile<String>(
                    value: 'Name',
                    title: Text(
                      "Name (A → Z)",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      "Alphabetical by common or scientific name",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: 0.9),
                  elevation: 5,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _applySort(String value) async {
    await _saveSortPreference(value);
    if (mounted) {
      setState(() => _sortType = value);
      _sortHistory();
      Navigator.pop(context);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMushroomInfoHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_mushroomInfoHistory.isEmpty) {
      return const Center(
        child: Text(
          'No mushroom entries found.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: _mushroomInfoHistory.length,
        itemBuilder: (context, index) {
          final item = _mushroomInfoHistory[index];
          final int? itemId = item[DatabaseService.columnId] as int?;
          if (itemId == null) return const SizedBox.shrink();

          return MushroomInfoItem(
            key: ValueKey(itemId),
            item: item,
            onDelete: () => _deleteMushroom(itemId, index),
            onCopy: () => _copyMushroom(item),
            onToggleBookmark: () => _toggleBookmark(itemId, index),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.tertiary,
        title: Text("History", style: TextStyle(color: colorScheme.onSurface)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort),
            color: colorScheme.onSurface,
            tooltip: "Sort History",
            onPressed: _showSortSheet,
          ),
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
