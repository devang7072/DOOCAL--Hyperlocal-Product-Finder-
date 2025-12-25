// lib/screens/customer/customer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_auth_service.dart';
import '../../core/themes/app_theme.dart';
import '../../routes.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService().currentUser();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: user == null 
        ? const Center(child: Text('Please login'))
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final data = snapshot.data!.data() as Map<String, dynamic>?;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(data?['name'] ?? 'Guest User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.phoneNumber ?? '', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    
                    _buildProfileTile(Icons.location_on_outlined, 'My Addresses', 'Manage saved locations'),
                    _buildProfileTile(Icons.payment, 'Payment Methods', 'UPI, Cards, Wallets'),
                    _buildProfileTile(Icons.favorite_border, 'Favorites', 'Saved shops & services'),
                    _buildProfileTile(Icons.help_outline, 'Help & Support', 'FAQs, Contact us'),
                    
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () async {
                         await FirebaseAuthService().signOut();
                         Navigator.pushNamedAndRemoveUntil(context, Routes.splash, (route) => false);
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Logout', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
