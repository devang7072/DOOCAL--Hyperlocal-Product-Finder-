// lib/screens/vendor/vendor_onboarding_benefits.dart
import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../routes.dart';
import '../../widgets/widgets.dart';

class VendorOnboardingBenefits extends StatefulWidget {
  const VendorOnboardingBenefits({super.key});

  @override
  State<VendorOnboardingBenefits> createState() => _VendorOnboardingBenefitsState();
}

class _VendorOnboardingBenefitsState extends State<VendorOnboardingBenefits> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _benefits = [
    {
      'title': 'Zero Commissions',
      'subtitle': 'Keep 100% of your earnings. We don\'t charge any commission on your sales.',
      'image': 'assets/images/benefit1.png', // Placeholder logic for now
      'icon': '💰',
    },
    {
      'title': 'Hyperlocal Leads',
      'subtitle': 'Get notified instantly when someone within 2km searching for your products.',
      'icon': '📍',
    },
    {
      'title': 'Direct Customer Chat',
      'subtitle': 'Talk directly to customers, clarify doubts and close deals faster.',
      'icon': '💬',
    },
    {
      'title': 'Daily Payouts',
      'subtitle': 'No waiting for weeks. Get your money settled in your bank account daily.',
      'icon': '🏦',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (v) => setState(() => _currentPage = v),
              itemCount: _benefits.length,
              itemBuilder: (context, index) {
                final benefit = _benefits[index];
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(benefit['icon']!, style: const TextStyle(fontSize: 80)),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        benefit['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        benefit['subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_benefits.length, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppTheme.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: _currentPage == _benefits.length - 1 ? 'Start Selling' : 'Next',
            onPressed: () {
              if (_currentPage < _benefits.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              } else {
                Navigator.pushReplacementNamed(context, Routes.vendorSetup);
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, Routes.vendorSetup),
            child: const Text('Skip intro', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
