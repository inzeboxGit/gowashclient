import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService();

  Future<void> createAccount({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final UserCredential credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Could not create your account right now.',
      );
    }

    await user.updateDisplayName(fullName);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'id': user.uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': 'client',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendResetEmail(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
