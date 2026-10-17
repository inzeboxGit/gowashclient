import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../data/models/edit_profile_result.dart';
import '../../data/models/profile_data.dart';
import '../../data/services/profile_service.dart';
import '../../utils/profile_formatters.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_sections.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = AppRoutes.profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = const ProfileService();

  ProfileData _profile = ProfileData.fallback();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final ProfileData loadedProfile = await _profileService.loadProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = loadedProfile;
      _isLoading = false;
    });
  }

  Future<void> _openEditProfile() async {
    if (_isSaving) {
      return;
    }

    final EditProfileResult? result =
        await showModalBottomSheet<EditProfileResult>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => EditProfileSheet(profile: _profile),
        );

    if (result == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final ProfileData nextProfile = await _profileService.updateProfile(
        currentProfile: _profile,
        result: result,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = nextProfile;
      });
      _showSnackBar(AppTexts.profileUpdated);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(AppTexts.profileUpdateFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _profileService.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(AppTexts.profileLogoutFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_isSaving) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppTexts.profileDeleteTitle),
          content: const Text(AppTexts.profileDeleteContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppTexts.profileCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF5A3C),
              ),
              child: const Text(AppTexts.profileDelete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!_profileService.supportsFirebaseProfile) {
      _showSnackBar(AppTexts.profileDeleteMobileOnly);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _profileService.deleteAccount();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error.code == 'requires-recent-login'
          ? AppTexts.profileDeleteRequiresRelogin
          : AppTexts.profileDeleteFailed;
      _showSnackBar(message);
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(AppTexts.profileDeleteFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppTexts.appTitle,
      applicationVersion: AppTexts.appVersion,
      applicationLegalese: AppTexts.appLegalese,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      isBusy: _isSaving,
                      onBack: () => Navigator.of(context).pop(),
                      onEdit: _openEditProfile,
                    ),
                    const SizedBox(height: 18),
                    ProfileSummaryCard(profile: _profile),
                    const SizedBox(height: 18),
                    const SectionTitle(
                      label: AppTexts.profileSectionPersonalInfo,
                    ),
                    const SizedBox(height: 10),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: Icons.phone_rounded,
                          label: formatPhoneNumber(_profile.phoneNumber),
                        ),
                        SettingsRow(
                          icon: Icons.mail_rounded,
                          label: _profile.email,
                        ),
                        const SettingsRow(
                          icon: Icons.lock_rounded,
                          label: AppTexts.profileMaskedPassword,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: Icons.location_on_rounded,
                          label: AppTexts.profileAddresses,
                          showChevron: true,
                          onTap: () =>
                              _showSnackBar(AppTexts.profileAddressSoon),
                        ),
                        SettingsRow(
                          icon: Icons.language_rounded,
                          label: AppTexts.profileLanguage,
                          trailingText: _profile.language,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const SectionTitle(label: AppTexts.profileSectionResources),
                    const SizedBox(height: 10),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: Icons.info_outline_rounded,
                          label: AppTexts.profileAbout,
                          showChevron: true,
                          onTap: _showAbout,
                        ),
                        SettingsRow(
                          icon: Icons.manage_accounts_outlined,
                          label: AppTexts.profileAccountAndData,
                          showChevron: true,
                          onTap: () =>
                              _showSnackBar(AppTexts.profileAccountAndDataSoon),
                        ),
                        SettingsRow(
                          icon: Icons.credit_card_rounded,
                          label: AppTexts.profilePayments,
                          showChevron: true,
                          onTap: () =>
                              _showSnackBar(AppTexts.profilePaymentsSoon),
                        ),
                        SettingsRow(
                          icon: Icons.help_outline_rounded,
                          label: AppTexts.profileUsingApp,
                          showChevron: true,
                          onTap: () => _showSnackBar(AppTexts.profileHelpSoon),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const SectionTitle(label: AppTexts.profileSectionAccount),
                    const SizedBox(height: 10),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: Icons.quiz_outlined,
                          label: AppTexts.profileFaq,
                          showChevron: true,
                          onTap: () => _showSnackBar(AppTexts.profileFaqSoon),
                        ),
                        SettingsRow(
                          icon: Icons.logout_rounded,
                          label: AppTexts.profileLogout,
                          showChevron: true,
                          onTap: _logout,
                        ),
                        SettingsRow(
                          icon: Icons.delete_outline_rounded,
                          label: AppTexts.profileDeleteAccount,
                          showChevron: true,
                          isDestructive: true,
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
