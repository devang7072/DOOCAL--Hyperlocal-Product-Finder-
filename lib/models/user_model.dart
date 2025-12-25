// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String phoneNumber;
  final String role; // 'customer' or 'vendor'
  final String? name;
  final String? shopName; // Only for vendors
  final String? shopCategory; // Only for vendors
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.role,
    this.name,
    this.shopName,
    this.shopCategory,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'role': role,
      'name': name,
      'shopName': shopName,
      'shopCategory': shopCategory,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'customer',
      name: map['name'],
      shopName: map['shopName'],
      shopCategory: map['shopCategory'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
