import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'organization_service.dart';

class VehicleService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'vehicles';

  // Get all vehicles
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final snapshot = await _firestoreService.getCollection(collection: _collection);
      return snapshot.docs.map((doc) {
        return VehicleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  // Listen to vehicles stream
  Stream<List<VehicleModel>> get vehiclesStream {
    return _firestoreService.listenToCollection(collection: _collection).map(
      (snapshot) => snapshot.docs.map((doc) {
        return VehicleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList(),
    );
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: _collection,
        documentId: id,
      );
      if (doc.exists) {
        return VehicleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vehicle: $e');
    }
  }

  // Add new vehicle
  Future<String> addVehicle(VehicleModel vehicle) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(_collection).doc();
      final newVehicle = vehicle.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.setDocument(
        collection: _collection,
        documentId: docRef.id,
        data: newVehicle.toMap(),
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  // Update vehicle
  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      final updatedVehicle = vehicle.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateDocument(
        collection: _collection,
        documentId: vehicle.id,
        data: updatedVehicle.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collection,
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  // Get vehicles by status
  Future<List<VehicleModel>> getVehiclesByStatus(VehicleStatus status) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('status', isEqualTo: status.name)
          .get();
      
      return snapshot.docs.map((doc) {
        return VehicleModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles by status: $e');
    }
  }

  // Get available vehicles
  Future<List<VehicleModel>> getAvailableVehicles() async {
    return getVehiclesByStatus(VehicleStatus.available);
  }

  // Assign vehicle to driver
  Future<void> assignVehicleToDriver(String vehicleId, String driverId, String driverName) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collection,
        documentId: vehicleId,
        data: {
          'driverId': driverId,
          'driverName': driverName,
          'status': VehicleStatus.inUse.name,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to assign vehicle to driver: $e');
    }
  }

  // Unassign vehicle from driver
  Future<void> unassignVehicleFromDriver(String vehicleId) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collection,
        documentId: vehicleId,
        data: {
          'driverId': null,
          'driverName': null,
          'status': VehicleStatus.available.name,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to unassign vehicle from driver: $e');
    }
  }

  // Search vehicles by name or license plate
  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      final allVehicles = await getAllVehicles();
      final lowercaseQuery = query.toLowerCase();
      
      return allVehicles.where((vehicle) {
        return vehicle.name.toLowerCase().contains(lowercaseQuery) ||
               vehicle.licensePlate.toLowerCase().contains(lowercaseQuery) ||
               (vehicle.model?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search vehicles: $e');
    }
  }

  // Get vehicles filtered by user's organization and role
  Future<List<VehicleModel>> getVehiclesForUser(UserModel user) async {
    try {
      final allVehicles = await getAllVehicles();
      return OrganizationService.filterVehiclesByUserAccess(allVehicles, user);
    } catch (e) {
      throw Exception('Failed to get vehicles for user: $e');
    }
  }

  // Get vehicles by organization (for admin users)
  Future<List<VehicleModel>> getVehiclesByOrganization(String organizationId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('organizationId', isEqualTo: organizationId)
          .get();
      
      return snapshot.docs.map((doc) {
        return VehicleModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles by organization: $e');
    }
  }

  // Get vehicles assigned to a specific driver
  Future<List<VehicleModel>> getVehiclesByDriver(String driverId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('driverId', isEqualTo: driverId)
          .get();
      
      return snapshot.docs.map((doc) {
        return VehicleModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles by driver: $e');
    }
  }

  // Stream vehicles filtered by user access
  Stream<List<VehicleModel>> getVehiclesStreamForUser(UserModel user) {
    final collection = FirebaseFirestore.instance.collection(_collection);

    if (user.isSuperAdmin) {
      return collection.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
                .toList(),
          );
    }

    if (user.isAdmin) {
      return collection
          .where('adminId', isEqualTo: user.id)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
              .toList());
    }

    return collection
        .where('adminId', isEqualTo: user.adminId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
