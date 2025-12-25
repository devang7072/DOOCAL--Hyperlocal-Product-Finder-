// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';
import '../widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Ask Anything",
      "text": "Need a product? Just post a request and let nearby vendors know.",
      "icon": "ask"
    },
    {
      "title": "Hyperlocal Connect",
      "text": "Vendors within 2km receive your request instantly.",
      "icon": "connect"
    },
    {
      "title": "Get it Fast",
      "text": "Chat, navigate, and get what you need in minutes.",
      "icon": "fast"
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background that changes per page
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _currentPage == 0
                    ? [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)]
                    : _currentPage == 1
                        ? [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)]
                        : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                if (_currentPage < _onboardingData.length - 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _currentPage = value),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) => OnboardingContent(
                      title: _onboardingData[index]["title"]!,
                      text: _onboardingData[index]["text"]!,
                      iconType: _onboardingData[index]["icon"]!,
                    ),
                  ),
                ),
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Next/Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: CustomButton(
                    text: _currentPage == _onboardingData.length - 1 ? "Get Started" : "Next",
                    icon: _currentPage == _onboardingData.length - 1 ? Icons.rocket_launch : Icons.arrow_forward,
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String text;
  final String iconType;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.text,
    required this.iconType,
  });

  IconData _getIcon() {
    switch (iconType) {
      case 'ask': return Icons.mic_none_outlined;
      case 'connect': return Icons.hub_outlined;
      case 'fast': return Icons.rocket_launch_outlined;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
