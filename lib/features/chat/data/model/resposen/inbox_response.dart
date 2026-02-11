class InboxResponse {
  final int id;
  final LastMessage lastMessage;
  final Sender sender;
  final Receiver receiver;

  InboxResponse({
    required this.id,
    required this.lastMessage,
    required this.sender,
    required this.receiver,
  });

  factory InboxResponse.fromJson(Map<String, dynamic> json) {
    return InboxResponse(
      id: json['id'],
      lastMessage: LastMessage.fromJson(json['last_message']),
      sender: Sender.fromJson(json['sender']),
      receiver: Receiver.fromJson(json['receiver']),
    );
  }
}

class LastMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final int receiverId;
  final String message;
  final String? mediaPath;
  final String messageType;
  final String status;
  final bool isDeleted;
  final String? readAt;

  LastMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.mediaPath,
    required this.messageType,
    required this.status,
    required this.isDeleted,
    this.readAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      mediaPath: json['media_path'],
      messageType: json['message_type'],
      status: json['status'],
      isDeleted: json['is_deleted'] == 1,
      readAt: json['read_at'],
    );
  }
}

class Sender {
  final int id;
  final String name;
  final String image;
  final String? email;

  Sender({
    required this.id,
    required this.name,
    required this.image,
    this.email,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      email: json['email'],
    );
  }
}

class Receiver {
  final int id;
  final String name;
  final String image;
  final String? email;

  Receiver({
    required this.id,
    required this.name,
    required this.image,
    this.email,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      email: json['email'],
    );
  }
}


