import 'package:flutter/material.dart';

// Display educational tips for foot care
class HealthTipsPage extends StatelessWidget {
  const HealthTipsPage({super.key});

  static const darkBlue = Color(0xFF144AB5);
  static const lightBlue = Color(0xFFAAD4F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Foot Care Tips',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why Foot Care Matters ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Diabetes can reduce blood flow and nerve sensation in the feet. '
                    'Small injuries may go unnoticed and can become serious if untreated. '
                    'Daily foot care helps detect complications early and avoid amputation.',
                style: TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Daily Foot Care Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 15),

            _noteCard(
              backgroundColor: darkBlue.withValues(alpha: 0.15),
              icon: Icons.search,
              title: 'Inspect Feet Daily',
              content:
              'Check for cuts, redness, swelling, blisters, or skin changes. '
                  'Use a mirror if necessary.',
            ),

            _noteCard(
              backgroundColor: lightBlue.withValues(alpha: 0.35),
              icon: Icons.water_drop_outlined,
              title: 'Wash and Dry Carefully',
              content:
              'Wash with lukewarm water and mild soap. Dry thoroughly, especially between toes.',
            ),

            _noteCard(
              backgroundColor: darkBlue.withValues(alpha: 0.15),
              icon: Icons.spa_outlined,
              title: 'Moisturize',
              content:
              'Apply lotion to prevent dry skin and cracks, but avoid applying between toes.',
            ),

            _noteCard(
              backgroundColor: lightBlue.withValues(alpha: 0.35),
              icon: Icons.hiking_outlined,
              title: 'Wear Proper Shoes',
              content:
              'Avoid walking barefoot. Wear comfortable, well-fitting shoes to prevent injuries.',
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If you notice open wounds, blackened skin, severe swelling, bad odor or strong pain, seek medical advice from a healthcare professional.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _noteCard({
    required Color backgroundColor,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: darkBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
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