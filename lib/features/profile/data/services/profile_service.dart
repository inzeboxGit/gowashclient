import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/app_runtime.dart';
import '../models/edit_profile_result.dart';
import '../models/profile_data.dart';

class ProfileService {
  const ProfileService();

  bool get supportsFirebaseProfile => AppRuntime.supportsFirebaseBackend;

  Future<ProfileData> loadProfile() async {
    if (!supportsFirebaseProfile) {
      return ProfileData.fallback();
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return ProfileData.fallback();
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      return ProfileData.fromSources(
        user: user,
        firestoreData: snapshot.data(),
      );
    } catch (_) {
      return ProfileData.fromSources(user: user);
    }
  }

  Future<ProfileData> updateProfile({
    required ProfileData currentProfile,
    required EditProfileResult result,
  }) async {
    final ProfileData nextProfile = currentProfile.copyWith(
      fullName: result.fullName,
      phoneNumber: result.phoneNumber,
    );

    if (supportsFirebaseProfile) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if ((user.displayName ?? '').trim() != nextProfile.fullName) {
          await user.updateDisplayName(nextProfile.fullName);
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': nextProfile.fullName,
          'phoneNumber': nextProfile.phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    return nextProfile;
  }

  Future<void> logout() async {
    if (supportsFirebaseProfile) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> deleteAccount() async {
    if (!supportsFirebaseProfile) {
      throw StateError(
        'Account deletion is available only on signed-in mobile.',
      );
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in account was found.');
    }

    final String userId = user.uid;
    await user.delete();
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
