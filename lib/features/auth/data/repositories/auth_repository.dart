import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';

/// The ONLY class in the app that talks to FirebaseAuth directly.
/// Controllers depend on this, never on FirebaseAuth.instance directly —
/// that keeps business logic testable and swappable later if needed.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Emits the current user whenever sign-in state changes (login, logout,
  /// or app restart with a persisted session). This is the single source
  /// of truth for "is someone logged in" across the whole app.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AppException('Registration failed. Please try again.');
      }

      // Create the user's root document — this is where the FCM token
      // will be stored later (Step: Notifications), and it's also the
      // parent of the user's tasks subcollection.
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }

  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AppException('Login failed. Please try again.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}