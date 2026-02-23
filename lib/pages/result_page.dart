import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String disease;
  final double confidence;
  final Color color;

  const ResultPage({
    super.key,
    required this.disease,
    required this.confidence,
    required this.color,
  });

  static const darkBlue = Color(0xFF144AB5);


  double _confidencePercent(double c) {
    if (c <= 1.0) return (c * 100).clamp(0.0, 100.0);
    return c.clamp(0.0, 100.0);
  }

  // Confidence UI color logic
  Color _confidenceColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.amber;
    return Colors.red;
  }

  String _severityLabel(String diseaseName) {
    final d = diseaseName.toLowerCase();
    if (d.contains('healthy')) return 'Low risk';
    if (d.contains('blister') || d.contains('corn') || d.contains('callus')) {
      return 'Moderate risk';
    }
    if (d.contains('ulcer')) return 'High risk';
    if (d.contains('gangrene')) return 'Critical';
    return 'Unknown';
  }

  IconData _severityIcon(String diseaseName) {
    final d = diseaseName.toLowerCase();
    if (d.contains('healthy')) return Icons.check_circle_outline;
    if (d.contains('blister') || d.contains('corn') || d.contains('callus')) {
      return Icons.info_outline;
    }
    if (d.contains('ulcer')) return Icons.warning_amber_rounded;
    if (d.contains('gangrene')) return Icons.report_problem_outlined;
    return Icons.help_outline;
  }

  static String _infoText(String diseaseName) {
    final d = diseaseName.toLowerCase();
    if (d.contains('healthy')) {
      return 'No visible signs of diabetic foot complications were detected. Continue daily foot checks and maintain good hygiene.';
    }
    if (d.contains('blister') || d.contains('corn') || d.contains('callus')) {
      return 'Possible pressure or friction-related changes. Monitor the area, avoid tight shoes, and consider professional advice if it worsens.';
    }
    if (d.contains('ulcer')) {
      return 'Possible ulcer-like appearance. Ulcers can become serious. Seek medical advice from a healthcare professional.';
    }
    if (d.contains('gangrene')) {
      return 'Possible severe tissue damage. This may require urgent medical attention. Seek medical advice immediately.';
    }
    return 'This result is informational only. If you are concerned, consult a healthcare professional.';
  }

  @override
  Widget build(BuildContext context) {
    final percent = _confidencePercent(confidence);
    final confColor = _confidenceColor(percent);

    final sevLabel = _severityLabel(disease);
    final sevIcon = _severityIcon(disease);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Analysis Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(sevIcon, color: color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prediction',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          disease,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sevLabel,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Confidence section with dynamic color progress bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confidence',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: percent / 100.0,
                            minHeight: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(confColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: confColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Higher confidence means the model is more certain about the prediction.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Interactive expandable info
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.lightbulb_outline, color: darkBlue),
                title: const Text(
                  'What this means (tap to expand)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      _infoText(disease),
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

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
                  Icon(Icons.info_outline, size: 20, color: darkBlue),
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

            const SizedBox(height: 22),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: darkBlue.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan Again',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}