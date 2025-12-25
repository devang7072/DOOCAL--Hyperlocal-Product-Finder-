// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../models/request_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Vendor Operations
  Future<void> saveVendor(VendorModel vendor) async {
    await _db.collection('users').doc(vendor.uid).set(vendor.toMap(), SetOptions(merge: true));
  }

  Stream<List<VendorModel>> getNearbyVendors(double lat, double lng, double radiusKm) {
    return _db.collection('users')
        .where('role', isEqualTo: 'vendor')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorModel.fromMap(doc.data()))
            .toList());
  }

  // Request Operations
  Future<void> createRequest(RequestModel request) async {
    await _db.collection('requests').doc(request.id).set(request.toMap());
  }

  Stream<List<RequestModel>> getCustomerRequests(String customerId) {
    return _db.collection('requests')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<RequestModel>> getNearbyRequests(String category, double lat, double lng) {
    return _db.collection('requests')
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: RequestStatus.sent.index)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> respondToRequest(String requestId, VendorResponse response) async {
    await _db.collection('requests').doc(requestId).update({
      'responses': FieldValue.arrayUnion([response.toMap()]),
      'status': RequestStatus.responsesReceived.index,
    });
  }

  // Review Operations
  Future<void> submitReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).set(review.toMap());
    
    // Update vendor rating (simplified)
    final vendorDoc = await _db.collection('users').doc(review.vendorId).get();
    if (vendorDoc.exists) {
      final vendor = VendorModel.fromMap(vendorDoc.data()!);
      final newTotalReviews = vendor.totalReviews + 1;
      final newRating = ((vendor.rating * vendor.totalReviews) + review.rating) / newTotalReviews;
      
      await _db.collection('users').doc(review.vendorId).update({
        'rating': newRating,
        'totalReviews': newTotalReviews,
      });
    }
  }
}
