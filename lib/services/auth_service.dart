import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password and get user role
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
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
            role: 'driver', // default role
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

  // Sign up with email and password and create user document
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
        // Create user document in Firestore
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          role: role,
          name: name,
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
