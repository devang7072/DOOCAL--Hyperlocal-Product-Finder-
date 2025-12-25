// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void loadMessages(String requestId) {
    _isLoading = true;
    _chatService.getMessages(requestId).listen((msgs) {
      _messages = msgs;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String requestId, String senderId, String text, {String? imageUrl}) async {
    final message = MessageModel(
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
    await _chatService.sendMessage(requestId, message);
  }
}
