class ConversationDeleteRequest {
  final int conversationId;

  ConversationDeleteRequest({required this.conversationId});

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
    };
  }
}
