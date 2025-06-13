import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  // Authentication Methods
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create user document if it doesn't exist
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Firestore Methods
  Future<void> _createUserDocument(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'created_at': FieldValue.serverTimestamp(),
        'saved_procedures': [],
      });
    }
  }

  Future<void> saveProcedureForUser(String userId, int procedureId) async {
    await _firestore.collection('users').doc(userId).set({
      'saved_procedures': FieldValue.arrayUnion([procedureId]),
    }, SetOptions(merge: true));
  }

  Future<void> removeProcedureForUser(String userId, int procedureId) async {
    await _firestore.collection('users').doc(userId).update({
      'saved_procedures': FieldValue.arrayRemove([procedureId]),
    });
  }

  Future<List<int>> getSavedProcedureIds(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || !doc.data()!.containsKey('saved_procedures')) {
      return [];
    }
    return List<int>.from(doc.data()!['saved_procedures']);
  }

  Stream<List<int>> savedProceduresStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists || !doc.data()!.containsKey('saved_procedures')) {
        return [];
      }
      return List<int>.from(doc.data()!['saved_procedures']);
    });
  }

  // Helper Methods
  bool get isUserSignedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
