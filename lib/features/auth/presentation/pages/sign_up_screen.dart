import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import '../../utils/auth_validators.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/auth_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = AppRoutes.signUp;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = const AuthService();

  bool _showPassword = false;
  bool _passwordsMatch = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_syncPasswordState);
    _confirmPasswordController.addListener(_syncPasswordState);
  }

  void _syncPasswordState() {
    final bool nextValue =
        _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
    if (_passwordsMatch != nextValue) {
      setState(() {
        _passwordsMatch = nextValue;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _openLogin() {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  Future<void> _completeAuth() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
    });

    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String phoneNumber = normalizeUsPhoneNumber(_phoneController.text);

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = AppTexts.authValidationFullName;
      });
      return;
    }
    if (phoneNumber.length != 12) {
      setState(() {
        _errorMessage = AppTexts.authValidationPhone;
      });
      return;
    }
    if (!looksLikeEmail(email)) {
      setState(() {
        _errorMessage = AppTexts.authValidationEmail;
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = AppTexts.authValidationPasswordLength;
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = AppTexts.authValidationPasswordMismatch;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.createAccount(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.authSignUpSuccess)));
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.mainSearch, (route) => false);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = messageForAuthError(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppTexts.authSignUpFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topActionLabel: AppTexts.authTopLoginAction,
      onTopActionPressed: _openLogin,
      title: AppTexts.authCreateAccountTitle,
      subtitle: AppTexts.authCreateAccountSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(label: AppTexts.authLabelFullName),
          AuthTextField(
            controller: _fullNameController,
            autofocus: true,
            highlightBorder: true,
            textInputAction: TextInputAction.next,
            hintText: AppTexts.authHintName,
          ),
          const SizedBox(height: 18),
          const FieldLabel(label: AppTexts.authLabelPhone),
          PhoneField(phoneController: _phoneController),
          const SizedBox(height: 18),
          const FieldLabel(label: AppTexts.authLabelEmail),
          AuthTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            hintText: AppTexts.authHintEmail,
          ),
          const SizedBox(height: 18),
          const FieldLabel(label: AppTexts.authLabelPassword),
          AuthTextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            textInputAction: TextInputAction.next,
            hintText: AppTexts.authHintPassword,
            suffix: IconButton(
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword ? Icons.visibility_off_rounded : Icons.visibility,
                color: const Color(0xFF8A8F98),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const FieldLabel(label: AppTexts.authLabelConfirmPassword),
          AuthTextField(
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            hintText: AppTexts.authHintPassword,
            suffix: _passwordsMatch
                ? const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(
                      Icons.check_rounded,
                      color: Color(0xFF43B95A),
                      size: 28,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 18),
          if (_errorMessage != null) ...[
            AuthMessageBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          const TermsText(),
          const SizedBox(height: 26),
          PrimaryAuthButton(
            label: AppTexts.authPrimaryCreateAccount,
            onPressed: _completeAuth,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}
