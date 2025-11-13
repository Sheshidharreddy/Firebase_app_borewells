import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MaintenanceType { time, mileage, hours, both }
enum MaintenancePriority { low, medium, high, critical }
enum MaintenanceStatus { upcoming, due, overdue, completed }

class MaintenanceItem {
  final String? id;
  final String vehicleId;
  final String itemName;
  final String description;
  final MaintenanceType type;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  
  // Scheduling intervals
  final int? intervalDays;     // For time-based maintenance
  final double? intervalKm;    // For mileage-based maintenance
  final double? intervalHours; // For hours-based maintenance
  
  // Current values
  final double currentKm;
  final double currentHours;
  final DateTime lastPerformed;
  final DateTime nextDue;
  
  // Additional info
  final String? notes;
  final double? estimatedCost;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceItem({
    this.id,
    required this.vehicleId,
    required this.itemName,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    this.intervalDays,
    this.intervalKm,
    this.intervalHours,
    required this.currentKm,
    required this.currentHours,
    required this.lastPerformed,
    required this.nextDue,
    this.notes,
    this.estimatedCost,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create MaintenanceItem from Firestore document
  factory MaintenanceItem.fromMap(String id, Map<String, dynamic> map) {
    return MaintenanceItem(
      id: id,
      vehicleId: map['vehicleId'] ?? '',
      itemName: map['itemName'] ?? '',
      description: map['description'] ?? '',
      type: MaintenanceType.values.firstWhere(
        (e) => e.toString() == 'MaintenanceType.${map['type']}',
        orElse: () => MaintenanceType.time,
      ),
      priority: MaintenancePriority.values.firstWhere(
        (e) => e.toString() == 'MaintenancePriority.${map['priority']}',
        orElse: () => MaintenancePriority.medium,
      ),
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.toString() == 'MaintenanceStatus.${map['status']}',
        orElse: () => MaintenanceStatus.upcoming,
      ),
      intervalDays: map['intervalDays'],
      intervalKm: (map['intervalKm'] as num?)?.toDouble(),
      intervalHours: (map['intervalHours'] as num?)?.toDouble(),
      currentKm: (map['currentKm'] ?? 0.0).toDouble(),
      currentHours: (map['currentHours'] ?? 0.0).toDouble(),
      lastPerformed: (map['lastPerformed'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextDue: (map['nextDue'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble(),
      assignedTo: map['assignedTo'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert MaintenanceItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'itemName': itemName,
      'description': description,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'intervalDays': intervalDays,
      'intervalKm': intervalKm,
      'intervalHours': intervalHours,
      'currentKm': currentKm,
      'currentHours': currentHours,
      'lastPerformed': Timestamp.fromDate(lastPerformed),
      'nextDue': Timestamp.fromDate(nextDue),
      'notes': notes,
      'estimatedCost': estimatedCost,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate days until due
  int get daysUntilDue {
    final now = DateTime.now();
    return nextDue.difference(now).inDays;
  }

  // Check if maintenance is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(nextDue);
  }

  // Check if maintenance is due soon (within 7 days)
  bool get isDueSoon {
    final daysUntil = daysUntilDue;
    return !isOverdue && daysUntil <= 7;
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.upcoming:
        return Colors.blue;
      case MaintenanceStatus.due:
        return Colors.orange;
      case MaintenanceStatus.overdue:
        return Colors.red;
    }
  }

  // Get priority color
  Color get priorityColor {
    switch (priority) {
      case MaintenancePriority.low:
        return Colors.green;
      case MaintenancePriority.medium:
        return Colors.orange;
      case MaintenancePriority.high:
        return Colors.red;
      case MaintenancePriority.critical:
        return Colors.purple;
    }
  }

  // Calculate next maintenance date based on current values
  DateTime calculateNextDue({double? newKm, double? newHours}) {
    final km = newKm ?? currentKm;
    final hours = newHours ?? currentHours;
    
    switch (type) {
      case MaintenanceType.time:
        if (intervalDays != null) {
          return lastPerformed.add(Duration(days: intervalDays!));
        }
        break;
      case MaintenanceType.mileage:
        // This would need vehicle tracking to determine when km threshold is reached
        // For now, estimate based on average daily driving
        if (intervalKm != null) {
          final kmSinceLastMaintenance = km - (currentKm - intervalKm!);
          if (kmSinceLastMaintenance >= intervalKm!) {
            return DateTime.now();
          }
          // Estimate based on 50km average per day
          final remainingKm = intervalKm! - kmSinceLastMaintenance;
          final estimatedDays = (remainingKm / 50).ceil();
          return DateTime.now().add(Duration(days: estimatedDays));
        }
        break;
      case MaintenanceType.hours:
        if (intervalHours != null) {
          final hoursSinceLastMaintenance = hours - (currentHours - intervalHours!);
          if (hoursSinceLastMaintenance >= intervalHours!) {
            return DateTime.now();
          }
          // Estimate based on 8 hours average per day
          final remainingHours = intervalHours! - hoursSinceLastMaintenance;
          final estimatedDays = (remainingHours / 8).ceil();
          return DateTime.now().add(Duration(days: estimatedDays));
        }
        break;
      case MaintenanceType.both:
        // Use the earliest of mileage or time-based calculation
        DateTime? timeBasedDue;
        DateTime? mileageBasedDue;
        
        if (intervalDays != null) {
          timeBasedDue = lastPerformed.add(Duration(days: intervalDays!));
        }
        if (intervalKm != null) {
          final remainingKm = intervalKm! - (km - currentKm);
          if (remainingKm <= 0) {
            mileageBasedDue = DateTime.now();
          } else {
            final estimatedDays = (remainingKm / 50).ceil();
            mileageBasedDue = DateTime.now().add(Duration(days: estimatedDays));
          }
        }
        
        if (timeBasedDue != null && mileageBasedDue != null) {
          return timeBasedDue.isBefore(mileageBasedDue) ? timeBasedDue : mileageBasedDue;
        } else if (timeBasedDue != null) {
          return timeBasedDue;
        } else if (mileageBasedDue != null) {
          return mileageBasedDue;
        }
        break;
    }
    
    return nextDue;
  }

  // Create a copy with updated fields
  MaintenanceItem copyWith({
    String? id,
    String? vehicleId,
    String? itemName,
    String? description,
    MaintenanceType? type,
    MaintenancePriority? priority,
    MaintenanceStatus? status,
    int? intervalDays,
    double? intervalKm,
    double? intervalHours,
    double? currentKm,
    double? currentHours,
    DateTime? lastPerformed,
    DateTime? nextDue,
    String? notes,
    double? estimatedCost,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      intervalDays: intervalDays ?? this.intervalDays,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalHours: intervalHours ?? this.intervalHours,
      currentKm: currentKm ?? this.currentKm,
      currentHours: currentHours ?? this.currentHours,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      nextDue: nextDue ?? this.nextDue,
      notes: notes ?? this.notes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MaintenanceItem{id: $id, vehicleId: $vehicleId, itemName: $itemName, status: $status, nextDue: $nextDue}';
  }
}
