import 'package:chat/chat.dart';
import 'package:core/core.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatClient {
  late final io.Socket socket = io.io(uri, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  final String uri;
  final Function(List<ChatMessage>)? onAllMessages;
  final Function(ChatMessage)? onNewMessage;
  final Function()? onConnected;
  final Function()? onDisconnected;
  final Function(dynamic)? onError;

  ChatClient({
    required this.uri,
    required this.onAllMessages,
    required this.onNewMessage,
    required this.onConnected,
    required this.onDisconnected,
    required this.onError,
  });

  void connect() {
    socket.connect();

    socket.onConnect((_) {
      printLog('[ChatClient] Connected to chat server: $uri');
      onConnected?.call();
    });

    socket.on('allMessages', (data) {
      printLog('[ChatClient] Received all messages: $data');
      if (data is List) {
        final messages = data
            .map((json) => ChatMessage.fromJson(json))
            .toList();
        onAllMessages?.call(messages);
      }
    });

    socket.on('newMessage', (data) {
      printLog('[ChatClient] Received new message: $data');
      if (data is Map<String, dynamic>) {
        final message = ChatMessage.fromJson(data);
        onNewMessage?.call(message);
      }
    });

    socket.onDisconnect((_) {
      printLog('[ChatClient] Disconnected from chat server');
      onDisconnected?.call();
    });

    socket.onError((data) {
      printLog('[ChatClient] Socket Error: $data');
      onError?.call(data);
    });
  }

  void sendMessage({
    required String senderName,
    required Animals avatarName,
    required AvatarBackgroundColor avatarBackgroundColor,
    required String message,
  }) {
    if (!socket.connected) {
      printLog('[ChatClient] Socket not connected. Cannot send message.');
      return;
    }

    final chatMessage = ChatMessage(
      senderName: senderName,
      avatarName: avatarName,
      avatarBackgroundColor: avatarBackgroundColor,
      message: message,
    );

    printLog('[ChatClient] Sending message: ${chatMessage.toJson()}');
    socket.emit('sendMessage', chatMessage.toJson());
  }

  void disconnect() {
    if (!socket.connected) {
      return;
    }
    socket.disconnect();
  }
}
