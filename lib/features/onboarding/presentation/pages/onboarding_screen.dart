import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/onboarding_page_data.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      accent: Color(0xFF123D95),
      service: AppTexts.onboardingServiceCar,
      subtitle: AppTexts.onboardingSubtitleCar,
      imagePath: 'assets/images/service_car.svg',
    ),
    OnboardingPageData(
      accent: Color(0xFF9A6C06),
      service: AppTexts.onboardingServiceInterior,
      subtitle: AppTexts.onboardingSubtitleInterior,
      imagePath: 'assets/images/service_interior.svg',
    ),
    OnboardingPageData(
      accent: Color(0xFF0B9770),
      service: AppTexts.onboardingServiceExterior,
      subtitle: AppTexts.onboardingSubtitleExterior,
      imagePath: 'assets/images/service_exterior.svg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_currentPage == _pages.length - 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.signUp);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            return OnboardingPageView(
              key: ValueKey('onboarding-page-$index'),
              data: _pages[index],
              currentIndex: _currentPage,
              pageCount: _pages.length,
              onContinue: _onContinue,
            );
          },
        ),
      ),
    );
  }
}
