import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../data/models/edit_profile_result.dart';
import '../../data/models/profile_data.dart';
import '../../utils/profile_formatters.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({required this.profile, super.key});

  final ProfileData profile;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(
      text: formatPhoneNumber(widget.profile.phoneNumber),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final String fullName = _fullNameController.text.trim();
    final String phoneInput = _phoneController.text.trim();

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = AppTexts.authValidationFullName;
      });
      return;
    }

    if (!isEditablePhoneNumber(phoneInput)) {
      setState(() {
        _errorMessage = AppTexts.profileValidationPhone;
      });
      return;
    }

    Navigator.of(context).pop(
      EditProfileResult(
        fullName: fullName,
        phoneNumber: normalizePhoneNumber(phoneInput),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 24, 12, insets.bottom + 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DBE2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                AppTexts.profileEditTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101113),
                ),
              ),
              const SizedBox(height: 16),
              const _SheetFieldLabel(label: AppTexts.profileEditLabelFullName),
              const SizedBox(height: 8),
              _SheetTextField(
                controller: _fullNameController,
                hintText: AppTexts.authHintName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              const _SheetFieldLabel(label: AppTexts.authLabelPhone),
              const SizedBox(height: 8),
              _SheetTextField(
                controller: _phoneController,
                hintText: AppTexts.authHintPhone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF5A3C),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF101113),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text(AppTexts.profileEditSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetFieldLabel extends StatelessWidget {
  const _SheetFieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6F7682),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
