import 'dart:async';
import '../models/maintenance_log_model.dart';

class TestMaintenanceLogService {
  // Simulated in-memory database
  static final List<MaintenanceLog> _logs = [
    MaintenanceLog(
      id: 'log1',
      itemName: 'Oil Change',
      date: DateTime.now().subtract(const Duration(days: 15)),
      hours: 0.5,
      km: 12500.0,
      notes: 'Used synthetic oil. Changed oil filter as well. Next change due at 15,000 km.',
      performedBy: 'Admin User',
      vehicleId: '1',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    MaintenanceLog(
      id: 'log2',
      itemName: 'Brake Inspection',
      date: DateTime.now().subtract(const Duration(days: 30)),
      hours: 1.0,
      km: 12000.0,
      notes: 'Front brake pads at 40% wear. Rear pads at 60%. No immediate action needed.',
      performedBy: 'Admin User',
      vehicleId: '2',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    MaintenanceLog(
      id: 'log3',
      itemName: 'Tire Rotation',
      date: DateTime.now().subtract(const Duration(days: 45)),
      hours: 0.75,
      km: 11500.0,
      notes: 'Rotated all four tires. Checked tire pressure and adjusted to recommended levels.',
      performedBy: 'Driver User',
      vehicleId: '1',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    MaintenanceLog(
      id: 'log4',
      itemName: 'Air Filter Replacement',
      date: DateTime.now().subtract(const Duration(days: 60)),
      hours: 0.25,
      km: 11000.0,
      notes: 'Replaced engine air filter. Old filter was quite dirty.',
      performedBy: 'Admin User',
      vehicleId: '3',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    MaintenanceLog(
      id: 'log5',
      itemName: 'Transmission Service',
      date: DateTime.now().subtract(const Duration(days: 90)),
      hours: 2.5,
      km: 10000.0,
      notes: 'Full transmission fluid change and filter replacement. Transmission running smoothly.',
      performedBy: 'Admin User',
      vehicleId: '2',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  static int _nextId = 6;

  // Get all maintenance logs as a stream
  Stream<List<MaintenanceLog>> getAllLogs() {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      // Simulate network delay
      final sortedLogs = List<MaintenanceLog>.from(_logs)
        ..sort((a, b) => b.date.compareTo(a.date));
      return sortedLogs;
    }).take(1);
  }

  // Get logs for a specific vehicle
  Stream<List<MaintenanceLog>> getLogsByVehicle(String vehicleId) {
    return Stream.periodic(const Duration(milliseconds: 100), (count) { // Reduced delay
      final filteredLogs = _logs
          .where((log) => log.vehicleId == vehicleId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return List<MaintenanceLog>.from(filteredLogs);
    }).take(1);
  }

  // Get logs by date range
  Stream<List<MaintenanceLog>> getLogsByDateRange(DateTime startDate, DateTime endDate) {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredLogs = _logs
          .where((log) => 
              log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              log.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return List<MaintenanceLog>.from(filteredLogs);
    }).take(1);
  }

  // Get logs by performed user
  Stream<List<MaintenanceLog>> getLogsByUser(String userId) {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredLogs = _logs
          .where((log) => log.performedBy == userId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return List<MaintenanceLog>.from(filteredLogs);
    }).take(1);
  }

  // Add a new maintenance log
  Future<String> addLog(MaintenanceLog log) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50)); // Reduced delay

    final now = DateTime.now();
    final newLog = log.copyWith(
      id: 'log${_nextId++}',
      createdAt: now,
      updatedAt: now,
    );

    _logs.add(newLog);
    return newLog.id!;
  }

  // Update an existing maintenance log
  Future<void> updateLog(MaintenanceLog log) async {
    if (log.id == null) {
      throw Exception('Cannot update log without an ID');
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      _logs[index] = log.copyWith(updatedAt: DateTime.now());
    } else {
      throw Exception('Log not found');
    }
  }

  // Delete a maintenance log
  Future<void> deleteLog(String logId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _logs.indexWhere((log) => log.id == logId);
    if (index != -1) {
      _logs.removeAt(index);
    } else {
      throw Exception('Log not found');
    }
  }

  // Get a single log by ID
  Future<MaintenanceLog?> getLogById(String logId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _logs.firstWhere((log) => log.id == logId);
    } catch (e) {
      return null;
    }
  }

  // Search logs by item name
  Stream<List<MaintenanceLog>> searchLogsByItemName(String searchTerm) {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredLogs = _logs
          .where((log) => 
              log.itemName.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return List<MaintenanceLog>.from(filteredLogs);
    }).take(1);
  }

  // Get maintenance statistics
  Future<Map<String, dynamic>> getMaintenanceStatistics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    double totalHours = _logs.fold(0, (sum, log) => sum + log.hours);
    double totalKm = _logs.fold(0, (sum, log) => sum + log.km);
    int totalLogs = _logs.length;

    // Group by item name for most common maintenance items
    Map<String, int> itemCounts = {};
    for (var log in _logs) {
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
  }

  // Get recent maintenance activity (last 7 days)
  Stream<List<MaintenanceLog>> getRecentActivity() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return getLogsByDateRange(weekAgo, DateTime.now());
  }

  // Get logs that might need follow-up (based on notes containing keywords)
  Stream<List<MaintenanceLog>> getLogsNeedingFollowUp() {
    final keywords = ['due', 'replace', 'check', 'monitor', 'schedule'];
    
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredLogs = _logs
          .where((log) => 
              keywords.any((keyword) => 
                  log.notes.toLowerCase().contains(keyword)))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)); // Oldest first for follow-up
      return List<MaintenanceLog>.from(filteredLogs);
    }).take(1);
  }
}
