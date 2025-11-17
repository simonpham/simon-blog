import 'package:core/core.dart';

class ChatMessage {
  final String senderName;
  final Animals avatarName;
  final BackgroundColorType avatarBackgroundColor;
  final String message;
  final DateTime? timestamp;

  ChatMessage({
    required this.senderName,
    required this.avatarName,
    required this.avatarBackgroundColor,
    required this.message,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: json['senderName'],
      avatarName: Animals.fromName(
        json['avatarName'],
      ),
      avatarBackgroundColor: BackgroundColorType.fromString(
        json['avatarBackgroundColor'],
      ),
      message: json['message'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderName': senderName,
      'avatarName': avatarName.name,
      'avatarBackgroundColor': avatarBackgroundColor.name,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
