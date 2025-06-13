import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  // Auth State
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('FirebaseService: Starting Google Sign In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('FirebaseService: Google Sign In was aborted by user');
        return null;
      }

      print('FirebaseService: Getting Google Auth tokens...');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'FirebaseService: Got Google Auth tokens. AccessToken exists: ${googleAuth.accessToken != null}, IdToken exists: ${googleAuth.idToken != null}');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('FirebaseService: Signing in with Firebase...');
      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      print(
          'FirebaseService: Firebase Sign In successful. User ID: ${userCredential.user?.uid}');

      // Create/Update user document in Firestore
      if (userCredential.user != null) {
        try {
          print('FirebaseService: Updating user document in Firestore...');
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'name': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'lastLogin': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('FirebaseService: User document updated successfully');
        } catch (e) {
          print('FirebaseService: Error updating Firestore document: $e');
          // Don't return null here, we still want to return the userCredential
          // even if Firestore update fails
        }
      }

      return userCredential;
    } catch (e) {
      print('FirebaseService: Error during sign in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('FirebaseService: Error signing out: $e');
      rethrow;
    }
  }

  // Save procedure for user
  Future<void> saveProcedureForUser(String userId, int procedureId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'saved_procedures': FieldValue.arrayUnion([procedureId])
      });
    } catch (e) {
      print('Error saving procedure: $e');
      rethrow;
    }
  }

  // Remove saved procedure
  Future<void> removeProcedureForUser(String userId, int procedureId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'saved_procedures': FieldValue.arrayRemove([procedureId])
      });
    } catch (e) {
      print('Error removing procedure: $e');
      rethrow;
    }
  }

  // Get saved procedure IDs
  Stream<List<int>> getSavedProcedureIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data();
      if (data == null || !data.containsKey('saved_procedures')) return [];
      return List<int>.from(data['saved_procedures'] ?? []);
    });
  }

  // Check if procedure is saved
  Future<bool> isProcedureSaved(String userId, int procedureId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null || !data.containsKey('saved_procedures')) return false;

      final savedProcedures = List<int>.from(data['saved_procedures'] ?? []);
      return savedProcedures.contains(procedureId);
    } catch (e) {
      print('Error checking saved procedure: $e');
      return false;
    }
  }
}
