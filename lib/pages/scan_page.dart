import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _isAnalyzing = false);


    // To remove later when implementing model
    final results = [
      {'name': 'Healthy', 'color': Colors.green},
      {'name': 'Blister / Corn & Callus', 'color': Colors.amber},
      {'name': 'Ulcer', 'color': Colors.orange},
      {'name': 'Gangrene', 'color': Colors.red},
    ];

    final mockResult = results[Random().nextInt(results.length)];
    final confidence = 70 + Random().nextInt(29);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          disease: mockResult['name'] as String,
          confidence: confidence.toDouble(),
          color: mockResult['color'] as Color,
        ),
      ),
    );
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