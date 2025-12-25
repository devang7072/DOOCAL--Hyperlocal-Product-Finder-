// lib/screens/customer/customer_home.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../routes.dart';
import 'vendor_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isMapView = false;
  List<Map<String, dynamic>> _nearbyVendors = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': Colors.blue},
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.red},
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.purple},
    {'name': 'Medicine', 'icon': Icons.medical_services, 'color': Colors.green},
    {'name': 'Services', 'icon': Icons.build, 'color': Colors.orange},
    {'name': 'Grocery', 'icon': Icons.shopping_basket, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
  }

  Future<void> _initLocationAndData() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
      _loadData();
    } catch (e) {
      debugPrint('Location error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    if (_currentPosition == null) return;
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .where('isOnline', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> vendors = [];
    Set<Marker> markers = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lat = data['latitude'];
      final lng = data['longitude'];

      if (lat != null && lng != null) {
        final dist = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, lat, lng) / 1000;
        
        if (dist <= 5.0) { // 5km radius
          data['distance'] = dist;
          data['id'] = doc.id;
          vendors.add(data);
          
          markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: data['shopName']),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VendorProfileScreen(vendorData: data))),
          ));
        }
      }
    }

    setState(() {
      _nearbyVendors = vendors;
      _markers = markers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          _isMapView ? _buildMapView() : _buildDiscoveryView(),
          _buildTopBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _isMapView = !_isMapView),
        backgroundColor: AppTheme.primary,
        icon: Icon(_isMapView ? Icons.list : Icons.map),
        label: Text(_isMapView ? 'List View' : 'Map View'),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.white.withOpacity(0.9), Colors.transparent]),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Location', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('Bengaluru, Karnataka', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.1), child: const Icon(Icons.person_outline, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 20),
            SearchBarWidget(
              hintText: 'Search for "Samosa", "Electrician"...',
              onChanged: (v) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 180, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Explore Categories'),
          const SizedBox(height: 16),
          _buildCategoryGrid(),
          const SizedBox(height: 32),
          _buildPromoBanner(),
          const SizedBox(height: 32),
          _buildSectionHeader('Best Shops Near You'),
          const SizedBox(height: 16),
          _nearbyVendors.isEmpty && !_isLoading 
            ? const Center(child: Text('No shops found nearby'))
            : _buildVendorHorizontalList(),
          const SizedBox(height: 32),
          _buildSectionHeader('Recent Requests'),
          const SizedBox(height: 16),
          _buildActiveRequestsCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('See All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cat['color'].withOpacity(0.1),
                  child: Icon(cat['icon'], color: cat['color']),
                ),
                const SizedBox(height: 8),
                Text(cat['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, bottom: -20, child: Icon(Icons.bolt, size: 150, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Need something FAST?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Broadcast your need to 50+ local shops.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.createRequest),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(120, 36)),
                  child: const Text('Start Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorHorizontalList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _nearbyVendors.length,
        itemBuilder: (ctx, i) {
          final vendor = _nearbyVendors[i];
          return Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VendorProfileScreen(vendorData: vendor))),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(vendor['imageUrl'] ?? 'https://via.placeholder.com/200', height: 100, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendor['shopName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                          Text(vendor['shopCategory'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              Text(' ${vendor['rating'] ?? '5.0'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text('${vendor['distance']?.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveRequestsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Samosa (2 items)', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('3 vendors responded nearby', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition != null ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude) : const LatLng(12.9716, 77.5946),
        zoom: 15,
      ),
      onMapCreated: (c) => _controller.complete(c),
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      padding: const EdgeInsets.only(top: 180),
    );
  }
}
