// lib/models/transaction_model.dart

enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded
}

class TransactionModel {
  final String id;
  final String requestId;
  final String customerId;
  final String vendorId;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String paymentMethod;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.vendorId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'customerId': customerId,
      'vendorId': vendorId,
      'amount': amount,
      'currency': currency,
      'status': status.index,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      customerId: map['customerId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'INR',
      status: TransactionStatus.values[map['status'] ?? 0],
      paymentMethod: map['paymentMethod'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
