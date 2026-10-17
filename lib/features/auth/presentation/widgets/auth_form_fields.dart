import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gowashclient/core/config/app_texts.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF9DA2AD),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.hintText,
    this.obscureText = false,
    this.suffix,
    this.highlightBorder = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;
  final bool obscureText;
  final Widget? suffix;
  final bool highlightBorder;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101113),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF2F3F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0x998E93A0),
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlightBorder
                ? const Color(0xFF23499A)
                : const Color(0xFFE2E4E8),
            width: highlightBorder ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlightBorder
                ? const Color(0xFF23499A)
                : const Color(0xFFE2E4E8),
            width: highlightBorder ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF23499A), width: 2),
        ),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({required this.phoneController, super.key});

  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E4E8)),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE0E2E6))),
            ),
            child: const Row(
              children: [
                FlagBadge(),
                SizedBox(width: 6),
                Text(
                  '+1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E93A0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101113),
              ),
              decoration: const InputDecoration(
                hintText: AppTexts.authHintPhone,
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0x998E93A0),
                ),
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlagBadge extends StatelessWidget {
  const FlagBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E2E6)),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: List.generate(
                6,
                (index) => Expanded(
                  child: ColoredBox(
                    color: index.isEven
                        ? const Color(0xFFE35A59)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 10,
                height: 11,
                color: const Color(0xFF23499A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Color(0xFF8E93A0),
          ),
          children: [
            TextSpan(text: AppTexts.authTermsPrefix),
            TextSpan(
              text: AppTexts.authTermsAndConditions,
              style: TextStyle(
                color: Color(0xFF143C94),
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: AppTexts.authTermsAndJoiner),
            TextSpan(
              text: AppTexts.authPrivacyPolicy,
              style: TextStyle(
                color: Color(0xFF143C94),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEEEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFB5473B),
        ),
      ),
    );
  }
}

class PrimaryAuthButton extends StatelessWidget {
  const PrimaryAuthButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final Future<void> Function() onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B0C0E),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: const Color(0xFF0B0C0E),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}
