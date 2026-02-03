import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'session_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  // Test mode flag
  static const bool _useTestMode = false;

  // Get current user
  User? get currentUser {
    if (_useTestMode) {
      // In test mode, we don't use Firebase User objects
      return null;
    }
    return _auth.currentUser;
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges {
    if (_useTestMode) {
      // In test mode, return a stream that never has data
      // AuthWrapper will handle test authentication differently
      return Stream<User?>.empty();
    }
    return _auth.authStateChanges();
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('SIGNED IN UID: ${credential.user?.uid}');
      print('CURRENT USER UID: ${FirebaseAuth.instance.currentUser?.uid}');
      
      if (credential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestoreService.getDocument(
          collection: 'users',
          documentId: credential.user!.uid,
        );
        
        if (userDoc.exists) {
          // Update last login
          await _firestoreService.updateDocument(
            collection: 'users',
            documentId: credential.user!.uid,
            data: {'lastLogin': DateTime.now()},
          );
          
          return UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
            credential.user!.uid,
          );
        } else {
          // Create user document if it doesn't exist (fallback)
          final newUser = UserModel(
            id: credential.user!.uid,
            email: credential.user!.email!,
            role: 'user', // default role
            adminId: 'admin_default',
            organizationId: 'org_default',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          
          await _firestoreService.setDocument(
            collection: 'users',
            documentId: credential.user!.uid,
            data: newUser.toMap(),
          );
          
          return newUser;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user document
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          role: role,
          name: name,
          adminId: role == 'admin' ? credential.user!.uid : 'admin_default',
          organizationId: 'org_default',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        await _firestoreService.setDocument(
          collection: 'users',
          documentId: credential.user!.uid,
          data: newUser.toMap(),
        );
        
        return newUser;
      }
      return null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestoreService.getDocument(
          collection: 'users',
          documentId: user.uid,
        );
        
        if (userDoc.exists) {
          return UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
            user.uid,
          );
        }
      } catch (e) {
        throw Exception('Failed to get user data: $e');
      }
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      SessionService.instance.setCurrentUser(null);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
