import 'package:firebase_auth/firebase_auth.dart';

/// Wraps a human-readable message so the UI layer never has to know
/// anything about FirebaseAuthException codes.
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// Translates raw FirebaseAuthException codes into messages a non-technical
/// user can actually understand and act on. This is the single place that
/// knows about Firebase error codes — repositories catch FirebaseAuthException
/// and rethrow AppException via this mapper; the UI only ever sees AppException.
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static AppException map(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return AppException('That email address looks invalid.');
        case 'user-disabled':
          return AppException('This account has been disabled.');
        case 'user-not-found':
          return AppException('No account found with this email.');
        case 'wrong-password':
        case 'invalid-credential':
          return AppException('Incorrect email or password.');
        case 'email-already-in-use':
          return AppException('An account already exists with this email.');
        case 'weak-password':
          return AppException('Password is too weak. Use at least 6 characters.');
        case 'operation-not-allowed':
          return AppException('Email/password sign-in is not enabled.');
        case 'too-many-requests':
          return AppException('Too many attempts. Please try again later.');
        case 'network-request-failed':
          return AppException('Network error. Check your connection and try again.');
        default:
          return AppException(error.message ?? 'Something went wrong. Please try again.');
      }
    }
    return AppException('Something went wrong. Please try again.');
  }
}