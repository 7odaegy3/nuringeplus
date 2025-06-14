import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> syncSavedProcedures(List<int> procedureIds) async {
    if (currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('saved_procedures')
        .doc('procedures')
        .set({
      'ids': procedureIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<int>> getSavedProcedureIds() async {
    if (currentUserId == null) return [];

    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('saved_procedures')
        .doc('procedures')
        .get();

    if (!doc.exists) return [];

    final data = doc.data();
    if (data == null || !data.containsKey('ids')) return [];

    return List<int>.from(data['ids'] as List);
  }

  Stream<List<int>> savedProceduresStream() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('saved_procedures')
        .doc('procedures')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null || !data.containsKey('ids')) return [];
      return List<int>.from(data['ids'] as List);
    });
  }
}
