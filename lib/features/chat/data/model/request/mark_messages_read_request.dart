class MarkMessagesReadRequest {
  final int conversationId;
  final int receiverId;

  MarkMessagesReadRequest({
    required this.conversationId,
    required this.receiverId,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'receiver_id': receiverId,
    };
  }
}
