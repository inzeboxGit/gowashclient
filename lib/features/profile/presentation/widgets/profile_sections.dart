import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../data/models/profile_data.dart';
import '../../utils/profile_formatters.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.isBusy,
    required this.onBack,
    required this.onEdit,
    super.key,
  });

  final bool isBusy;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF101113),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const Text(
            AppTexts.profileHeader,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101113),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: isBusy ? null : onEdit,
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit_rounded),
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF101113),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({required this.profile, super.key});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileAvatar(name: profile.fullName),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101113),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F6FB), Color(0xFFE2E8F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF123D95),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initialsFromName(name),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF8A909B),
        letterSpacing: 0.4,
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.label,
    super.key,
    this.trailingText,
    this.showChevron = false,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final bool showChevron;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isDestructive
        ? const Color(0xFFFF5A3C)
        : const Color(0xFF101113);
    final Color iconColor = isDestructive
        ? const Color(0xFFFF5A3C)
        : const Color(0xFF8A909B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          child: Row(
            children: [
              Icon(icon, size: 21, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isDestructive
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A909B),
                  ),
                ),
              if (showChevron) ...[
                if (trailingText != null) const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: isDestructive
                      ? const Color(0xFFFF5A3C)
                      : const Color(0xFF9CA2AD),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
