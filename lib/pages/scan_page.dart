import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'result_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../services/history_service.dart';

// Allows user to capture image using camera
// Upload picture from gallery
// Send image to AI model for prediction
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isAnalyzing = false;

  //Image File
  File? image;

  //Image picker
  final picker = ImagePicker();

  //Laptop IP
  static const String apiUrl= 'http://172.20.10.2:8000/predict';

  //Pick Image Method
  Future<void> pickImage(ImageSource source) async {
    // Pick rom camera or gallery
    final pickedFile = await picker .pickImage(source: source);

    //Updated selected image
    if (pickedFile != null) {
      setState(() {
        image = File (pickedFile.path);
      });
    }
  }

  static const lightBlue = Color(0xDFAAD4F6);
  static const darkBlue = Color(0xFF144AB5);

  // Map raw label from API to UI display name and color
  _LabelUI _mapLabelToUI(String raw) {
    final l = raw.toLowerCase();

    if (l.contains('healthy')) return _LabelUI('Healthy', Colors.green);
    if (l.contains('blister')) return _LabelUI('Blister', Colors.amber);
    if (l.contains('corn') || l.contains('callus')) {
      return _LabelUI('Corn & Callus', Colors.amber);
    }
    if (l.contains('ulcer')) return _LabelUI('Ulcer', Colors.orange);
    if (l.contains('gangrene')) return _LabelUI('Gangrene', Colors.red);

    return _LabelUI(raw, Colors.grey);
  }

  // AI prediction logic
  // Sends image to AI prediction API
  Future<void> _analyzeImage() async {
    if (image == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // Create request to API
      final uri = Uri.parse(apiUrl);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('file', image!.path));

      // Send request to server
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception(
            'Server error ${response.statusCode}: ${response.body}');
      }

      // Parse JSON response from AI model
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final rawLabel = data['label'].toString();
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;

      // Convert raw label into UI label
      final mapped = _mapLabelToUI(rawLabel);

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      // Minimum Confidence Threshold
      const double threshold = 0.65;

      if (confidence < threshold) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => ResultPage(
              disease: 'Uncertain (Retake photo / Crop closer)',
              confidence: confidence,
              color: Colors.blueGrey,
            ),
          ),
        );
        return;
      }

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Not logged in");
      }

      // Navigation first
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            disease: mapped.displayName,
            confidence: confidence,
            color: mapped.color,
          ),
        ),
      );

      // Save history
       HistoryService.saveScan(
         uid: user.uid,
         imageFile: image!,
         disease: mapped.displayName,
         confidence: confidence,
       ).then((_) {
         debugPrint("History saved successfully");
       }).catchError((e) {
         debugPrint("History save failed: $e");
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("History save failed: $e")),
         );
       });

    } catch (e){
      if(!mounted) return;
      setState(() => _isAnalyzing = false);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prediction failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
          foregroundColor: Colors.white,
        toolbarHeight: 80,
        title: const Text(
              'Foot Scan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
          ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Capture or upload an image of the affected area.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

            // Image preview container
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: image == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/foot_image.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
                    : Image.file(
                  image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Camera & Gallery buttons (light blue)

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Analyze button (dark blue)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_isAnalyzing || image == null) ? null : _analyzeImage,
                child: _isAnalyzing
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Analyze Image',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Medical Disclaimer with info icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: Color(0xFF186DE1)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Medical Disclaimer: This application is intended for awareness and educational purposes only. It does not replace professional medical diagnosis or treatment.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelUI {
  final String displayName;
  final Color color;
  _LabelUI(this.displayName, this.color);
}