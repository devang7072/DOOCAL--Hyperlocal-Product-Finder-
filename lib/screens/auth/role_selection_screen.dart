// lib/screens/auth/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../routes.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // We'll use this to show loading when saving the role
  bool isSaving = false;

  void _selectRole(String role) async {
    setState(() => isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Update role in Firestore
    await auth.updateUserRole(context, role);
    
    if (mounted) {
      if (role == 'vendor') {
        // Check if vendor has already completed setup
        final user = auth.user;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = doc.data();
          if (data != null && data['isSetupComplete'] == true) {
            Navigator.pushNamedAndRemoveUntil(context, Routes.vendorHome, (route) => false);
          } else {
            // New or incomplete vendors go to Benefits Onboarding
            Navigator.pushReplacementNamed(context, Routes.vendorOnboarding);
          }
        }
      } else {
        // Customers go straight to Home
        Navigator.pushNamedAndRemoveUntil(context, Routes.customerHome, (route) => false);
      }
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Who are you?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose how you want to use DOOCAL',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildRoleCard(
                context,
                title: 'I am a Customer',
                subtitle: 'I want to find products & services nearby.',
                icon: Icons.person_pin_circle,
                color: Theme.of(context).primaryColor,
                onTap: () => _selectRole('customer'),
              ),
              const SizedBox(height: 24),
              _buildRoleCard(
                context,
                title: 'I am a Sender / Vendor',
                subtitle: 'I want to receive requests and sell.',
                icon: Icons.storefront_rounded,
                color: AppTheme.accent, // Using amber/accent for vendor distinction
                onTap: () => _selectRole('vendor'),
              ),
              const Spacer(),
              if (isSaving)
                const Center(child: CircularProgressIndicator())
              else
                const SizedBox(height: 48), // Placeholder for spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
