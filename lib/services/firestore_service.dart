import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicemaster/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';




class FirestoreService {
  
final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getCurrentUser() async {
        final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('User document not found');
    }

    return UserModel.fromMap(doc.data()!, doc.id);
   }
  

  // Create or update document
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

  // Get document
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {



    try {
      return await _db.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  // Get collection
  Future<QuerySnapshot> getCollection({
    required String collection,
  }) async {
    try {
      return await _db.collection(collection).get();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  // Listen to collection changes
  Stream<QuerySnapshot> listenToCollection({
    required String collection,
  }) {
    return _db.collection(collection).snapshots();
  }

  // Delete document
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Update document
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {

    try {
      await _db.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }
}
