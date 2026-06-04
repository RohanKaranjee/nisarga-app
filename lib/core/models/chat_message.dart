class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime sentAt;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.sentAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
      'read': read,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderRole: map['senderRole'] ?? 'patient',
      text: map['text'] ?? '',
      sentAt: _parseDate(map['sentAt']) ?? DateTime.now(),
      read: map['read'] ?? false,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    final dynamic timestamp = value;
    try {
      return timestamp.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
