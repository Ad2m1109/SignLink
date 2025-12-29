import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'sign_language.dart';

class ConversationPage extends StatefulWidget {
  final String friendEmail;
  final String conversationId;
  final bool isDarkMode;

  const ConversationPage({
    super.key,
    required this.friendEmail,
    required this.conversationId,
    required this.isDarkMode,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isWritingMessage = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? userId;
  String friendName = "Loading...";
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadFriendName();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages(isPolling: true);
    });
  }

  Future<void> _loadMessages({bool isPolling = false}) async {
    try {
      final token = await UserPreferences.getUserToken();
      userId = await UserPreferences.getUserId();
      if (token != null && userId != null) {
        final fetchedMessages = await ApiService.getConversationMessages(
            widget.conversationId, token);
        if (mounted) {
          setState(() {
            messages = fetchedMessages;
            if (!isPolling) isLoading = false;
          });
          if (!isPolling) _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted && !isPolling) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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
        if (mounted) {
          setState(() {
            friendName = friendProfile['name'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          friendName = widget.friendEmail;
        });
      }
    }
  }

  Future<void> _sendMessage({String? content}) async {
    final message = content ?? _messageController.text.trim();
    if (message.isNotEmpty && userId != null) {
      try {
        final tempMessage = {
          'iduser': userId,
          'contenu': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isSending': true
        };

        setState(() {
          messages.add(tempMessage);
        });
        _scrollToBottom();

        final token = await UserPreferences.getUserToken();
        if (token != null) {
          await ApiService.sendMessage(
              widget.conversationId, userId!, message, token);
          if (content == null) _messageController.clear();
          if (mounted) {
            setState(() {
              if (content == null) isWritingMessage = false;
              messages.removeWhere((msg) => msg['isSending'] == true);
            });
            _loadMessages();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            messages.removeWhere((msg) => msg['isSending'] == true);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      }
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isMyMessage = message['iduser'].toString() == userId.toString();
    final isSending = message['isSending'] == true;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMyMessage ? 50 : 10,
          right: isMyMessage ? 10 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isMyMessage
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMyMessage ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMyMessage ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMyMessage ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message['contenu'],
              style: GoogleFonts.outfit(
                color: isMyMessage ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(message['timestamp'] ?? ''),
                  style: TextStyle(
                    color: isMyMessage ? Colors.white70 : Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
                if (isSending) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.access_time, size: 10, color: Colors.white70)
                ]
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
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
        title: Text(friendName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.white
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              Text(
                                "No messages yet.\nStart a conversation!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[500],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(messages[index], index);
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    if (isWritingMessage)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            onPressed: () => _sendMessage(),
                            mini: true,
                            elevation: 0,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ],
                      ).animate().fadeIn(),
                    if (!isWritingMessage)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => isWritingMessage = true),
                              icon: const Icon(Icons.keyboard),
                              label: const Text("Text"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignLanguagePage(),
                                  ),
                                );
                                if (result != null && result is String) {
                                  _sendMessage(content: result);
                                }
                              },
                              icon: const Icon(Icons.back_hand),
                              label: const Text("Sign"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().slideY(begin: 0.5, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
