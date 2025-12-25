// lib/models/favorite_vendor.dart
class FavoriteVendor {
  final String vendorId;
  final String shopName;
  final String? imageUrl;
  final String category;
  final double latitude;
  final double longitude;
  final DateTime addedAt;

  FavoriteVendor({
    required this.vendorId,
    required this.shopName,
    this.imageUrl,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'shopName': shopName,
      'imageUrl': imageUrl,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteVendor.fromMap(Map<String, dynamic> map) {
    return FavoriteVendor(
      vendorId: map['vendorId'] ?? '',
      shopName: map['shopName'] ?? '',
      imageUrl: map['imageUrl'],
      category: map['category'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      addedAt: DateTime.parse(map['addedAt']),
    );
  }
}
