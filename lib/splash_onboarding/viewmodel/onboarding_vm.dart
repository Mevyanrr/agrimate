import 'package:agrimate/splash_onboarding/model/onboarding.dart';
import 'package:flutter/material.dart';

class OnboardingViewModel extends ChangeNotifier {
  final PageController pageController = PageController();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  final List<OnboardingModel> pages = const [
    OnboardingModel(
      imagePath: 'assets/images/onboarding1.png',
      iconPath: 'assets/icons/tea.svg',
      title: 'Ceritakan\nRencana Panenmu',
      description:
          'Estimasi hasil panenmu sebelum waktunya tiba. Tanpa antri, tanpa ribet.',
      buttonText: 'Lanjut',
    ),
    OnboardingModel(
      imagePath: 'assets/images/onboarding2.png',
      iconPath: 'assets/icons/handshake.svg', 
      title: 'Kami Carikan\nPembeli yang Cocok',
      description:
          'Sistem kami otomatis mencocokan hasil panenmu dengan pembeli yang membutuhkan',
      buttonText: 'Mulai',
    ),
    OnboardingModel(
      imagePath: 'assets/images/onboarding3.png',
      iconPath: 'assets/icons/checked.svg',
      title: 'Ceritakan\nRencana Panenmu',
      description:
          'Pilih yang cocok dan setujui kesepakatan, terima pesanan, pesanan akan diproses.',
      buttonText: 'Lanjut',
    ),
  ];

  bool get isLastPage => _currentPage == pages.length - 1;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void onNextPressed(BuildContext context) {
    if (isLastPage) {
      _goToRole(context);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void onSkipPressed(BuildContext context) {
    _goToRole(context);
  }

  void _goToRole(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/role-selection');
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}