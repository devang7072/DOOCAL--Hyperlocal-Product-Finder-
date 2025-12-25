// lib/models/review_model.dart

class ReviewModel {
  final String id;
  final String requestId;
  final String reviewerId;
  final String reviewerName;
  final String vendorId;
  final double rating;
  final String comment;
  final List<String>? photos;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.requestId,
    required this.reviewerId,
    required this.reviewerName,
    required this.vendorId,
    required this.rating,
    required this.comment,
    this.photos,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'vendorId': vendorId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      photos: map['photos'] != null ? List<String>.from(map['photos']) : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
