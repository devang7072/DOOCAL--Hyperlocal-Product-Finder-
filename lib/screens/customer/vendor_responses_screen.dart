// lib/screens/customer/vendor_responses_screen.dart
import 'package:flutter/material.dart';
import '../../models/request_model.dart';
import '../../core/themes/app_theme.dart';

class VendorResponsesScreen extends StatelessWidget {
  final RequestModel request;

  const VendorResponsesScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Replies'),
      ),
      body: Column(
        children: [
          _buildRequestHeader(context),
          Expanded(
            child: request.responses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: request.responses.length,
                    itemBuilder: (context, index) {
                      final response = request.responses[index];
                      return _buildResponseCard(context, response);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.category,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const Spacer(),
              Text(
                '${request.responses.length} responses',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(BuildContext context, VendorResponse response) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(response.vendorName[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(response.vendorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.accent, size: 16),
                          const SizedBox(width: 4),
                          Text(response.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text('${response.distance.toStringAsFixed(1)} km'),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${response.price.toInt()}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text('ETA: ${response.eta}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to Chat
                  },
                  child: const Text('Chat'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Accept Offer
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 45),
                    elevation: 0,
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Waiting for vendors to respond...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Usually takes 2-5 minutes',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
