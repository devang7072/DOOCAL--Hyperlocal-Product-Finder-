// lib/models/request_model.dart

enum RequestStatus {
  created,
  sent,
  responsesReceived,
  accepted,
  inProgress,
  completed,
  cancelled
}

class VendorResponse {
  final String vendorId;
  final String vendorName;
  final double price;
  final String eta;
  final double rating;
  final double distance;
  final String? message;
  final DateTime responseTime;

  VendorResponse({
    required this.vendorId,
    required this.vendorName,
    required this.price,
    required this.eta,
    required this.rating,
    required this.distance,
    this.message,
    required this.responseTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'price': price,
      'eta': eta,
      'rating': rating,
      'distance': distance,
      'message': message,
      'responseTime': responseTime.toIso8601String(),
    };
  }

  factory VendorResponse.fromMap(Map<String, dynamic> map) {
    return VendorResponse(
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      eta: map['eta'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      distance: (map['distance'] ?? 0.0).toDouble(),
      message: map['message'],
      responseTime: map['responseTime'] != null 
          ? DateTime.parse(map['responseTime']) 
          : DateTime.now(),
    );
  }
}

class RequestModel {
  final String id;
  final String customerId;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final RequestStatus status;
  final List<VendorResponse> responses;
  final String? acceptedVendorId;
  final DateTime createdAt;
  final List<String>? images;

  RequestModel({
    required this.id,
    required this.customerId,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.responses,
    this.acceptedVendorId,
    required this.createdAt,
    this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.index,
      'responses': responses.map((r) => r.toMap()).toList(),
      'acceptedVendorId': acceptedVendorId,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: RequestStatus.values[map['status'] ?? 0],
      responses: (map['responses'] as List? ?? [])
          .map((r) => VendorResponse.fromMap(r))
          .toList(),
      acceptedVendorId: map['acceptedVendorId'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      images: map['images'] != null ? List<String>.from(map['images']) : null,
    );
  }
}
