import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firebase_auth_service.dart';
import '../../widgets/widgets.dart';
import '../../core/animations.dart';

class CreateRequestScreen extends StatefulWidget {
  final String? initialItem;
  final String? initialCategory;

  const CreateRequestScreen({super.key, this.initialItem, this.initialCategory});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemController;
  late TextEditingController _descController;
  late String _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.initialItem);
    _descController = TextEditingController();
    _selectedCategory = widget.initialCategory ?? 'Food';
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Clothing', 'icon': Icons.checkroom},
    {'name': 'Medicine', 'icon': Icons.medical_services},
    {'name': 'Services', 'icon': Icons.build},
    {'name': 'Hardware', 'icon': Icons.hardware},
    {'name': 'General', 'icon': Icons.apps},
  ];

  @override
  void dispose() {
    _itemController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuthService().currentUser();
      if (user == null) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await FirebaseFirestore.instance.collection('requests').add({
        'userId': user.uid,
        'item': _itemController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'status': 'active',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createdAt': FieldValue.serverTimestamp(),
        'responses': [],
      });

      if (mounted) {
        await SuccessAnimation.show(context, message: 'Broadcast Successful!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isSubmitting,
      message: 'Broadcasting to nearby vendors...',
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Create New Discovery'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FadeInSlide(
                  child: Text('What are you looking for?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const FadeInSlide(
                  delay: 0.1,
                  child: Text('Describe the item or service. Vendors within 5km will be notified instantly.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
                const SizedBox(height: 32),
                
                FadeInSlide(
                  delay: 0.2,
                  child: TextFormField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'e.g. Vintage leather boots',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please specify what you need' : null,
                  ),
                ),
                const SizedBox(height: 24),
                
                const FadeInSlide(delay: 0.3, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                const SizedBox(height: 12),
                FadeInSlide(
                  delay: 0.3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: _categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CategoryChip(
                          label: cat['name'],
                          icon: cat['icon'],
                          isSelected: _selectedCategory == cat['name'],
                          onTap: () => setState(() => _selectedCategory = cat['name']),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                FadeInSlide(
                  delay: 0.4,
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Additional Details (Optional)',
                      alignLabelWithHint: true,
                      hintText: 'Color, budget, brand preferences or urgency...',
                      prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.notes_rounded)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                FadeInSlide(
                  delay: 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.radar_rounded, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Your request will be broadcasted to verified local vendors.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              text: 'Broadcast Request',
              icon: Icons.send_rounded,
              onPressed: _submitRequest,
            ),
          ),
        ),
      ),
    );
  }
}
