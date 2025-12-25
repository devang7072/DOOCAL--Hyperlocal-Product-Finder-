// lib/services/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating({
    required String vendorId,
    required String customerId,
    required double stars,
  }) async {
    final vendorRef = _firestore.collection('users').doc(vendorId);
    final ratingRef = vendorRef.collection('ratings').doc(); // Auto-ID

    return _firestore.runTransaction((transaction) async {
      final vendorDoc = await transaction.get(vendorRef);

      if (!vendorDoc.exists) {
        throw Exception("Vendor does not exist!");
      }

      final data = vendorDoc.data()!;
      final double currentTotal = (data['ratingTotal'] ?? 0.0) as double;
      final int currentCount = (data['ratingCount'] ?? 0) as int;

      final newTotal = currentTotal + stars;
      final newCount = currentCount + 1;
      final newAvg = newTotal / newCount;

      // Update Vendor Stats
      transaction.update(vendorRef, {
        'ratingTotal': newTotal,
        'ratingCount': newCount,
        'ratingAvg': newAvg,
      });

      // Add Rating Record
      transaction.set(ratingRef, {
        'reviewerId': customerId,
        'stars': stars,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
