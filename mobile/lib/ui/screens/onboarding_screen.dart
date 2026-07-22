import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';

import '../../ui/themes/app_theme.dart';
=======
import '../../ui/themes/app_theme.dart';
import 'login_screen.dart';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.home_repair_service_rounded,
      title: 'Expert Technicians',
      description: 'Connect with skilled professionals for all your home repair needs.',
      color: AppTheme.pastelPink,
      iconColor: AppTheme.primaryColor,
    ),
    OnboardingPage(
      icon: Icons.calendar_today_rounded,
      title: 'Easy Booking',
      description: 'Schedule appointments at your convenience with just a few taps.',
      color: AppTheme.pastelBlue,
      iconColor: AppTheme.info,
    ),
    OnboardingPage(
      icon: Icons.verified_rounded,
      title: 'Quality Assured',
      description: 'Verified technicians with ratings and reviews for your peace of mind.',
      color: AppTheme.pastelGreen,
      iconColor: AppTheme.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _getStarted() {
<<<<<<< HEAD
    context.go('/login');
=======
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: TextButton(
                  onPressed: _getStarted,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Bottom section
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  // Page indicators
                  _buildPageIndicators(),
                  
                  const SizedBox(height: AppTheme.spacingXl),
                  
                  // Get Started button
                  SoftGradientButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _getStarted();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppTheme.primaryColor : AppTheme.textMuted,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with pastel background
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color,
              borderRadius: BorderRadius.circular(AppTheme.radius2xl),
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.iconColor,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing2xl),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color iconColor;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.iconColor,
  });
}
