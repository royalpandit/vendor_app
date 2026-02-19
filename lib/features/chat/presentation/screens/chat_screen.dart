import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/utils/skeleton_loader.dart';
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
            Text(
              widget.name,
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Color(0x2870737C), width: 0.5)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, prov, _) {
                final messages = prov.conversationMessages;

                if (prov.loading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4678)));
                }

                return ListView.builder(
                  reverse: false, // Set to true if your API returns newest first
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    final bool isMe =
                        msg.sender.id == (_authenticatedUserId ?? widget.senderId);

                    return _buildMessageBubble(msg.message ?? "", isMe);
                    // final msg = messages[index].lastMessage;
                    //
                    // // FIX: Robust isMe check.
                    // // Compare against the logged-in ID, or the senderId passed in widget.
                    // final bool isMe = msg?.senderId == (_authenticatedUserId ?? widget.senderId);
                    //
                    // return _buildMessageBubble(msg?.message ?? "", isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Padding(
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
    );
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