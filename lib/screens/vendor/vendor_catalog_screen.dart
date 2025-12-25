// lib/screens/vendor/vendor_catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_auth_service.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/widgets.dart';

class VendorCatalogScreen extends StatefulWidget {
  const VendorCatalogScreen({super.key});

  @override
  State<VendorCatalogScreen> createState() => _VendorCatalogScreenState();
}

class _VendorCatalogScreenState extends State<VendorCatalogScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addItem() async {
    if (_itemController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuthService().currentUser();
      if (user != null) {
        final newItem = {
          'name': _itemController.text.trim(),
          'price': _priceController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'isAvailable': true,
        };
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'serviceCatalog': FieldValue.arrayUnion([newItem])
        });
        
        _itemController.clear();
        _priceController.clear();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24, left: 24, right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add New Item/Service', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _itemController,
              decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.shopping_bag_outlined)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (Optional)', prefixIcon: Icon(Icons.currency_rupee)),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Product Image URL (Optional)', prefixIcon: Icon(Icons.image_outlined)),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add to Catalog',
              onPressed: _addItem,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService().currentUser();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 30),
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: user == null 
        ? const EmptyState(
            icon: Icons.lock_outline,
            title: 'Authentication Required',
            message: 'Please Login to manage your catalog',
          )
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final catalog = (data?['serviceCatalog'] as List<dynamic>?) ?? [];
              
              if (catalog.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Opacity(opacity: 0.5, child: Icon(Icons.inventory_2_outlined, size: 80)),
                      const SizedBox(height: 16),
                      Text('Your catalog is empty', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Add items to help customers find you.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: OutlinedButton(
                          onPressed: _showAddDialog,
                          child: const Text('Add First Item'),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: catalog.length,
                itemBuilder: (context, index) {
                  final item = catalog[index] as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.label_important_outline, color: AppTheme.primary),
                      ),
                      title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: item['price'] != null && item['price'].toString().isNotEmpty
                        ? Text('₹${item['price']}', style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold))
                        : const Text('Price not set'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () async {
                           await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                             'serviceCatalog': FieldValue.arrayRemove([item])
                           });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
