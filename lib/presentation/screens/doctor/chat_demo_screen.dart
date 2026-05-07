import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ChatDemoScreen extends StatefulWidget {
  final String doctorId;
  const ChatDemoScreen({super.key, required this.doctorId});

  @override
  State<ChatDemoScreen> createState() => _ChatDemoScreenState();
}

class _ChatDemoScreenState extends State<ChatDemoScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Hello! How can I help you today?',
      'time': '10:00 AM',
    },
    {
      'isMe': true,
      'text': 'Hi Doctor, I have a quick question about my cycle.',
      'time': '10:05 AM',
    },
    {
      'isMe': false,
      'text': 'Sure, please go ahead. What seems to be the issue?',
      'time': '10:06 AM',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': _messageController.text.trim(),
        'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}',
      });
    });
    
    _messageController.clear();

    // Simulate auto-reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isMe': false,
            'text': 'I understand. Could you tell me more about your symptoms?',
            'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}',
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Doctor Consultation', style: TextStyle(fontSize: 16)),
                Text('Online', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['time'],
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
