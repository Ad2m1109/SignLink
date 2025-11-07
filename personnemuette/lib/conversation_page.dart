import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'sign_language.dart';

class ConversationPage extends StatefulWidget {
  final String friendEmail;
  final String conversationId;
  final bool isDarkMode; // Add isDarkMode parameter

  ConversationPage({
    required this.friendEmail,
    required this.conversationId,
    required this.isDarkMode, // Initialize isDarkMode
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isWritingMessage = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? userId;
  String friendName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadFriendName();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final token = await UserPreferences.getUserToken();
      userId = await UserPreferences.getUserId();
      if (token != null && userId != null) {
        final fetchedMessages = await ApiService.getConversationMessages(
            widget.conversationId, token);
        setState(() {
          messages = fetchedMessages;
          isLoading = false;
        });

        // Scroll to bottom after messages load
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadFriendName() async {
    try {
      final token = await UserPreferences.getUserToken();
      if (token != null) {
        final friendProfile =
            await ApiService.getUserProfileByEmail(widget.friendEmail, token);
        setState(() {
          friendName = friendProfile['name'];
        });
      }
    } catch (e) {
      setState(() {
        friendName =
            widget.friendEmail; // Fallback to email if name fetch fails
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && userId != null) {
      try {
        // Create a temporary message with the CURRENT user's ID
        final tempMessage = {
          'iduser': userId, // This ensures the message appears on the right
          'contenu': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isSending': true
        };

        setState(() {
          // Add the temporary message to show immediately
          messages.add(tempMessage);
        });

        // Scroll to bottom after adding the temporary message
        _scrollToBottom();

        final token = await UserPreferences.getUserToken();
        if (token != null) {
          await ApiService.sendMessage(
              widget.conversationId, userId!, message, token);
          _messageController.clear();
          setState(() {
            isWritingMessage = false;
            // Remove the temporary message as we'll reload all messages
            messages.removeWhere((msg) => msg['isSending'] == true);
          });
          _loadMessages(); // Refresh the conversation screen
        }
      } catch (e) {
        // Remove the temporary message on error
        setState(() {
          messages.removeWhere((msg) => msg['isSending'] == true);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMyMessage = message['iduser'].toString() == userId.toString();

    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isMyMessage ? 80 : 10,
        right: isMyMessage ? 10 : 80,
      ),
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isMyMessage
                  ? (widget.isDarkMode ? Colors.blue[700] : Colors.blue[600])
                  : (widget.isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight:
                    isMyMessage ? Radius.circular(0) : Radius.circular(18),
                bottomLeft:
                    isMyMessage ? Radius.circular(18) : Radius.circular(0),
              ),
            ),
            child: Text(
              message['contenu'],
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTimestamp(message['timestamp'] ?? ''),
              style: TextStyle(
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.blue,
        title: Text(
          friendName,
          style: TextStyle(
            color:
                widget.isDarkMode ? Colors.white : Colors.black, // Adjust color
          ),
        ),
        elevation: 1,
      ),
      body: Container(
        color: widget.isDarkMode
            ? Colors.black
            : Colors.white, // Set background color
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                      ? Center(
                          child: Text(
                            "No messages yet. Start a conversation!",
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(messages[index]);
                          },
                        ),
            ),
            Divider(
              height: 1,
              color: widget.isDarkMode ? Colors.grey[700] : Colors.grey[300],
            ),
            if (isWritingMessage)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Write your message...",
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isWritingMessage)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isWritingMessage = true;
                          });
                        },
                        icon: Icon(Icons.message),
                        label: Text("Text Message"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignLanguagePage(),
                              settings: RouteSettings(
                                  arguments: widget
                                      .conversationId), // Pass conversationId
                            ),
                          );
                        },
                        icon: Icon(Icons.sign_language),
                        label: Text("Sign Language"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
