import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/config/app_texts.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_runtime.dart';
import 'features/home/presentation/pages/main_search_screen.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';

class GoWashApp extends StatelessWidget {
  const GoWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppTexts.appTitle,
      theme: AppTheme.lightTheme,
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: AppRuntime.supportsFirebaseBackend
          ? const _AuthGateway()
          : const OnboardingScreen(),
    );
  }
}

class _AuthGateway extends StatelessWidget {
  const _AuthGateway();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const MainSearchScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}
