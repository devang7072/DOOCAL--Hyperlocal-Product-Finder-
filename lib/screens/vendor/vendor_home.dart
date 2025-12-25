// lib/screens/vendor/vendor_home.dart - ENHANCED VERSION
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../services/firebase_auth_service.dart';
import '../../services/notification_service.dart';
import '../../core/animations.dart';
import '../../routes.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> with TickerProviderStateMixin {
  double? _vendorLat;
  double? _vendorLng;
  Map<String, dynamic>? _vendorProfileData;
  bool _isLoadingProfile = true;
  StreamSubscription? _requestSubscription;
  final Set<String> _knownRequestIds = {};
  String _selectedFilter = 'All';
  int _todayRequests = 0;
  int _acceptedToday = 0;
  late AnimationController _statsAnimationController;

  @override
  void initState() {
    super.initState();
    _statsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    NotificationService.initialize();
    _fetchVendorProfile();
    _calculateTodayStats();
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    _statsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendorProfile() async {
    final user = FirebaseAuthService().currentUser();
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
           setState(() {
             _vendorLat = data['latitude'];
             _vendorLng = data['longitude'];
             _vendorProfileData = data;
             _isLoadingProfile = false;
           });
           _startListeningForNewRequests();
           _statsAnimationController.forward();
        }
      }
    }
  }

  void _startListeningForNewRequests() {
    if (_vendorLat == null || _vendorLng == null) return;

    final Query requestsQuery = FirebaseFirestore.instance
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .limit(20);

    _requestSubscription = requestsQuery.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final requestId = change.doc.id;

          if (_knownRequestIds.contains(requestId)) continue;
          _knownRequestIds.add(requestId);
          
          double? reqLat = data['latitude'];
          double? reqLng = data['longitude'];
          if (reqLat != null && reqLng != null) {
             double dist = Geolocator.distanceBetween(_vendorLat!, _vendorLng!, reqLat, reqLng);
             if (dist <= 2000) {
                 NotificationService.showNotification(
                   id: requestId.hashCode,
                   title: "New Request Nearby!", 
                   body: "Someone wants ${data['item']}",
                 );
             }
          }
        }
      }
    });
  }

  Future<void> _calculateTodayStats() async {
    final user = FirebaseAuthService().currentUser();
    if (user == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('vendorIds', arrayContains: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      int accepted = 0;
      for (var doc in requestsSnapshot.docs) {
        final responses = doc.data()['responses'] as List<dynamic>? ?? [];
        for (var response in responses) {
          if (response['vendorId'] == user.uid && response['status'] == 'accepted') {
            accepted++;
          }
        }
      }

      if (mounted) {
        setState(() {
          _todayRequests = requestsSnapshot.docs.length;
          _acceptedToday = accepted;
        });
      }
    } catch (e) {
      debugPrint('Error calculating stats: $e');
    }
  }

  Future<void> _respondToRequest(
      BuildContext context, String requestId, String status) async {
    final user = FirebaseAuthService().currentUser();
    if (user == null) return;

    try {
      final response = {
        'vendorId': user.uid,
        'status': status, 
        'respondedAt': Timestamp.now(),
        'shopName': _vendorProfileData?['shopName'] ?? 'Unknown Shop',
        'imageUrl': _vendorProfileData?['imageUrl'],
        'address': _vendorProfileData?['address'],
        'bestProduct': _vendorProfileData?['bestProduct'],
        'latitude': _vendorLat,
        'longitude': _vendorLng,
      };

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'responses': FieldValue.arrayUnion([response]),
        'vendorIds': FieldValue.arrayUnion([user.uid]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  status == 'accepted' ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text('Response sent: ${status == 'accepted' ? 'Accepted' : 'Rejected'}'),
              ],
            ),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _calculateTodayStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              const Text('Loading your dashboard...'),
            ],
          ),
        ),
      );
    }

    if (_vendorLat == null || _vendorLng == null) {
      return const Scaffold(
        body: Center(child: Text("Location not found. Please complete setup.")),
      );
    }

    final Query requestsQuery = FirebaseFirestore.instance
        .collection('requests')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Vendor Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_vendorProfileData?['imageUrl'] != null)
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(_vendorProfileData!['imageUrl']),
                              )
                            else
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: const Icon(Icons.store, color: Colors.white, size: 30),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _vendorProfileData?['shopName'] ?? 'My Shop',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _vendorProfileData?['shopCategory'] ?? 'General',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              // Online / Offline Toggle (Zomato Style)
              Row(
                children: [
                   Text(
                    _vendorProfileData?['isOnline'] == false ? 'OFFLINE' : 'ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _vendorProfileData?['isOnline'] == false ? Colors.white54 : Colors.white,
                    ),
                  ),
                  Switch(
                    value: _vendorProfileData?['isOnline'] ?? true,
                    activeColor: Colors.greenAccent,
                    onChanged: (v) async {
                      final user = FirebaseAuthService().currentUser();
                      if (user != null) {
                        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'isOnline': v});
                        _fetchVendorProfile();
                      }
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Shop Settings',
                onPressed: () {
                   Navigator.pushNamed(context, Routes.vendorSetup);
                },
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Switch to Customer Mode',
                onPressed: () {
                   Navigator.pushNamedAndRemoveUntil(context, Routes.roleSelection, (route) => false);
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Accepted Jobs',
                onPressed: () {
                   Navigator.pushNamed(context, Routes.vendorHistory);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                   await FirebaseAuthService().signOut();
                   if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, Routes.splash, (route) => false);
                   }
                },
              ),
            ],
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FadeInSlide(
                delay: 0.1,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Today\'s Requests',
                        _todayRequests.toString(),
                        Icons.inbox,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Accepted',
                        _acceptedToday.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Rate',
                        _todayRequests > 0 
                            ? '${((_acceptedToday / _todayRequests) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Food'),
                    _buildFilterChip('Electronics'),
                    _buildFilterChip('Clothing'),
                    _buildFilterChip('Medicine'),
                    _buildFilterChip('Services'),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Requests List
          StreamBuilder<QuerySnapshot>(
            stream: requestsQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final allDocs = snapshot.data!.docs;
              final nearbyDocs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final double? reqLat = data['latitude'];
                final double? reqLng = data['longitude'];

                if (reqLat == null || reqLng == null) return false;

                final double distanceInMeters = Geolocator.distanceBetween(
                  _vendorLat!,
                  _vendorLng!,
                  reqLat,
                  reqLng,
                );

                return distanceInMeters <= 2000;
              }).toList();

              if (nearbyDocs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.radar, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Scanning for nearby requests...',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Only requests within 2km will appear here.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = nearbyDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final requestId = doc.id;
                    final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
                    final timeStr = timestamp != null
                        ? DateFormat('hh:mm a').format(timestamp)
                        : 'Just now';

                    final double distMeters = Geolocator.distanceBetween(
                        _vendorLat!, _vendorLng!, data['latitude'], data['longitude']);
                    
                    String distDisplay = distMeters < 1000 
                      ? '${distMeters.round()} m' 
                      : '${(distMeters / 1000).toStringAsFixed(1)} km';

                    return FadeInSlide(
                      delay: index * 0.05,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(data['category'] ?? 'General'),
                                    backgroundColor:
                                        Theme.of(context).primaryColor.withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                       Row(
                                         children: [
                                           const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                           const SizedBox(width: 4),
                                           Text(distDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                                         ],
                                       ),
                                       Text(
                                        timeStr,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                data['item'] ?? 'Unknown Item',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (data['description'] != null &&
                                  data['description'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  data['description'],
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text('Do you have this?', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _respondToRequest(context, requestId, 'rejected'),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('No'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _respondToRequest(context, requestId, 'accepted'),
                                      icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                      label: const Text('Yes, I have it', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: nearbyDocs.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _statsAnimationController, curve: Curves.easeOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() => _selectedFilter = label);
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
