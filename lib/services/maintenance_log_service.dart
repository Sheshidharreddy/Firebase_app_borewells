import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_log_model.dart';

class MaintenanceLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'logs';

  // Get all maintenance logs as a stream
  Stream<List<MaintenanceLog>> getAllLogs() {
    return _firestore
        .collection(collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get logs for a specific vehicle
  Stream<List<MaintenanceLog>> getLogsByVehicle(String vehicleId) {
    return _firestore
        .collection(collectionName)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get logs by date range
  Stream<List<MaintenanceLog>> getLogsByDateRange(DateTime startDate, DateTime endDate) {
    return _firestore
        .collection(collectionName)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get logs by performed user
  Stream<List<MaintenanceLog>> getLogsByUser(String userId) {
    return _firestore
        .collection(collectionName)
        .where('performedBy', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Add a new maintenance log
  Future<String> addLog(MaintenanceLog log) async {
    try {
      final now = DateTime.now();
      final logWithTimestamps = log.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      
      final docRef = await _firestore
          .collection(collectionName)
          .add(logWithTimestamps.toMap());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add maintenance log: $e');
    }
  }

  // Update an existing maintenance log
  Future<void> updateLog(MaintenanceLog log) async {
    if (log.id == null) {
      throw Exception('Cannot update log without an ID');
    }

    try {
      final updatedLog = log.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(collectionName)
          .doc(log.id)
          .update(updatedLog.toMap());
    } catch (e) {
      throw Exception('Failed to update maintenance log: $e');
    }
  }

  // Delete a maintenance log
  Future<void> deleteLog(String logId) async {
    try {
      await _firestore.collection(collectionName).doc(logId).delete();
    } catch (e) {
      throw Exception('Failed to delete maintenance log: $e');
    }
  }

  // Get a single log by ID
  Future<MaintenanceLog?> getLogById(String logId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(logId).get();
      if (doc.exists) {
        return MaintenanceLog.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get maintenance log: $e');
    }
  }

  // Search logs by item name
  Stream<List<MaintenanceLog>> searchLogsByItemName(String searchTerm) {
    return _firestore
        .collection(collectionName)
        .where('itemName', isGreaterThanOrEqualTo: searchTerm)
        .where('itemName', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .orderBy('itemName')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get maintenance statistics
  Future<Map<String, dynamic>> getMaintenanceStatistics() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      final logs = snapshot.docs
          .map((doc) => MaintenanceLog.fromMap(doc.id, doc.data()))
          .toList();

      double totalHours = logs.fold(0, (sum, log) => sum + log.hours);
      double totalKm = logs.fold(0, (sum, log) => sum + log.km);
      int totalLogs = logs.length;

      // Group by item name for most common maintenance items
      Map<String, int> itemCounts = {};
      for (var log in logs) {
        itemCounts[log.itemName] = (itemCounts[log.itemName] ?? 0) + 1;
      }

      // Get top 5 maintenance items
      var sortedItems = itemCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var topItems = sortedItems.take(5).toList();

      return {
        'totalLogs': totalLogs,
        'totalHours': totalHours,
        'totalKm': totalKm,
        'averageHours': totalLogs > 0 ? totalHours / totalLogs : 0,
        'averageKm': totalLogs > 0 ? totalKm / totalLogs : 0,
        'topMaintenanceItems': topItems,
      };
    } catch (e) {
      throw Exception('Failed to get maintenance statistics: $e');
    }
  }
}
