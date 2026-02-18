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
  final int senderId;
  final int receiverId;
  final String? message;
  final String? mediaPath;
  final String messageType; // e.g. "text"
  final String status; // e.g. "sent"
  final int isDeleted;
  final DateTime? readAt;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.mediaPath,
    required this.messageType,
    required this.status,
    required this.isDeleted,
    required this.readAt,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] ?? 0) as int,
      conversationId: (json['conversation_id'] ?? 0) as int,
      senderId: (json['sender_id'] ?? 0) as int,
      receiverId: (json['receiver_id'] ?? 0) as int,
      message: json['message']?.toString(),
      mediaPath: json['media_path']?.toString(),
      messageType: json['message_type']?.toString() ?? 'text',
      status: json['status']?.toString() ?? '',
      isDeleted: (json['is_deleted'] ?? 0) as int,
      readAt: _parseNullableDateTime(json['read_at']),
      createdAt: _parseNullableDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'media_path': mediaPath,
      'message_type': messageType,
      'status': status,
      'is_deleted': isDeleted,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    int? receiverId,
    String? message,
    String? mediaPath,
    String? messageType,
    String? status,
    int? isDeleted,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      mediaPath: mediaPath ?? this.mediaPath,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
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
      id: (json['id'] ?? 0) as int,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      email: json['email']?.toString(),
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

  ChatUser copyWith({
    int? id,
    String? name,
    String? image,
    String? email,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      email: email ?? this.email,
    );
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
