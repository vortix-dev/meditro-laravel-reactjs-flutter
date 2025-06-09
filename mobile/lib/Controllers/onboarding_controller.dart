import 'package:flutter/material.dart';
import 'package:meditro/Views/Auth/login_view.dart';

class OnboardingController {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> screens = [
    {
      'image': 'assets/img/onboarding1.png',
      'logo': 'assets/img/logo.png',
      'title': 'Bienvenue sur MediTro',
      'subtitle': 'Votre santé, notre priorité',
      'width': 250.0,
      'height': 250.0,
    },
    {
      'image': 'assets/img/onboarding2.png',
      'logo': 'assets/img/logo.png',
      'title': 'Prenez rendez-vous facilement',
      'subtitle':
          'Choisissez votre médecin et votre créneau en quelques clics.',
      'width': 250.0,
      'height': 250.0,
    },
    {
      'image': 'assets/img/onboarding3.png',
      'logo': 'assets/img/logo.png',
      'title': 'Suivez vos dossiers médicaux',
      'subtitle': 'Consultez vos antécédents et traitements à tout moment.',
      'width': 250.0,
      'height': 250.0,
    },
  ];

  void onPageChanged(int index) {
    currentPage = index;
  }

  void finishOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: currentPage == index ? 12 : 8,
      height: currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? const Color(0xFFF17732) : Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
