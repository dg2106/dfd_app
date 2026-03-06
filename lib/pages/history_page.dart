import 'dart:io';
import 'package:flutter/material.dart';
import 'result_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Displays previous scan results stored in Firebase Firestore
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const lightBlue = Color(0xFFAAD4F6);
  static const darkBlue = Color(0xFF144AB5);

  @override
  Widget build(BuildContext context) {

    // Currently logged-in user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    // History data from Firestore
    final historyStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: historyStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _EmptyHistory(onStartScan: () => Navigator.pop(context));
          }

          final items = docs.map((doc) {
            final data = doc.data();
            final disease = (data['disease'] ?? 'Unknown').toString();
            final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
            final localPath = data['localImagePath']?.toString();

            final percent = (confidence <= 1.0 ? confidence * 100 : confidence)
                .clamp(0, 100)
                .toDouble();

            String formattedDate = (data['dateText'] ?? '').toString();

            if (formattedDate.isEmpty) {
              final timestamp = data['createdAt'] as Timestamp?;
              if (timestamp != null) {
                final date = timestamp.toDate();
                formattedDate =
                    DateFormat('MMM d, yyyy • HH:mm').format(date);
              }
            }

            return HistoryItem(
              disease: disease,
              confidencePercent: percent,
              dateText: formattedDate,
              color: _diseaseColor(disease),
              localImagePath: localPath,
            );
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _HistoryCard(
              item: items[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultPage(
                      disease: items[index].disease,
                      confidence: items[index].confidencePercent / 100,
                      color: _diseaseColor(items[index].disease),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _diseaseColor(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('healthy')) return Colors.green;
    if (d.contains('blister') || d.contains('corn') || d.contains('callus')) return Colors.amber;
    if (d.contains('ulcer')) return Colors.orange;
    if (d.contains('gangrene')) return Colors.red;
    return Colors.grey;
  }

}

class HistoryItem {
  final String disease;
  final double confidencePercent;
  final String dateText;
  final Color color;
  final String? localImagePath;

  HistoryItem({
    required this.disease,
    required this.confidencePercent,
    required this.dateText,
    required this.color,
    this.localImagePath,
  });
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.onTap,
  });

  static const darkBlue = Color(0xFF144AB5);

  Color _confidenceColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final confColor = _confidenceColor(item.confidencePercent);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Colored stripe (disease color)
            Container(
              width: 10,
              height: 86,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    // Thumbnail placeholder
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.localImagePath  == null
                          ? const Icon(Icons.image_outlined, color: Colors.grey)
                          : Image.file(
                              File(item.localImagePath!),
                              fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.disease,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: item.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.dateText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Confidence chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: confColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: confColor.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              'Confidence: ${item.confidencePercent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: confColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trailing chevron
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final VoidCallback onStartScan;

  const _EmptyHistory({required this.onStartScan});

  static const lightBlue = Color(0xFFAAD4F6);
  static const darkBlue = Color(0xFF144AB5);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: lightBlue.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.history, size: 38, color: darkBlue),
            ),
            const SizedBox(height: 14),
            const Text(
              'No scans yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your scan results will appear here after you analyze an image.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),


            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Use the Scan tab below to start scanning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
