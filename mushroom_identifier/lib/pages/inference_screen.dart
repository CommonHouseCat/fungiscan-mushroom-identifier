import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/database_service.dart';
import 'mushroom_information_screen.dart';

class InferenceScreen extends StatefulWidget {
  final String imagePath;
  final String serverUrl;

  const InferenceScreen({
    super.key,
    required this.imagePath,
    required this.serverUrl,
  });

  @override
  State<InferenceScreen> createState() => _InferenceScreenState();
}

class _InferenceScreenState extends State<InferenceScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  String? _error;

  Future<Uint8List?> _getCachedImage() async {
    final box = Hive.box('cache');
    return box.get('edited_image') as Uint8List?;
  }

  Future<void> _cleanup() async {
    final box = Hive.box('cache');
    box.delete('edited_image');
  }

  @override
  void initState() {
    super.initState();
    _runInference();
  }

  Future<void> _runInference() async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'data': await MultipartFile.fromFile(widget.imagePath),
      });

      final response = await dio.post(
        widget.serverUrl,
        data: formData,
        options: Options(
          headers: {'Authorization': dotenv.env['API_TOKEN']},
          contentType: 'multipart/form-data',
        ),
      );

      if (!mounted) return;
      final data = response.data as Map<String, dynamic>;
      final predictedClass = data['predicted_class'] as String;
      final confidence = double.tryParse(data['confidence'].toString().replaceAll('%', '')) ?? 0.0;

      final String jsonString = await rootBundle.loadString('assets/mushroom_info.json');
      final Map<String, dynamic> allInfo = jsonDecode(jsonString);
      final Map<String, dynamic>? mushroomInfo = allInfo[predictedClass];

      if (mushroomInfo == null) {
        throw Exception('No info found for class: $predictedClass');
      }

      final Uint8List? cachedImage = await _getCachedImage();
      if (cachedImage == null) {
        throw Exception("No cached image found in Hive.");
      }

      await _databaseService.insertMushroomInfo(
        imageBytes: cachedImage,
        confidenceScore: confidence / 100.0,
        basicInfo: jsonEncode(mushroomInfo['basic_info']),
        physicalCharacteristics: mushroomInfo['physical_characteristics'] ?? 'N/A',
        lookAlike: mushroomInfo['look_alike'] ?? 'N/A',
        usages: mushroomInfo['usages'] ?? 'N/A',
        safetyTips: mushroomInfo['safety_tips'] ?? 'N/A',
        wikipediaUrl: mushroomInfo['search_metadata']['wikipedia_url'] ?? 'N/A',
      );

      await _cleanup();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MushroomInformationScreen(
            mushroomData: {
              DatabaseService.columnImage: cachedImage,
              DatabaseService.columnConfidenceScore: confidence / 100.0,
              DatabaseService.columnBasicInfo: jsonEncode(mushroomInfo['basic_info']),
              DatabaseService.columnPhysicalCharacteristics: mushroomInfo['physical_characteristics'] ?? 'N/A',
              DatabaseService.columnLookAlike: mushroomInfo['look_alike'] ?? 'N/A',
              DatabaseService.columnUsages: mushroomInfo['usages'] ?? 'N/A',
              DatabaseService.columnSafetyTips: mushroomInfo['safety_tips'] ?? 'N/A',
              DatabaseService.columnWikipedia: mushroomInfo['search_metadata']['wikipedia_url'] ?? 'N/A',
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String friendlyMessage;

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            friendlyMessage = "Server is taking too long to respond.\nPlease try again later.";
            break;
          case DioExceptionType.connectionError:
            friendlyMessage = "No internet connection.\nPlease check your network and try again.";
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              friendlyMessage = "Inference server not found.\nPlease contact admin and try again later.";
            }  else if (statusCode == 500) {
              friendlyMessage = "Server error occurred.\nPlease try again later.";
            } else {
              friendlyMessage = "Server returned an error ($statusCode).\nPlease try again.";
            }
            break;
          default:
            friendlyMessage = "Failed to connect to server.\nPlease check your internet connection.";
        }
      } else {
        friendlyMessage = e.toString().contains('not found')
            ? "Mushroom not recognized.\nTry taking a clearer photo."
            : "An unexpected error occurred.\nPlease try again.";
      }

      setState(() {
        _error = friendlyMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
          title: Text(
              "Running inference",
              style: TextStyle(color: colorScheme.onSurface),
          ),
        backgroundColor: colorScheme.tertiary,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: colorScheme.primary)
            : _error != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Error: $_error",
              style: TextStyle(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}