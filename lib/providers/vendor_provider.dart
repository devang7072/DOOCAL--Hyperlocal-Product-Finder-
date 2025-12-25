// lib/providers/vendor_provider.dart
import 'package:flutter/material.dart';
import '../models/vendor_model.dart';
import '../services/firestore_service.dart';

class VendorProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  VendorModel? _currentVendor;
  List<VendorModel> _nearbyVendors = [];
  bool _isLoading = false;

  VendorModel? get currentVendor => _currentVendor;
  List<VendorModel> get nearbyVendors => _nearbyVendors;
  bool get isLoading => _isLoading;

  void fetchNearbyVendors(double lat, double lng) {
    _isLoading = true;
    _firestoreService.getNearbyVendors(lat, lng, 5.0).listen((vendors) {
      _nearbyVendors = vendors;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateVendorProfile(VendorModel vendor) async {
    await _firestoreService.saveVendor(vendor);
    _currentVendor = vendor;
    notifyListeners();
  }

  void setVendor(VendorModel vendor) {
    _currentVendor = vendor;
    notifyListeners();
  }
}
