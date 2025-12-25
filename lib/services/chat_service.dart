// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }
}

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String requestId) {
    return _db.collection('requests').doc(requestId).collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String requestId, MessageModel message) async {
    await _db.collection('requests').doc(requestId).collection('messages')
        .add(message.toMap());
  }
}
