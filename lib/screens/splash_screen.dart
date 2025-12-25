// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/firebase_auth_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    
    // Check state after animation + buffer
    Future.delayed(const Duration(seconds: 2), _checkStateAndNavigate);
  }

  Future<void> _checkStateAndNavigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final user = FirebaseAuthService().currentUser();

    if (mounted) {
      if (!seenOnboarding) {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      } else if (user != null) {
        // User is logged in, use AuthProvider to check their profile in Firestore and route correctly
        if (mounted) {
           final authProvider = Provider.of<AuthProvider>(context, listen: false);
           await authProvider.checkUserAndNavigate(context, user);
        }
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white, // Clean white background for the logo
        ),
        child: Stack(
          children: [
            // Abstract background dots/circles
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.03),
                ),
              ),
            ),
            
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Luxury Logo Image
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Minimalist Tagline removed as it's in the logo image or we can keep it
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Loading & Version
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor.withOpacity(0.2)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'v1.0.0'.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
