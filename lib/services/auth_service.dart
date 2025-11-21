import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'test_auth_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  // Test mode flag
  static const bool _useTestMode = true;

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
    if (_useTestMode) {
      // Use test authentication
      final testAuth = TestAuthService();
      return await testAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
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
    if (_useTestMode) {
      // Test mode doesn't support sign up
      throw Exception('Sign up not available in test mode');
    }
    
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
    if (_useTestMode) {
      // In test mode, this is handled by RoleService
      return null;
    }
    
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
    if (_useTestMode) {
      // In test mode, just clear the current test user in RoleService
      // This will be handled by the calling code
      return;
    }
    
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    if (_useTestMode) {
      // In test mode, just simulate password reset
      return;
    }
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
