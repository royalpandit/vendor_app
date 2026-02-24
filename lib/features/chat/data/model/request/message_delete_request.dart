class MessageDeleteRequest {
  final int conversationId;
  final int messageId;

  MessageDeleteRequest({
    required this.conversationId,
    required this.messageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'message_id': messageId,
    };
  }
}
