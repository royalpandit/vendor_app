import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String image;
  final int conversationId;
  final int receiverId;
  final int senderId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
    required this.receiverId,
    required this.senderId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  Timer? _refreshTimer;
  int? _authenticatedUserId; // The actual logged-in user ID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Step 1: Get the real User ID from storage to ensure "isMe" works
      final userData = await TokenStorage.getUserData();
      if (mounted) {
        setState(() {
          _authenticatedUserId = userData?.id;
        });
      }

      await _fetchMessages();

      // Refresh timer
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) _fetchMessages();
      });
    });
  }

  Future<void> _fetchMessages() async {
    if (widget.conversationId > 0) {
      await context.read<AuthProvider>().fetchConversationMessages(widget.conversationId);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.name,
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Conversation'),
                    content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final prov = context.read<AuthProvider>();
                          final success = await prov.deleteConversation(widget.conversationId);
                          if (success && mounted) {
                            Navigator.pop(context, true); // Return true to indicate deletion
                          }
                        },
                        child: const Text('Delete', style: TextStyle(color: Color(0xFFFF4678))),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Color(0xFFFF4678), size: 20),
                    SizedBox(width: 8),
                    Text('Delete Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
        shape: const Border(bottom: BorderSide(color: Color(0x2870737C), width: 0.5)),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.43, 0.05),
              end: Alignment(0.44, 0.26),
              colors: [const Color(0xFFFFE5E8), Colors.white],
            ),
          ),
          child: Column(
        children: [
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, prov, _) {
                final messages = prov.conversationMessages;

                if (prov.loading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4678)));
                }

                return ListView.builder(
                  reverse: false,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    final bool isMe =
                        msg.sender.id == (_authenticatedUserId ?? widget.senderId);

                    return _buildMessageBubble(msg.message ?? "", isMe, msg.id, msg.conversationId);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, int messageId, int conversationId) {
    return GestureDetector(
      onLongPress: isMe
          ? () => _showMessageOptions(messageId, conversationId)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Align(
          // Aligns YOUR messages to the RIGHT, others to the LEFT
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              // YOUR bubbles are PINK, others are GREY
              color: isMe ? const Color(0xFFFF4678) : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                fontFamily: 'Onest',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(int messageId, int conversationId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFFF4678)),
              title: const Text('Delete Message'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(messageId, conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int messageId, int conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMessage(messageId, conversationId);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF4678))),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(int messageId, int conversationId) async {
    final success = await context.read<AuthProvider>().deleteMessage(
      messageId: messageId,
      conversationId: conversationId,
    );

    if (success && mounted) {
      await _fetchMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted'), duration: Duration(seconds: 2)),
      );
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFDBE2EA)),
              ),
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                  hintText: 'Type in your message',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: Color(0xFFFF4678),
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final success = await context.read<AuthProvider>().sendMessage(
      senderId: _authenticatedUserId ?? widget.senderId,
      receiverId: widget.receiverId,
      messageText: text,
    );

    if (success) {
      _msgController.clear();
      _fetchMessages();
    }
  }
}