import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../shared/widgets/asset_svg_image.dart';
import '../../data/models/onboarding_page_data.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    required this.data,
    required this.currentIndex,
    required this.pageCount,
    required this.onContinue,
    super.key,
  });

  final OnboardingPageData data;
  final int currentIndex;
  final int pageCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Text(
            AppTexts.onboardingChooseService,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(child: _ServiceIllustration(data: data)),
          ),
          _DotsIndicator(
            pageCount: pageCount,
            currentIndex: currentIndex,
            accent: data.accent,
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              key: Key('service-title-${data.service.toLowerCase()}'),
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101113),
                ),
                children: [
                  const TextSpan(text: AppTexts.onboardingGoWashPrefix),
                  TextSpan(
                    text: data.service,
                    style: TextStyle(color: data.accent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(data.subtitle, style: textTheme.bodyLarge),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(AppTexts.onboardingMapHint, style: textTheme.bodyLarge),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B0C0E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text(AppTexts.onboardingContinue),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceIllustration extends StatelessWidget {
  const _ServiceIllustration({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      height: 360,
      child: Center(
        child: AssetSvgImage(
          assetPath: data.imagePath,
          width: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.pageCount,
    required this.currentIndex,
    required this.accent,
  });

  final int pageCount;
  final int currentIndex;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 21 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? accent : const Color(0xFFD7D8DD),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
