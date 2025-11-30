import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }
      return (userDoc.data()?['role'] as String?)?.toLowerCase() ?? 'user';
    } catch (e) {
      throw Exception('Failed to determine user role: $e');
    }
  }

  Future<bool> isSuperAdmin() async {
    try {
      return (await getUserRole()) == 'super_admin';
    } catch (_) {
      return false;
    }
  }

  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'admin' || role == 'super_admin';
    } catch (_) {
      return false;
    }
  }

  Future<bool> isUser() async {
    try {
      final role = await getUserRole();
      return role == 'user' || role == 'driver';
    } catch (_) {
      return true;
    }
  }

  Future<bool> hasPermission(Permission permission) async {
    final admin = await isAdmin();
    final superAdmin = await isSuperAdmin();

    switch (permission) {
      case Permission.viewAllVehicles:
      case Permission.addVehicle:
      case Permission.editVehicleDetails:
      case Permission.deleteVehicle:
      case Permission.viewAllLogs:
      case Permission.editMaintenanceLog:
      case Permission.deleteMaintenanceLog:
      case Permission.createSchedule:
      case Permission.editSchedule:
      case Permission.viewAdminDashboard:
        return admin || superAdmin;
      case Permission.updateVehicleMetrics:
      case Permission.addMaintenanceLog:
      case Permission.viewUserDashboard:
        return true;
    }
  }

  Future<void> setUserRole(String userId, String role) async {
    if (!await isSuperAdmin()) {
      throw Exception('Only super admins can adjust roles');
    }

    await _firestore.collection('users').doc(userId).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }
}

enum Permission {
  viewAllVehicles,
  addVehicle,
  editVehicleDetails,
  deleteVehicle,
  updateVehicleMetrics,
  viewAllLogs,
  addMaintenanceLog,
  editMaintenanceLog,
  deleteMaintenanceLog,
  createSchedule,
  editSchedule,
  viewAdminDashboard,
  viewUserDashboard,
}
