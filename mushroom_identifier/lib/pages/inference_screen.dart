import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'inference_result_screen.dart';

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
  bool _isLoading = true;
  String? _error;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InferenceResultScreen(
            predictedClass: data['predicted_class'],
            predictedIndex: data['index'],
            confidence: data['confidence'],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Running inference")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Error: $_error"),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}