import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/firebase_auth_service.dart';
import '../chat/chat_screen.dart';
import '../../core/animations.dart';
import 'rating_dialog.dart';
import '../../services/rating_service.dart';
import '../../widgets/widgets.dart';

class CustomerRequestsScreen extends StatelessWidget {
  const CustomerRequestsScreen({super.key});

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    
    try {
       if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
         throw 'Could not launch maps';
       }
    } catch (e) {
       debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService().currentUser();
    if (user == null) return const Scaffold(body: EmptyState(icon: Icons.lock_outline, title: 'Login Required', message: 'Please login to view your requests.'));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('My Discovery History'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: user.uid)
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
              icon: Icons.history_rounded,
              title: 'No Requests Yet',
              message: 'When you create a request, it will appear here for tracking.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final responses = (data['responses'] as List<dynamic>? ?? []);
              
              return FadeInSlide(
                delay: index * 0.1,
                child: _buildRequestCard(context, data, responses, docs[index].id, user.uid),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> data, List<dynamic> responses, String docId, String userId) {
    final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('MMM d, h:mm a').format(timestamp) : '';
    bool hasOffers = responses.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['item'] ?? 'Unknown Item', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${data['category']} • $timeStr', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                _buildStatusBadge(hasOffers, responses.length),
              ],
            ),
          ),
          if (hasOffers) ...[
            Divider(height: 1, color: Colors.grey[100]),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text('View ${responses.length} Vendor Offers', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)
                  ),
                  iconColor: Theme.of(context).primaryColor,
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: responses.map((resp) => _buildVendorOfferCard(context, resp, docId, userId)).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool hasOffers, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasOffers ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hasOffers ? '$count Offers' : 'Searching...',
        style: TextStyle(
          color: hasOffers ? Colors.green[700] : Colors.orange[800],
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVendorOfferCard(BuildContext context, dynamic resp, String docId, String userId) {
    final rMap = resp as Map<String, dynamic>;
    if (rMap['status'] != 'accepted') return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: rMap['imageUrl'] != null ? NetworkImage(rMap['imageUrl']) : null,
                child: rMap['imageUrl'] == null ? const Icon(Icons.storefront) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rMap['shopName'] ?? 'Vendor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (rMap['bestProduct'] != null)
                      Text("Specialty: ${rMap['bestProduct']}", style: TextStyle(fontSize: 12, color: Colors.blueGrey[400])),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline, size: 20, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Chat',
                  height: 44,
                  variant: ButtonVariant.secondary,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        requestId: docId,
                        otherPartyName: rMap['shopName'] ?? 'Vendor',
                      ),
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Navigate',
                  height: 44,
                  icon: Icons.near_me_rounded,
                  onPressed: () {
                    if (rMap['latitude'] != null) _launchMaps(rMap['latitude'], rMap['longitude']);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final stars = await showDialog<int>(
                context: context,
                builder: (_) => RatingDialog(vendorName: rMap['shopName'] ?? 'Vendor'),
              );
              if (stars != null && context.mounted) {
                await RatingService().submitRating(vendorId: rMap['vendorId'], customerId: userId, stars: stars.toDouble());
                if (context.mounted) await SuccessAnimation.show(context, message: 'Rating Submitted!');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded, size: 18, color: Colors.amber[800]),
                  const SizedBox(width: 6),
                  Text('Rate Vendor', style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
