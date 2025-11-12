import 'package:core/models/animals.dart'; // Import the Animals enum from core

// Enums mirroring your server's AvatarBackgroundColor
enum AvatarBackgroundColor {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
  pink,
}

// ChatMessage model to represent a message
class ChatMessage {
  final String senderName;
  final Animals avatarName; // Using Animals enum from core
  final AvatarBackgroundColor avatarBackgroundColor;
  final String message;
  final DateTime? timestamp; // Nullable as it might not be present on creation

  ChatMessage({
    required this.senderName,
    required this.avatarName,
    required this.avatarBackgroundColor,
    required this.message,
    this.timestamp,
  });

  // Factory constructor to create a ChatMessage from a JSON map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: json['senderName'],
      avatarName: Animals.fromName(json['avatarName']), // Use fromName constructor
      avatarBackgroundColor: AvatarBackgroundColor.values.firstWhere(
          (e) => e.toString().split('.').last == json['avatarBackgroundColor']),
      message: json['message'],
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  // Method to convert a ChatMessage to a JSON map for sending
  Map<String, dynamic> toJson() {
    return {
      'senderName': senderName,
      'avatarName': avatarName.name, // Use .name for enum value
      'avatarBackgroundColor': avatarBackgroundColor.toString().split('.').last,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}