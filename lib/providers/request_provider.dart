// lib/providers/request_provider.dart
import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';

class RequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<RequestModel> _customerRequests = [];
  bool _isLoading = false;

  List<RequestModel> get customerRequests => _customerRequests;
  bool get isLoading => _isLoading;

  void fetchCustomerRequests(String customerId) {
    _isLoading = true;
    _firestoreService.getCustomerRequests(customerId).listen((requests) {
      _customerRequests = requests;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> broadcastRequest(RequestModel request) async {
    await _firestoreService.createRequest(request);
  }

  Future<void> acceptVendorResponse(String requestId, String vendorId) async {
    // Logic to update request status and set acceptedVendorId
    // This would typically involve a firestore update
  }
}
