// lib/screens/vendor/vendor_setup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../services/firebase_auth_service.dart';
import '../../routes.dart';
import '../../widgets/widgets.dart';
import '../../core/themes/app_theme.dart';

class VendorSetupScreen extends StatefulWidget {
  const VendorSetupScreen({super.key});

  @override
  State<VendorSetupScreen> createState() => _VendorSetupScreenState();
}

class _VendorSetupScreenState extends State<VendorSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1: Identity
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';

  // Step 2: Location
  final TextEditingController _manualAddressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  double _serviceRadius = 5.0; // km
  Position? _currentPosition;

  // Step 3: Timing & Contact
  final TextEditingController _phoneController = TextEditingController();
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 21, minute: 0);

  // Step 4: Media
  File? _profileImage;
  List<File> _galleryImages = [];
  final ImagePicker _picker = ImagePicker();

  // Step 5: Legal & Banking
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();

  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Electronics', 'icon': Icons.electrical_services},
    {'name': 'Clothing', 'icon': Icons.checkroom},
    {'name': 'Medicine', 'icon': Icons.medical_services},
    {'name': 'Services', 'icon': Icons.handyman},
    {'name': 'Hardware', 'icon': Icons.construction},
    {'name': 'Grocery', 'icon': Icons.local_grocery_store},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _manualAddressController.dispose();
    _landmarkController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _accountNoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuthService().currentUser();
    if (user == null) return;
    _phoneController.text = user.phoneNumber ?? '';

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _shopNameController.text = data['shopName'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _manualAddressController.text = data['address'] ?? '';
        _landmarkController.text = data['landmark'] ?? '';
        _selectedCategory = data['shopCategory'] ?? 'Food';
        _serviceRadius = (data['serviceRadius'] ?? 5.0).toDouble();
        _gstController.text = data['gstNumber'] ?? '';
        _panController.text = data['panNumber'] ?? '';
        
        if (data['latitude'] != null && data['longitude'] != null) {
          _currentPosition = Position(
            latitude: data['latitude'],
            longitude: data['longitude'],
            timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
          );
        }
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _profileImage = File(file.path));
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 70);
    if (files.isNotEmpty) {
      setState(() => _galleryImages.addAll(files.map((e) => File(e.path))));
    }
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      debugPrint('Location Error: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_profileImage == null && _shopNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete basic info')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuthService().currentUser();
      if (user == null) return;

      String? profileUrl;
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance.ref().child('vendors/${user.uid}/profile.jpg');
        await ref.putFile(_profileImage!);
        profileUrl = await ref.getDownloadURL();
      }

      List<String> galleryUrls = [];
      for (int i = 0; i < _galleryImages.length; i++) {
        final ref = FirebaseStorage.instance.ref().child('vendors/${user.uid}/gallery_$i.jpg');
        await ref.putFile(_galleryImages[i]);
        galleryUrls.add(await ref.getDownloadURL());
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'shopName': _shopNameController.text,
        'description': _descriptionController.text,
        'shopCategory': _selectedCategory,
        'address': _manualAddressController.text,
        'landmark': _landmarkController.text,
        'serviceRadius': _serviceRadius,
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'phoneNumber': _phoneController.text,
        'openingTime': '${_openTime.hour}:${_openTime.minute}',
        'closingTime': '${_closeTime.hour}:${_closeTime.minute}',
        'imageUrl': profileUrl,
        'galleryImages': galleryUrls,
        'gstNumber': _gstController.text,
        'panNumber': _panController.text,
        'isSetupComplete': true,
        'role': 'vendor',
        'isVerified': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        await SuccessAnimation.show(context, message: 'Welcome to DOOCAL Business!');
        Navigator.pushNamedAndRemoveUntil(context, Routes.vendorHome, (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isSubmitting,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   _buildStepIdentity(),
                   _buildStepLocation(),
                   _buildStepTiming(),
                   _buildStepMedia(),
                   _buildStepFinancial(),
                ],
              ),
            ),
            _buildNavigationRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Partner Onboarding', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              Text('Step ${_currentStep + 1} of $_totalSteps', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIdentity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('What identifies your business?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _shopNameController,
            decoration: const InputDecoration(labelText: 'Store Name', prefixIcon: Icon(Icons.storefront)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Short Description', prefixIcon: Icon(Icons.description_outlined)),
          ),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _categories.map((c) => ChoiceChip(
              label: Text(c['name']),
              selected: _selectedCategory == c['name'],
              onSelected: (s) => setState(() => _selectedCategory = c['name']),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLocation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Presence', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('Where can customers find you?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _getLocation,
            icon: Icon(_currentPosition != null ? Icons.check_circle : Icons.gps_fixed),
            label: Text(_currentPosition != null ? 'Location Captured' : 'Get Current Location'),
            style: ElevatedButton.styleFrom(backgroundColor: _currentPosition != null ? Colors.green : AppTheme.primary),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _manualAddressController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Detailed Address', prefixIcon: Icon(Icons.location_on)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _landmarkController,
            decoration: const InputDecoration(labelText: 'Nearby Landmark', prefixIcon: Icon(Icons.turned_in_not)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Service Radius', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${_serviceRadius.round()} km', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _serviceRadius,
            min: 1, max: 20,
            onChanged: (v) => setState(() => _serviceRadius = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTiming() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Operations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('When do you serve?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ListTile(
            title: const Text('Opening Time'),
            subtitle: Text(_openTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _openTime);
              if (t != null) setState(() => _openTime = t);
            },
          ),
          ListTile(
            title: const Text('Closing Time'),
            subtitle: Text(_closeTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _closeTime);
              if (t != null) setState(() => _closeTime = t);
            },
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Business Phone', prefixIcon: Icon(Icons.phone)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepMedia() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visuals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('Add some life to your shop profile', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const Text('Profile / Cover Photo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
              ),
              child: _profileImage == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 32),
          const Text('Shop Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickGalleryImages,
            child: Container(
              height: 100, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Add Store Photos', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_galleryImages.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _galleryImages.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_galleryImages[i], width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepFinancial() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Legal & Trust', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('Help us verify your business', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _gstController,
            decoration: const InputDecoration(labelText: 'GST Number (Optional)', prefixIcon: Icon(Icons.assignment)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _panController,
            decoration: const InputDecoration(labelText: 'PAN Number', prefixIcon: Icon(Icons.credit_card)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _accountNoController,
            decoration: const InputDecoration(labelText: 'Settlement Account No.', prefixIcon: Icon(Icons.account_balance)),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(child: Text('Verification usually takes 24-48 hours after submission.', style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevPage,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == _totalSteps - 1 ? _saveProfile : _nextPage,
              child: Text(_currentStep == _totalSteps - 1 ? 'Submit Profile' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
