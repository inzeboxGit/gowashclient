import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.accent,
    required this.service,
    required this.subtitle,
    required this.imagePath,
  });

  final Color accent;
  final String service;
  final String subtitle;
  final String imagePath;
}
