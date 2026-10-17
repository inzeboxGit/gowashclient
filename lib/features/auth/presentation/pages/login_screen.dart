import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gowashclient/core/config/app_texts.dart';
import 'package:gowashclient/core/routes/app_routes.dart';
import 'package:gowashclient/features/auth/data/services/auth_service.dart';
import 'package:gowashclient/features/auth/presentation/widgets/auth_form_fields.dart';
import 'package:gowashclient/features/auth/presentation/widgets/auth_layout.dart';
import 'package:gowashclient/features/auth/utils/auth_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = AppRoutes.login;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = const AuthService();

  bool _showPassword = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _completeAuth() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    if (!looksLikeEmail(email)) {
      setState(() {
        _errorMessage = AppTexts.authValidationEmail;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _errorMessage = AppTexts.authValidationPasswordMissing;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.signIn(email: email, password: password);
      if (!mounted) {
        return;
      }
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
        _errorMessage = AppTexts.authLoginFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();
    final String email = _emailController.text.trim();
    if (!looksLikeEmail(email)) {
      setState(() {
        _errorMessage = AppTexts.authValidationResetNeedsEmail;
      });
      return;
    }

    try {
      await _authService.sendResetEmail(email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.authResetSent)));
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = messageForAuthError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF101113),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      title: AppTexts.authWelcomeBackTitle,
      subtitle: AppTexts.authWelcomeBackSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            textInputAction: TextInputAction.done,
            hintText: AppTexts.authHintPassword,
            suffix: IconButton(
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword ? Icons.visibility_off_rounded : Icons.visibility,
                color: const Color(0xFF8A8F98),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _sendResetEmail,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF143C94),
              ),
              child: const Text(
                AppTexts.authForgotPassword,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_errorMessage != null) ...[
            AuthMessageBanner(message: _errorMessage!),
            const SizedBox(height: 18),
          ],
          PrimaryAuthButton(
            label: AppTexts.authPrimaryLogin,
            onPressed: _completeAuth,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}
