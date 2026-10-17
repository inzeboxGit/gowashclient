import 'package:firebase_auth/firebase_auth.dart';

bool looksLikeEmail(String email) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}

String normalizeUsPhoneNumber(String rawPhone) {
  final String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return '';
  }
  return '+1$digits';
}

String messageForAuthError(FirebaseAuthException error) {
  switch (error.code) {
    case 'email-already-in-use':
      return 'This email is already in use.';
    case 'invalid-email':
      return 'This email address is not valid.';
    case 'weak-password':
      return 'Choose a stronger password.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password is incorrect.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    default:
      return error.message ?? 'Something went wrong. Please try again.';
  }
}
