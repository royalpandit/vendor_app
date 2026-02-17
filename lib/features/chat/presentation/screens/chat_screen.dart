import 'package:flutter/material.dart';


 import 'package:vendor_app/core/utils/app_colors.dart';
 import 'package:provider/provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/chat/data/model/resposen/conversation_chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String image;
  final int conversationId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // API call
    Future.microtask(() async {
      final prov = context.read<AuthProvider>();
      await prov.fetchConversationMessages(widget.conversationId);

      // DEBUG (optional)
      // debugPrint('items: ${prov.conversationMessages.length}');
      // if (prov.conversationMessages.isNotEmpty) {
      //   debugPrint('first lastMessage: ${prov.conversationMessages.first.lastMessage?.message}');
      // }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  ImageProvider _avatarProvider(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/images/placeholder_user.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header (same design)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: _avatarProvider(widget.image),
                  radius: 30,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // name already in AppBar title—yahan optional dubara
                    // Text(...),
                    Text(
                      'Last seen at 9:15 AM',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Messages list (API-driven) — design same
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, prov, _) {
                final loading = prov.loading;
                final items = prov.conversationMessages; // List<ConversationItem>

                if (loading && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length + 1, // +1 for "Today"
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Today",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      );
                    }

                    final it = items[index - 1];
                    final msg = it.lastMessage;

                    // graceful fallback
                    final text = (msg?.message?.isNotEmpty ?? false)
                        ? msg!.message!
                        : ((msg?.mediaPath?.isNotEmpty ?? false)
                        ? '[media]'
                        : '(no message)');

                    // LEFT if sender == "other person" (item.sender)
                    final isLeft = (msg?.senderId ?? it.sender.id) == it.sender.id;

                    final bubble = Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLeft ? Colors.grey[200] : Colors.pink[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isLeft ? Colors.black : Colors.white,
                        ),
                      ),
                    );

                    return Column(
                      crossAxisAlignment:
                      isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: isLeft
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: bubble,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input (unchanged design)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.pink[200],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // TODO: send message API (jab endpoint mile)
                      // _msgController.text use karke POST karo, aur success par list refresh:
                      // context.read<AuthProvider>().fetchConversationMessages(widget.conversationId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
class ChatScreen extends StatelessWidget {
  final String name;
  final String image;

  // Constructor to receive data
  ChatScreen({required this.name, required this.image});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Back Icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          name,
          style: TextStyle(color: Colors.black), // Title color
        ),
        backgroundColor: Colors.white,  // AppBar background color
        elevation: 0, // Remove shadow for a clean design
      ),
      body: Column(
        children: [
          // Chat Messages
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(image),
                  radius: 30,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last seen at 9:15 AM',  // You can customize this as per your need
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Today date and messages
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Today",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 10),
                // Sender's message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Hey, how\'s the wedding planning going?'),
                  ),
                ),
                SizedBox(height: 10),
                // Receiver's message
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.pink[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Everything\'s on track! Just finalizing the menu.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Receiver's message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('That sounds exciting! Do you need any suggestions?'),
                  ),
                ),
                SizedBox(height: 10),
                // Sender's message
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.pink[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'That would be fantastic, thank you!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Sender's message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Great, just send me the time and place.'),
                  ),
                ),
                SizedBox(height: 10),
                // Receiver's message
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.pink[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Absolutely! Talk soon.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message Input Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Input field
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type in your message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Send button
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.pink[200],
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
