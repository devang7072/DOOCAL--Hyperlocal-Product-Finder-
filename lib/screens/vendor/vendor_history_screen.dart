import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_auth_service.dart';
import '../chat/chat_screen.dart';
import '../../widgets/widgets.dart';
import '../../core/animations.dart';

class VendorHistoryScreen extends StatelessWidget {
  const VendorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService().currentUser();
    if (user == null) return const Scaffold(body: EmptyState(icon: Icons.lock_outline, title: 'Login Required', message: 'Please login to view your job history.'));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Accepted Job History'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('vendorIds', arrayContains: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const ShimmerListCard(),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.work_outline_rounded,
              title: 'No Accepted Jobs',
              message: 'When you accept a customer request, it will appear here for management.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return FadeInSlide(
                delay: index * 0.1,
                child: _buildJobCard(context, data, docs[index].id, user.uid),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> data, String requestId, String vendorId) {
    final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('MMM d, h:mm a').format(timestamp) : 'Recently';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.check_circle_outline, color: Colors.green[600], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['item'] ?? 'Unknown Item', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Accepted on $timeStr', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['category'] ?? 'General',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Open Chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  height: 48,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        requestId: requestId,
                        otherPartyName: 'Customer', // Simplified for demo
                      ),
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'View Details',
                  variant: ButtonVariant.secondary,
                  height: 48,
                  onPressed: () {
                     // Potential for a detail sheet here
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
