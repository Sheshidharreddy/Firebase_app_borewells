import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/user_model.dart';

class UserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _primaryAuth = FirebaseAuth.instance;
  FirebaseApp? _secondaryApp;
  FirebaseAuth? _secondaryAuth;

  Future<FirebaseAuth> _ensureSecondaryAuth() async {
    if (_secondaryAuth != null) return _secondaryAuth!;

    try {
      _secondaryApp = Firebase.apps.firstWhere((app) => app.name == 'userCreation');
    } catch (_) {
      _secondaryApp = await Firebase.initializeApp(
        name: 'userCreation',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    _secondaryAuth = FirebaseAuth.instanceFor(app: _secondaryApp!);
    return _secondaryAuth!;
  }

  Future<bool> superAdminExists() async {
    final doc = await _firestore
      .collection('config')
      .doc('system')
      .get();

    final uid = doc.data()?['superAdminUid'];
    return doc.exists && uid != null && (uid is String ? uid.isNotEmpty : false);
  }

  Future<void> createSuperAdmin({
    required String uid,
    required String email,
    required String name,
  }) async {
    if (await superAdminExists()) {
      throw Exception('Super admin already exists');
    }

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': 'super_admin',
      'adminId': 'super_admin',
      'organizationId': 'org_super_admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel> createAdmin({
    required String name,
    required String email,
    required String tempPassword,
  }) async {
    await _ensureLoggedInSuperAdmin();

    final auth = await _ensureSecondaryAuth();
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: tempPassword,
    );

    final uid = credential.user!.uid;
    final now = DateTime.now();
    final data = {
      'name': name,
      'email': email,
      'role': 'admin',
      'adminId': uid,
      'organizationId': 'org_$uid',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(uid).set(data);
    await auth.signOut();

    return UserModel(
      id: uid,
      email: email,
      role: 'admin',
      createdAt: now
    );
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String tempPassword,
    String? adminIdOverride,
  }) async {
    final creatorSnapshot = await _getCurrentUserSnapshot();
    final creatorData = creatorSnapshot.data();
    final creatorRole = creatorData?['role'];

    if (creatorRole != 'super_admin' && creatorRole != 'admin') {
      throw Exception('Only admins or super admins can create users');
    }

    String adminId;
    String organizationId;

    if (creatorRole == 'super_admin') {
      if (adminIdOverride == null || adminIdOverride.isEmpty) {
        throw Exception('Select an admin to assign this user to');
      }
      final adminDoc = await _firestore.collection('users').doc(adminIdOverride).get();
      final adminData = adminDoc.data();
      if (!adminDoc.exists || adminData?['role'] != 'admin') {
        throw Exception('Invalid admin selected');
      }
      adminId = adminDoc.id;
      organizationId = adminData?['organizationId'] ?? 'org_default';
    } else {
      adminId = creatorSnapshot.id;
      organizationId = creatorData?['organizationId'] ?? 'org_default';
    }

    final auth = await _ensureSecondaryAuth();
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: tempPassword,
    );
    final uid = credential.user!.uid;
    final now = DateTime.now();

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': 'user',
      'adminId': adminId,
      'organizationId': organizationId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await auth.signOut();

    return UserModel(
      id: uid,
      email: email,
      role: 'user',
      createdAt: now,
    );
  }

  Stream<List<UserModel>> adminsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<UserModel>> usersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteAdmin(String adminId) async {
    await _ensureLoggedInSuperAdmin();

    await _firestore.collection('users').doc(adminId).delete();

    final affectedUsers = await _firestore
        .collection('users')
        .where('adminId', isEqualTo: adminId)
        .get();

    for (final doc in affectedUsers.docs) {
      await doc.reference.update({
        'adminId': 'admin_removed',
      });
    }
  }

  Future<List<UserModel>> getAdminsOnce() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .orderBy('name')
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> _ensureLoggedInSuperAdmin() async {
    final user = _primaryAuth.currentUser;
    if (user == null) {
      throw Exception('Please sign in as super admin to continue');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data()?['role'] != 'super_admin') {
      throw Exception('Only the super admin can perform this action');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getCurrentUserSnapshot() async {
    final user = _primaryAuth.currentUser;
    if (user == null) {
      throw Exception('Please sign in to continue');
    }
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    return doc;
  }

Future<void> createUserWithRole({
  required String email,
  required String password,
  required String role, // superadmin, admin, or user
}) async {
   try {
    // Use secondary auth to avoid affecting primary signed-in user
    final auth = await _ensureSecondaryAuth();
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final uid = credential.user!.uid;

      // Create Firestore user document with minimal fields
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await auth.signOut();
  } catch (e) {
    throw Exception('Failed to create user: $e');
  }
}

}
