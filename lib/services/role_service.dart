import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Test mode flag (same as other services)
  static const bool _useTestMode = true;
  
  // Test user roles for offline testing
  static const Map<String, String> _testUserRoles = {
    'admin@servicemaster.com': 'admin',
    'driver@servicemaster.com': 'user',
    'mechanic@servicemaster.com': 'user',
  };

  /// Get the current user's role
  Future<String> getUserRole() async {
    if (_useTestMode) {
      // In test mode, determine role based on email
      final email = getCurrentUserEmail();
      return _testUserRoles[email] ?? 'user';
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data();
      return userData?['role'] ?? 'user';
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }

  /// Check if current user is an admin
  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'admin';
    } catch (e) {
      return false; // Default to user if error
    }
  }

  /// Check if current user is a regular user
  Future<bool> isUser() async {
    try {
      final role = await getUserRole();
      return role == 'user';
    } catch (e) {
      return true; // Default to user if error
    }
  }

  /// Get current user's email (for test mode)
  String getCurrentUserEmail() {
    if (_useTestMode) {
      // Return test email based on current test scenario
      // This would be set during login in test mode
      return _getCurrentTestUserEmail();
    }
    
    final user = _auth.currentUser;
    return user?.email ?? '';
  }

  /// Get current user's ID
  String getCurrentUserId() {
    if (_useTestMode) {
      return _getCurrentTestUserId();
    }
    
    final user = _auth.currentUser;
    return user?.uid ?? '';
  }

  /// Check if user has permission to perform an action
  Future<bool> hasPermission(Permission permission) async {
    final isAdminUser = await isAdmin();
    
    switch (permission) {
      case Permission.viewAllVehicles:
        return isAdminUser;
      case Permission.addVehicle:
        return isAdminUser;
      case Permission.editVehicleDetails:
        return isAdminUser;
      case Permission.deleteVehicle:
        return isAdminUser;
      case Permission.updateVehicleMetrics:
        return true; // Both admin and user can update hours/km
      case Permission.viewAllLogs:
        return isAdminUser;
      case Permission.addMaintenanceLog:
        return true; // Both admin and user can add logs
      case Permission.editMaintenanceLog:
        return isAdminUser;
      case Permission.deleteMaintenanceLog:
        return isAdminUser;
      case Permission.createSchedule:
        return isAdminUser;
      case Permission.editSchedule:
        return isAdminUser;
      case Permission.viewAdminDashboard:
        return isAdminUser;
      case Permission.viewUserDashboard:
        return true; // Both can view their respective dashboards
    }
  }

  /// Set user role (admin only function)
  Future<void> setUserRole(String userId, String role) async {
    if (!await isAdmin()) {
      throw Exception('Only admins can set user roles');
    }

    if (_useTestMode) {
      // In test mode, this would be simulated
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set user role: $e');
    }
  }

  /// Create user document with role
  Future<void> createUserDocument(String userId, String email, String role) async {
    if (_useTestMode) {
      // In test mode, this would be simulated
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (!await isAdmin()) {
      throw Exception('Only admins can view all users');
    }

    if (_useTestMode) {
      // Return test users
      return [
        {
          'id': 'admin-user-id',
          'email': 'admin@servicemaster.com',
          'role': 'admin',
          'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        },
        {
          'id': 'driver-user-id',
          'email': 'driver@servicemaster.com',
          'role': 'user',
          'createdAt': DateTime.now().subtract(const Duration(days: 15)),
        },
        {
          'id': 'mechanic-user-id',
          'email': 'mechanic@servicemaster.com',
          'role': 'user',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)),
        },
      ];
    }

    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Private helper methods for test mode
  String _getCurrentTestUserEmail() {
    // This would be set during test login
    // For now, default to admin for testing
    return _currentTestUser;
  }

  String _getCurrentTestUserId() {
    final email = _getCurrentTestUserEmail();
    switch (email) {
      case 'admin@servicemaster.com':
        return 'admin-user-id';
      case 'driver@servicemaster.com':
        return 'driver-user-id';
      case 'mechanic@servicemaster.com':
        return 'mechanic-user-id';
      default:
        return 'default-user-id';
    }
  }

  /// Switch test user for testing purposes
  static String _currentTestUser = '';
  
  void switchTestUser(String email) {
    if (_useTestMode && _testUserRoles.containsKey(email)) {
      _currentTestUser = email;
    }
  }
  
  void clearTestUser() {
    if (_useTestMode) {
      _currentTestUser = '';
    }
  }
}

/// Permission enum for different actions
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

/// User role enum
enum UserRole {
  admin,
  user,
}
