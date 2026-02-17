class SendMessageRequest {
  final int senderId;
  final int receiverId;
  final String message;

  SendMessageRequest({
    required this.senderId,
    required this.receiverId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
    };
  }
}
