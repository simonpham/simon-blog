import 'dart:math';

import 'package:chat/chat.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  ChatClient? _chatClient;

  // TODO: handle random animals creation.
  Animals get animal => Animals.fox;
  BackgroundColorType get backgroundColor => BackgroundColorType.yellow;

  // random 3 number as String. min 100
  // String randomInt = '${Random().nextInt(900) + 100}';
  String randomInt = '233';

  String get senderName => '${backgroundColor.name}_${animal.name}$randomInt';

  List<ChatMessage> _chatMessages = [];

  ChatViewModel();

  List<ChatMessage> get chatMessages => _chatMessages;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void sendMessage(String message) {
    _chatClient?.sendMessage(
      senderName: senderName,
      message: message,
      avatarName: animal,
      avatarBackgroundColor: backgroundColor,
    );
  }

  void init() {
    final chatClient = ChatClient(
      uri: 'https://nowis-chat.onrender.com',
      onAllMessages: (messages) {
        _chatMessages = messages;
        notifyListeners();
      },
      onNewMessage: (message) {
        _chatMessages.insert(0, message);
        notifyListeners();
      },
      onConnected: () {
        _isConnected = true;
        notifyListeners();
      },
      onDisconnected: () {
        _isConnected = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
    chatClient.connect();
    _chatClient = chatClient;
  }

  @override
  void dispose() {
    _chatClient?.disconnect();
    _chatClient?.dispose();
    super.dispose();
  }
}
