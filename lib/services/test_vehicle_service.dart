import '../models/vehicle_model.dart';

class TestVehicleService {
  // Mock in-memory vehicle storage
  static final List<VehicleModel> _vehicles = [
    VehicleModel(
      id: '1',
      name: 'Service Truck 01',
      licensePlate: 'SVT-001',
      type: VehicleType.truck,
      status: VehicleStatus.available,
      model: 'Ford Transit',
      year: '2023',
      color: 'White',
      capacity: 2.5,
      hours: 1250.5,
      km: 18500.0,
      notes: 'Primary service vehicle for repairs',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VehicleModel(
      id: '2',
      name: 'Delivery Van 01',
      licensePlate: 'DVN-001',
      type: VehicleType.van,
      status: VehicleStatus.inUse,
      model: 'Mercedes Sprinter',
      year: '2022',
      color: 'Blue',
      capacity: 1.8,
      hours: 950.8,
      km: 22300.0,
      driverId: 'driver123',
      driverName: 'John Doe',
      notes: 'Equipment delivery vehicle',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    VehicleModel(
      id: '3',
      name: 'Emergency Response Car',
      licensePlate: 'ERC-999',
      type: VehicleType.car,
      status: VehicleStatus.maintenance,
      model: 'Toyota Camry',
      year: '2021',
      color: 'Red',
      capacity: 0.5,
      hours: 675.2,
      km: 15800.0,
      notes: 'Quick response vehicle for urgent calls',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // Get all vehicles
  Future<List<VehicleModel>> getAllVehicles() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Reduced delay
    return List.from(_vehicles);
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Reduced delay
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new vehicle
  Future<String> addVehicle(VehicleModel vehicle) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newVehicle = vehicle.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _vehicles.add(newVehicle);
    return newId;
  }

  // Update vehicle
  Future<void> updateVehicle(VehicleModel vehicle) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle.copyWith(updatedAt: DateTime.now());
    } else {
      throw Exception('Vehicle not found');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      _vehicles.removeAt(index);
    } else {
      throw Exception('Vehicle not found');
    }
  }

  // Get vehicles by status
  Future<List<VehicleModel>> getVehiclesByStatus(VehicleStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _vehicles.where((vehicle) => vehicle.status == status).toList();
  }

  // Get available vehicles
  Future<List<VehicleModel>> getAvailableVehicles() async {
    return getVehiclesByStatus(VehicleStatus.available);
  }

  // Assign vehicle to driver
  Future<void> assignVehicleToDriver(String vehicleId, String driverId, String driverName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(
        driverId: driverId,
        driverName: driverName,
        status: VehicleStatus.inUse,
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception('Vehicle not found');
    }
  }

  // Unassign vehicle from driver
  Future<void> unassignVehicleFromDriver(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(
        driverId: null,
        driverName: null,
        status: VehicleStatus.available,
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception('Vehicle not found');
    }
  }

  // Search vehicles
  Future<List<VehicleModel>> searchVehicles(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _vehicles.where((vehicle) {
      return vehicle.name.toLowerCase().contains(lowercaseQuery) ||
             vehicle.licensePlate.toLowerCase().contains(lowercaseQuery) ||
             (vehicle.model?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Stream simulation for real-time updates
  Stream<List<VehicleModel>> get vehiclesStream async* {
    while (true) {
      yield List.from(_vehicles);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
