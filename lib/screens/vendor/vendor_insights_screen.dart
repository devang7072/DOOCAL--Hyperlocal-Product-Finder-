// lib/screens/vendor/vendor_insights_screen.dart
import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

class VendorInsightsScreen extends StatelessWidget {
  const VendorInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInsightCard('Total Leads', '182', Icons.flash_on, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildInsightCard('Earnings', '₹12.4k', Icons.account_balance_wallet, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInsightCard('Profile Views', '1.2k', Icons.visibility, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildInsightCard('Avg. Rating', '4.8', Icons.star, Colors.amber)),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Conversion Funnel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFunnelStep('Views', '1,240', 1.0, Colors.blue),
            _buildFunnelStep('Leads Received', '182', 0.6, Colors.orange),
            _buildFunnelStep('Chats Initiated', '45', 0.3, Colors.purple),
            _buildFunnelStep('Deals Closed', '28', 0.15, Colors.green),
            
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Icon(Icons.rocket_launch, color: Colors.white, size: 40),
                  SizedBox(height: 16),
                  Text(
                    'Reach more customers!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upgrade to DOOCAL Gold to get 2x more visibility in your local area.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFunnelStep(String label, String value, double widthFactor, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Stack(
              children: [
                Container(height: 12, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6))),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: Container(height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
