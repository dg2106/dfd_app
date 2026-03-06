import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class HistoryService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveScan({
    required String uid,
    required File imageFile,
    required String disease,
    required double confidence,
  }) async {
    final scanId = _db.collection('tmp').doc().id;

    // Copy image to app's local storage
    final dir = await getApplicationDocumentsDirectory();
    final savedPath = '${dir.path}/history_$scanId.jpg';
    final savedFile = await imageFile.copy(savedPath);
    final now = DateTime.now();

    // Save metadata + local path in Firestore
    await _db.collection('users').doc(uid).collection('history').doc(scanId).set({
      'localImagePath': savedFile.path,
      'disease': disease,
      'confidence': confidence,
      'createdAt': Timestamp.fromDate(now),
      'dateText': DateFormat('MMM d, yyyy • HH:mm').format(now),
    });
  }
}