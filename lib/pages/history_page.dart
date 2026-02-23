import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const lightBlue = Color(0xFFAAD4F6);
  static const darkBlue = Color(0xFF144AB5);

  @override
  Widget build(BuildContext context) {

    final List<HistoryItem> items = [
      HistoryItem(
        disease: 'Healthy',
        confidencePercent: 98.0,
        dateText: 'Feb 17, 2026 • 10:12',
        color: Colors.green,
      ),
      HistoryItem(
        disease: 'Ulcer',
        confidencePercent: 85.0,
        dateText: 'Feb 10, 2026 • 15:40',
        color: Colors.orange,
      ),
    ];

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
      body: items.isEmpty
          ? _EmptyHistory(
        onStartScan: () {
          // If you want: Navigate to Scan tab later.
          Navigator.pop(context);
        },
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _HistoryCard(
            item: item,
            onTap: () {
              // Later you can open a "History Details" page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Open details (UI only): ${item.disease}')),
              );
            },
          );
        },
      ),
    );
  }
}


class HistoryItem {
  final String disease;
  final double confidencePercent; // e.g., 85.0
  final String dateText; // keep as string for now; later use DateTime
  final Color color;
  final String? imageUrl; // for Firebase Storage later (optional)

  HistoryItem({
    required this.disease,
    required this.confidencePercent,
    required this.dateText,
    required this.color,
    this.imageUrl,
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
                    // Thumbnail placeholder (Firebase: swap to Image.network(item.imageUrl))
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
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
                    const Icon(Icons.chevron_right, color: darkBlue),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onStartScan,
              child: const Text('Start a Scan', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}