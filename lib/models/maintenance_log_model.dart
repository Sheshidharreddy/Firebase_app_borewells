import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceLog {
  final String? id;
  final String itemName;
  final DateTime date;
  final double hours;
  final double km;
  final String notes;
  final String? vehicleId; // Optional link to vehicle
  final String? performedBy; // User who performed maintenance
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceLog({
    this.id,
    required this.itemName,
    required this.date,
    required this.hours,
    required this.km,
    required this.notes,
    this.vehicleId,
    this.performedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create MaintenanceLog from Firestore document
  factory MaintenanceLog.fromMap(String id, Map<String, dynamic> map) {
    return MaintenanceLog(
      id: id,
      itemName: map['itemName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hours: (map['hours'] ?? 0.0).toDouble(),
      km: (map['km'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
      vehicleId: map['vehicleId'],
      performedBy: map['performedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert MaintenanceLog to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'date': Timestamp.fromDate(date),
      'hours': hours,
      'km': km,
      'notes': notes,
      'vehicleId': vehicleId,
      'performedBy': performedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  MaintenanceLog copyWith({
    String? id,
    String? itemName,
    DateTime? date,
    double? hours,
    double? km,
    String? notes,
    String? vehicleId,
    String? performedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceLog(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      km: km ?? this.km,
      notes: notes ?? this.notes,
      vehicleId: vehicleId ?? this.vehicleId,
      performedBy: performedBy ?? this.performedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MaintenanceLog{id: $id, itemName: $itemName, date: $date, hours: $hours, km: $km, notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemName == other.itemName &&
          date == other.date &&
          hours == other.hours &&
          km == other.km &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      itemName.hashCode ^
      date.hashCode ^
      hours.hashCode ^
      km.hashCode ^
      notes.hashCode;
}
