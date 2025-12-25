// lib/screens/customer/vendor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../routes.dart';

class VendorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> vendorData;

  const VendorProfileScreen({super.key, required this.vendorData});

  @override
  Widget build(BuildContext context) {
    final catalog = (vendorData['serviceCatalog'] as List<dynamic>?) ?? [];
    final gallery = (vendorData['galleryImages'] as List<dynamic>?) ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendorData['shopName'] ?? 'Unknown Store', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text(vendorData['shopCategory'] ?? 'General', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            const Icon(Icons.star, color: Colors.green, size: 20),
                            Text(vendorData['rating']?.toString() ?? '5.0', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Row(
                    children: [
                      _buildQuickAction(Icons.phone, 'Call', () => _launchCaller(vendorData['phoneNumber'])),
                      const SizedBox(width: 12),
                      _buildQuickAction(Icons.directions, 'Map', () {}),
                      const SizedBox(width: 12),
                      _buildQuickAction(Icons.share, 'Share', () {}),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('About Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(vendorData['description'] ?? 'No description available for this store.', style: const TextStyle(color: Colors.grey, height: 1.5)),
                  
                  if (gallery.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text('Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: gallery.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(gallery[i], width: 160, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Text('Catalog / Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (catalog.isEmpty)
                    const Text('No items listed in the catalog yet.', style: TextStyle(color: Colors.grey))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: catalog.length,
                      itemBuilder: (ctx, i) {
                        final item = catalog[i] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(item['name'] ?? ''),
                            subtitle: item['price'] != null ? Text('₹${item['price']}') : null,
                            trailing: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                context, 
                                Routes.createRequest, 
                                arguments: {'initialItem': item['name'], 'initialCategory': vendorData['shopCategory']}
                              ),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36), padding: EdgeInsets.zero),
                              child: const Text('Request', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        child: CustomButton(
          text: 'Send Custom Request',
          icon: Icons.chat_bubble_outline,
          onPressed: () => Navigator.pushNamed(
            context, 
            Routes.createRequest, 
            arguments: {'initialCategory': vendorData['shopCategory']}
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              vendorData['imageUrl'] ?? 'https://via.placeholder.com/400',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppTheme.primary.withOpacity(0.1)),
            ),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)]))),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _launchCaller(String? phone) async {
    if (phone == null) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
