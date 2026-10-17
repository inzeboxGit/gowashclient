import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/profile_formatters.dart';

class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.language,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String language;

  factory ProfileData.fallback() {
    return const ProfileData(
      fullName: 'Alan Anderson',
      email: 'alan.anderson@mail.com',
      phoneNumber: '+14094446666',
      language: 'English',
    );
  }

  factory ProfileData.fromSources({
    User? user,
    Map<String, dynamic>? firestoreData,
  }) {
    final String fullName =
        readProfileString(firestoreData?['fullName']) ??
        readProfileString(user?.displayName) ??
        'Alan Anderson';
    final String email =
        readProfileString(firestoreData?['email']) ??
        readProfileString(user?.email) ??
        'alan.anderson@mail.com';
    final String phoneNumber =
        readProfileString(firestoreData?['phoneNumber']) ??
        readProfileString(user?.phoneNumber) ??
        '+14094446666';

    return ProfileData(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      language: 'English',
    );
  }

  ProfileData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? language,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      language: language ?? this.language,
    );
  }
}
