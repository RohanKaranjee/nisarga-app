import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/doctor.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String? patientId;

  const ChatScreen({super.key, required this.doctorId, this.patientId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  String? _preparedChatId;
  String? _preparedRecipientId;
  Future<void>? _prepareChatFuture;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    if (auth.isProfileLoading || auth.role.isEmpty) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return StreamBuilder<Doctor?>(
      stream: _service.watchDoctor(widget.doctorId),
      builder: (context, doctorSnapshot) {
        if (doctorSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load doctor: ${doctorSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final doctor = doctorSnapshot.data;
        if (auth.isPatient &&
            doctorSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }
        if (auth.isPatient && doctor == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Doctor not available.')),
          );
        }

        final patientId = auth.isDoctor ? widget.patientId : user.uid;
        if (auth.isDoctor && (patientId == null || patientId.isEmpty)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(
              child: Text('Open chat from an appointment to select a patient.'),
            ),
          );
        }

        final chatId = _service.directChatId(patientId!, widget.doctorId);
        final doctorUserId = auth.isDoctor ? user.uid : (doctor?.userId ?? '');
        final recipientId = auth.isDoctor ? patientId : doctorUserId;
        if (recipientId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Chat is not available because this doctor is not linked to a doctor login account. You can still request an appointment.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        final recipientRoute = auth.isPatient
            ? '/doctor/chat/${widget.doctorId}?patientId=${user.uid}'
            : '/doctor/chat/${widget.doctorId}';

        return FutureBuilder<void>(
          future: _prepareChat(
            chatId,
            user.uid,
            recipientId,
            patientId: patientId,
            doctorUserId: doctorUserId,
          ),
          builder: (context, prepareSnapshot) {
            if (prepareSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body:
                    SafeArea(child: Center(child: CircularProgressIndicator())),
              );
            }
            if (prepareSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Chat')),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Unable to open chat: ${prepareSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.isDoctor
                                ? 'Patient Chat'
                                : (doctor?.name ?? 'Doctor'),
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text('Realtime',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<ChatMessage>>(
                      stream: _service.watchMessages(chatId),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? [];
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Unable to load messages: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        if (messages.isEmpty) {
                          return const Center(
                            child: Text(
                                'No messages yet. Start the conversation.'),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == user.uid;
                            return _MessageBubble(message: message, isMe: isMe);
                          },
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              enabled: !_sending,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              onSubmitted: (_) => _sendMessage(chatId, user.uid,
                                  auth.role, recipientId, recipientRoute),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send, color: Colors.white),
                              onPressed: _sending
                                  ? null
                                  : () => _sendMessage(chatId, user.uid,
                                      auth.role, recipientId, recipientRoute),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _prepareChat(
    String chatId,
    String senderId,
    String recipientId, {
    required String patientId,
    required String doctorUserId,
  }) {
    if (_preparedChatId == chatId &&
        _preparedRecipientId == recipientId &&
        _prepareChatFuture != null) {
      return _prepareChatFuture!;
    }
    _preparedChatId = chatId;
    _preparedRecipientId = recipientId;
    _prepareChatFuture = _service.ensureChat(
      chatId: chatId,
      senderId: senderId,
      recipientId: recipientId,
      patientId: patientId,
      doctorUserId: doctorUserId,
    );
    return _prepareChatFuture!;
  }

  Future<void> _sendMessage(
    String chatId,
    String senderId,
    String senderRole,
    String recipientId,
    String recipientRoute,
  ) async {
    if (_sending) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    _messageController.clear();
    setState(() => _sending = true);
    try {
      await _service.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderRole: senderRole,
        recipientId: recipientId,
        text: text,
        route: recipientRoute,
      );
    } catch (e) {
      if (mounted) {
        _messageController.text = text;
        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length,
        );
        messenger.showSnackBar(
          SnackBar(
            content: Text('Message failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: isMe ? const Radius.circular(0) : null,
                bottomLeft: !isMe ? const Radius.circular(0) : null,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white70
                        : theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
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
