// lib/models/vendor_model.dart

class VendorModel {
  final String uid;
  final String shopName;
  final String shopCategory;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final bool isVerified;
  final double rating;
  final int totalReviews;
  final String? profileImageUrl;
  final Map<String, dynamic>? workingHours;
  final List<String>? serviceCatalog;
  final bool isOnline;
  final int dailyLeads;
  final double conversionRate;
  
  // Advanced Onboarding Fields
  final String? gstNumber;
  final String? panNumber;
  final double serviceRadius; // in km
  final List<String> galleryImages;
  final Map<String, dynamic>? bankDetails;
  final bool isSetupComplete;

  VendorModel({
    required this.uid,
    required this.shopName,
    required this.shopCategory,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.profileImageUrl,
    this.workingHours,
    this.serviceCatalog,
    this.isOnline = true,
    this.dailyLeads = 0,
    this.conversionRate = 0.0,
    this.gstNumber,
    this.panNumber,
    this.serviceRadius = 5.0,
    this.galleryImages = const [],
    this.bankDetails,
    this.isSetupComplete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'shopCategory': shopCategory,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'rating': rating,
      'totalReviews': totalReviews,
      'profileImageUrl': profileImageUrl,
      'workingHours': workingHours,
      'serviceCatalog': serviceCatalog,
      'isOnline': isOnline,
      'dailyLeads': dailyLeads,
      'conversionRate': conversionRate,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'serviceRadius': serviceRadius,
      'galleryImages': galleryImages,
      'bankDetails': bankDetails,
      'isSetupComplete': isSetupComplete,
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      uid: map['uid'] ?? '',
      shopName: map['shopName'] ?? '',
      shopCategory: map['shopCategory'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      phoneNumber: map['phoneNumber'] ?? '',
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      profileImageUrl: map['profileImageUrl'],
      workingHours: map['workingHours'],
      serviceCatalog: map['serviceCatalog'] != null ? List<String>.from(map['serviceCatalog']) : null,
      isOnline: map['isOnline'] ?? true,
      dailyLeads: map['dailyLeads'] ?? 0,
      conversionRate: (map['conversionRate'] ?? 0.0).toDouble(),
      gstNumber: map['gstNumber'],
      panNumber: map['panNumber'],
      serviceRadius: (map['serviceRadius'] ?? 5.0).toDouble(),
      galleryImages: map['galleryImages'] != null ? List<String>.from(map['galleryImages']) : [],
      bankDetails: map['bankDetails'],
      isSetupComplete: map['isSetupComplete'] ?? false,
    );
  }
}
