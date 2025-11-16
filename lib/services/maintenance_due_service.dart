import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/simple_maintenance_item.dart';
import '../models/maintenance_log_model.dart';
import 'test_maintenance_log_service.dart';
import 'test_vehicle_service.dart';

enum MaintenanceStatus { ok, dueSoon, overdue }

class MaintenanceDueItem {
  final String itemName;
  final String itemId;
  final MaintenanceStatus status;
  final String statusText;
  final Color statusColor;
  final DateTime? lastServiceDate;
  final double? lastServiceHours;
  final double? lastServiceKm;
  final DateTime? nextDueDate;
  final double? nextDueHours;
  final double? nextDueKm;
  final int daysUntilDue;

  MaintenanceDueItem({
    required this.itemName,
    required this.itemId,
    required this.status,
    required this.statusText,
    required this.statusColor,
    this.lastServiceDate,
    this.lastServiceHours,
    this.lastServiceKm,
    this.nextDueDate,
    this.nextDueHours,
    this.nextDueKm,
    required this.daysUntilDue,
  });
}

class MaintenanceDueService {
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();

  Future<List<MaintenanceDueItem>> calculateMaintenanceDue(VehicleModel vehicle) async {
    final allLogs = await _logService.getAllLogs().first;
    final vehicleLogs = allLogs.where((log) => log.vehicleId == vehicle.id).toList();
    
    final items = SimpleMaintenanceItem.getActiveItems();
    final dueItems = <MaintenanceDueItem>[];

    for (final item in items) {
      final dueItem = _calculateItemDue(vehicle, item, vehicleLogs);
      dueItems.add(dueItem);
    }

    // Sort: Overdue first, then Due Soon, then OK
    dueItems.sort((a, b) {
      if (a.status == MaintenanceStatus.overdue && b.status != MaintenanceStatus.overdue) {
        return -1;
      }
      if (b.status == MaintenanceStatus.overdue && a.status != MaintenanceStatus.overdue) {
        return 1;
      }
      if (a.status == MaintenanceStatus.dueSoon && b.status == MaintenanceStatus.ok) {
        return -1;
      }
      if (b.status == MaintenanceStatus.dueSoon && a.status == MaintenanceStatus.ok) {
        return 1;
      }
      return a.daysUntilDue.compareTo(b.daysUntilDue);
    });

    return dueItems;
  }

  MaintenanceDueItem _calculateItemDue(
    VehicleModel vehicle, 
    SimpleMaintenanceItem item, 
    List<MaintenanceLog> vehicleLogs
  ) {
    // Find last service for this item - match by item name since no itemId field
    final lastLog = vehicleLogs
        .where((log) => log.itemName.toLowerCase().contains(item.name.toLowerCase()) ||
                       item.name.toLowerCase().contains(log.itemName.toLowerCase()))
        .fold<MaintenanceLog?>(null, (prev, current) {
      if (prev == null) return current;
      return current.date.isAfter(prev.date) ? current : prev;
    });

    final now = DateTime.now();
    
    // Calculate next due based on intervals
    DateTime? nextDueDate;
    double? nextDueHours;
    double? nextDueKm;
    int daysUntilDue = 0;

    if (lastLog != null) {
      // Calculate based on last service
      if (item.intervalMonths != null) {
        nextDueDate = DateTime(
          lastLog.date.year,
          lastLog.date.month + item.intervalMonths!,
          lastLog.date.day,
        );
        daysUntilDue = nextDueDate.difference(now).inDays;
      }
      
      if (item.intervalHours != null) {
        nextDueHours = lastLog.hours + item.intervalHours!;
        final vehicleHours = vehicle.hours ?? 0.0;
        final hoursDiff = nextDueHours - vehicleHours;
        // Rough estimate: 8 hours per day
        daysUntilDue = (hoursDiff / 8).round();
      }
      
      if (item.intervalKm != null) {
        nextDueKm = lastLog.km + item.intervalKm!;
        final vehicleKm = vehicle.km ?? 0.0;
        final kmDiff = nextDueKm - vehicleKm;
        // Rough estimate: 100 km per day
        daysUntilDue = (kmDiff / 100).round();
      }
    } else {
      // No previous service - assume first service is due based on vehicle usage
      if (item.intervalMonths != null) {
        // If no service history, consider overdue if vehicle is older than interval
        daysUntilDue = -30; // Assume overdue
      }
      
      final vehicleHours = vehicle.hours ?? 0.0;
      final vehicleKm = vehicle.km ?? 0.0;
      
      if (item.intervalHours != null && vehicleHours >= item.intervalHours!) {
        daysUntilDue = -1; // Overdue
      }
      
      if (item.intervalKm != null && vehicleKm >= item.intervalKm!) {
        daysUntilDue = -1; // Overdue
      }
    }

    // Determine status
    MaintenanceStatus status;
    String statusText;
    Color statusColor;

    if (daysUntilDue < 0) {
      status = MaintenanceStatus.overdue;
      statusText = 'Overdue';
      statusColor = Colors.red;
    } else if (daysUntilDue <= 7) {
      status = MaintenanceStatus.dueSoon;
      statusText = daysUntilDue == 0 ? 'Due Today' : 'Due in $daysUntilDue days';
      statusColor = Colors.orange;
    } else {
      status = MaintenanceStatus.ok;
      statusText = 'Due in $daysUntilDue days';
      statusColor = Colors.green;
    }

    return MaintenanceDueItem(
      itemName: item.name,
      itemId: item.id,
      status: status,
      statusText: statusText,
      statusColor: statusColor,
      lastServiceDate: lastLog?.date,
      lastServiceHours: lastLog?.hours,
      lastServiceKm: lastLog?.km,
      nextDueDate: nextDueDate,
      nextDueHours: nextDueHours,
      nextDueKm: nextDueKm,
      daysUntilDue: daysUntilDue,
    );
  }

  Future<MaintenanceDueItem?> getNextMaintenanceDue(VehicleModel vehicle) async {
    final dueItems = await calculateMaintenanceDue(vehicle);
    return dueItems.isNotEmpty ? dueItems.first : null;
  }

  Future<List<VehicleMaintenanceSummary>> getVehicleMaintenanceSummary() async {
    final TestVehicleService vehicleService = TestVehicleService();
    final vehicles = await vehicleService.getAllVehicles();
    final summaries = <VehicleMaintenanceSummary>[];

    for (final vehicle in vehicles) {
      final nextDue = await getNextMaintenanceDue(vehicle);
      summaries.add(VehicleMaintenanceSummary(
        vehicle: vehicle,
        nextMaintenanceDue: nextDue,
      ));
    }

    return summaries;
  }
}

class VehicleMaintenanceSummary {
  final VehicleModel vehicle;
  final MaintenanceDueItem? nextMaintenanceDue;

  VehicleMaintenanceSummary({
    required this.vehicle,
    this.nextMaintenanceDue,
  });
}
