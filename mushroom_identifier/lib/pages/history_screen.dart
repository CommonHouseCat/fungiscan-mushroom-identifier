import 'package:flutter/material.dart';

import '../components/mushroom_info_item.dart';
import '../services/database_service.dart';

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

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _fetchMushroomInfoHistory();
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

  Future<void> _copyMushroom() async {
    // does nothing for now
  }

  Future<void> _shareMushroom() async {
    // does nothing for now
  }

  // Helper widget to build the body
  Widget _buildBody() {
    // Loading Icon
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // Show error message and retry button
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
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

    // Show this if no entry is found
    if (_mushroomInfoHistory.isEmpty) {
      return const Center(
        child: Text(
          'No mushroom entries found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
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
          onCopy: _copyMushroom,
          onShare: _shareMushroom,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchMushroomInfoHistory,
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
