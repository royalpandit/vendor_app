// lib/features/chat/data/models/conversation_chat_model.dart

class ConversationItem {
  final int id;
  final ChatMessage? lastMessage;
  final ChatUser sender;
  final ChatUser receiver;

  ConversationItem({
    required this.id,
    required this.lastMessage,
    required this.sender,
    required this.receiver,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      id: (json['id'] ?? 0) as int,
      lastMessage: json['last_message'] == null
          ? null
          : ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>),
      sender: ChatUser.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: ChatUser.fromJson(json['receiver'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_message': lastMessage?.toJson(),
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
    };
  }

  ConversationItem copyWith({
    int? id,
    ChatMessage? lastMessage,
    ChatUser? sender,
    ChatUser? receiver,
  }) {
    return ConversationItem(
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
    );
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final ChatUser sender;
  final ChatUser receiver;
  final String? message;
  final String? mediaPath;
  final String messageType;
  final String status;
  final DateTime? readAt;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.mediaPath,
    required this.messageType,
    required this.status,
    required this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      sender: ChatUser.fromJson(json['sender'] ?? {}),
      receiver: ChatUser.fromJson(json['receiver'] ?? {}),
      message: json['message'],
      mediaPath: json['media_path'],
      messageType: json['message_type'] ?? 'text',
      status: json['status'] ?? '',
      readAt: _parseNullableDateTime(json['read_at']),
      createdAt: _parseNullableDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'message': message,
      'media_path': mediaPath,
      'message_type': messageType,
      'status': status,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}


class ChatUser {
  final int id;
  final String name;
  final String image;
  final String? email;

  ChatUser({
    required this.id,
    required this.name,
    required this.image,
    this.email,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'email': email,
    };
  }
}


DateTime? _parseNullableDateTime(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}
