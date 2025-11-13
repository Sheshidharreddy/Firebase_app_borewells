import 'dart:async';
import '../models/maintenance_item_model.dart';

class TestMaintenanceItemService {
  // Simulated in-memory database
  static final List<MaintenanceItem> _items = [
    MaintenanceItem(
      id: 'item1',
      vehicleId: 'vehicle1',
      itemName: 'Oil Change',
      description: 'Engine oil and filter replacement',
      type: MaintenanceType.both,
      priority: MaintenancePriority.high,
      status: MaintenanceStatus.overdue,
      intervalDays: 180, // 6 months
      intervalKm: 10000.0,
      intervalHours: null,
      currentKm: 12500.0,
      currentHours: 250.0,
      lastPerformed: DateTime.now().subtract(const Duration(days: 200)),
      nextDue: DateTime.now().subtract(const Duration(days: 20)), // Overdue
      notes: 'Use synthetic oil for better performance',
      estimatedCost: 150.0,
      assignedTo: 'Admin User',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    MaintenanceItem(
      id: 'item2',
      vehicleId: 'vehicle1',
      itemName: 'Brake Inspection',
      description: 'Check brake pads, rotors, and fluid',
      type: MaintenanceType.mileage,
      priority: MaintenancePriority.high,
      status: MaintenanceStatus.due,
      intervalDays: null,
      intervalKm: 15000.0,
      intervalHours: null,
      currentKm: 12500.0,
      currentHours: 250.0,
      lastPerformed: DateTime.now().subtract(const Duration(days: 120)),
      nextDue: DateTime.now().add(const Duration(days: 3)), // Due in 3 days
      notes: 'Front pads showing wear',
      estimatedCost: 300.0,
      assignedTo: 'Service Team',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    MaintenanceItem(
      id: 'item3',
      vehicleId: 'vehicle2',
      itemName: 'Tire Rotation',
      description: 'Rotate tires and check pressure',
      type: MaintenanceType.mileage,
      priority: MaintenancePriority.medium,
      status: MaintenanceStatus.upcoming,
      intervalDays: null,
      intervalKm: 8000.0,
      intervalHours: null,
      currentKm: 11000.0,
      currentHours: 180.0,
      lastPerformed: DateTime.now().subtract(const Duration(days: 60)),
      nextDue: DateTime.now().add(const Duration(days: 5)), // Due in 5 days
      notes: 'Check tire wear patterns',
      estimatedCost: 50.0,
      assignedTo: 'Driver User',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    MaintenanceItem(
      id: 'item4',
      vehicleId: 'vehicle2',
      itemName: 'Air Filter Replacement',
      description: 'Replace engine air filter',
      type: MaintenanceType.time,
      priority: MaintenancePriority.low,
      status: MaintenanceStatus.overdue,
      intervalDays: 365, // 1 year
      intervalKm: null,
      intervalHours: null,
      currentKm: 11000.0,
      currentHours: 180.0,
      lastPerformed: DateTime.now().subtract(const Duration(days: 400)),
      nextDue: DateTime.now().subtract(const Duration(days: 35)), // Overdue by 35 days
      notes: 'Check for dirt and debris',
      estimatedCost: 25.0,
      assignedTo: 'Service Team',
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
      updatedAt: DateTime.now().subtract(const Duration(days: 400)),
    ),
    MaintenanceItem(
      id: 'item5',
      vehicleId: 'vehicle3',
      itemName: 'Transmission Service',
      description: 'Transmission fluid and filter change',
      type: MaintenanceType.mileage,
      priority: MaintenancePriority.medium,
      status: MaintenanceStatus.upcoming,
      intervalDays: null,
      intervalKm: 50000.0,
      intervalHours: null,
      currentKm: 9500.0,
      currentHours: 150.0,
      lastPerformed: DateTime.now().subtract(const Duration(days: 180)),
      nextDue: DateTime.now().add(const Duration(days: 45)), // Due in 45 days
      notes: 'Expensive service - plan ahead',
      estimatedCost: 500.0,
      assignedTo: 'Service Team',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    MaintenanceItem(
      id: 'item6',
      vehicleId: 'vehicle3',
      itemName: 'Battery Check',
      description: 'Test battery voltage and terminals',
      type: MaintenanceType.time,
      priority: MaintenancePriority.medium,
      status: MaintenanceStatus.upcoming,
      intervalDays: 90, // 3 months
      intervalKm: null,
      intervalHours: null,
      currentKm: 9500.0,
      currentHours: 150.0,
      lastPerformed: DateTime.now().subtract(const Duration(days: 85)),
      nextDue: DateTime.now().add(const Duration(days: 5)), // Due in 5 days
      notes: 'Clean terminals if corroded',
      estimatedCost: 0.0, // Free check
      assignedTo: 'Driver User',
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      updatedAt: DateTime.now().subtract(const Duration(days: 85)),
    ),
  ];

  static int _nextId = 7;

  // Get all maintenance items as a stream
  Stream<List<MaintenanceItem>> getAllMaintenanceItems() {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final sortedItems = List<MaintenanceItem>.from(_items)
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return sortedItems;
    }).take(1);
  }

  // Get maintenance items for a specific vehicle
  Stream<List<MaintenanceItem>> getMaintenanceItemsByVehicle(String vehicleId) {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredItems = _items
          .where((item) => item.vehicleId == vehicleId)
          .toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return List<MaintenanceItem>.from(filteredItems);
    }).take(1);
  }

  // Get overdue maintenance items
  Stream<List<MaintenanceItem>> getOverdueItems() {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final overdueItems = _items
          .where((item) => item.isOverdue)
          .toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return List<MaintenanceItem>.from(overdueItems);
    }).take(1);
  }

  // Get items due soon (within 7 days)
  Stream<List<MaintenanceItem>> getDueSoonItems() {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final dueSoonItems = _items
          .where((item) => item.isDueSoon)
          .toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return List<MaintenanceItem>.from(dueSoonItems);
    }).take(1);
  }

  // Get upcoming maintenance items
  Stream<List<MaintenanceItem>> getUpcomingItems() {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final upcomingItems = _items
          .where((item) => !item.isOverdue && !item.isDueSoon)
          .toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return List<MaintenanceItem>.from(upcomingItems);
    }).take(1);
  }

  // Get items by status
  Stream<List<MaintenanceItem>> getItemsByStatus(MaintenanceStatus status) {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredItems = _items
          .where((item) => item.status == status)
          .toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return List<MaintenanceItem>.from(filteredItems);
    }).take(1);
  }

  // Get items by priority
  Stream<List<MaintenanceItem>> getItemsByPriority(MaintenancePriority priority) {
    return Stream.periodic(const Duration(milliseconds: 500), (count) {
      final filteredItems = _items
          .where((item) => item.priority == priority)
          .toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      return List<MaintenanceItem>.from(filteredItems);
    }).take(1);
  }

  // Add a new maintenance item
  Future<String> addMaintenanceItem(MaintenanceItem item) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final newItem = item.copyWith(
      id: 'item${_nextId++}',
      createdAt: now,
      updatedAt: now,
    );

    _items.add(newItem);
    return newItem.id!;
  }

  // Update an existing maintenance item
  Future<void> updateMaintenanceItem(MaintenanceItem item) async {
    if (item.id == null) {
      throw Exception('Cannot update item without an ID');
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item.copyWith(updatedAt: DateTime.now());
    } else {
      throw Exception('Maintenance item not found');
    }
  }

  // Delete a maintenance item
  Future<void> deleteMaintenanceItem(String itemId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items.removeAt(index);
    } else {
      throw Exception('Maintenance item not found');
    }
  }

  // Get a single maintenance item by ID
  Future<MaintenanceItem?> getMaintenanceItemById(String itemId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Mark maintenance as completed
  Future<void> markMaintenanceCompleted(String itemId, {
    DateTime? completedDate,
    String? performedBy,
    String? notes,
    double? actualCost,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _items[index];
      final completed = completedDate ?? DateTime.now();
      
      // Calculate next due date based on maintenance type and intervals
      DateTime nextDue;
      if (item.type == MaintenanceType.time && item.intervalDays != null) {
        nextDue = completed.add(Duration(days: item.intervalDays!));
      } else if (item.type == MaintenanceType.mileage && item.intervalKm != null) {
        // For mileage-based, estimate next due date (would need actual vehicle tracking)
        nextDue = completed.add(const Duration(days: 180)); // Placeholder
      } else if (item.type == MaintenanceType.hours && item.intervalHours != null) {
        // For hours-based, estimate next due date
        nextDue = completed.add(const Duration(days: 180)); // Placeholder
      } else {
        // Default to 6 months for mixed type
        nextDue = completed.add(const Duration(days: 180));
      }

      _items[index] = item.copyWith(
        status: MaintenanceStatus.upcoming,
        lastPerformed: completed,
        nextDue: nextDue,
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception('Maintenance item not found');
    }
  }

  // Get maintenance statistics
  Future<Map<String, dynamic>> getMaintenanceStatistics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final overdue = _items.where((item) => item.isOverdue).length;
    final dueSoon = _items.where((item) => item.isDueSoon).length;
    final upcoming = _items.where((item) => !item.isOverdue && !item.isDueSoon).length;
    final totalCost = _items.fold<double>(0, (sum, item) => sum + (item.estimatedCost ?? 0));

    // Group by priority for breakdown
    Map<MaintenancePriority, int> priorityBreakdown = {};
    for (var priority in MaintenancePriority.values) {
      priorityBreakdown[priority] = _items.where((item) => item.priority == priority).length;
    }

    // Group by vehicle for vehicle-specific stats
    Map<String, int> vehicleBreakdown = {};
    for (var item in _items) {
      vehicleBreakdown[item.vehicleId] = (vehicleBreakdown[item.vehicleId] ?? 0) + 1;
    }

    return {
      'totalItems': _items.length,
      'overdue': overdue,
      'dueSoon': dueSoon,
      'upcoming': upcoming,
      'totalEstimatedCost': totalCost,
      'priorityBreakdown': priorityBreakdown.map((k, v) => MapEntry(k.toString().split('.').last, v)),
      'vehicleBreakdown': vehicleBreakdown,
      'averageCostPerItem': _items.isNotEmpty ? totalCost / _items.length : 0,
    };
  }

  // Update vehicle metrics and recalculate due dates
  Future<void> updateVehicleMetrics(String vehicleId, {
    double? newKm,
    double? newHours,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final vehicleItems = _items.where((item) => item.vehicleId == vehicleId).toList();
    
    for (var item in vehicleItems) {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final updatedItem = item.copyWith(
          currentKm: newKm ?? item.currentKm,
          currentHours: newHours ?? item.currentHours,
          nextDue: item.calculateNextDue(newKm: newKm, newHours: newHours),
          updatedAt: DateTime.now(),
        );
        _items[index] = updatedItem;
      }
    }
  }
}
