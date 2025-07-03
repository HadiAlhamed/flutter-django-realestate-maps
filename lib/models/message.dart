class Message {
  final String id;
  final String senderId;
  final String senderFirstName;
  final String senderLastName;
  final String senderPhoto;
  final String? content;
  final String? fileUrl;
  final String messageType;
  final DateTime createdAt;
  bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderPhoto,
    required this.content,
    required this.fileUrl,
    required this.messageType,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderFirstName: json['sender_first_name'] as String,
      senderLastName: json['sender_last_name'] as String,
      senderPhoto: json['sender_photo'] as String,
      content: json['content'] as String,
      fileUrl: json['file_url'] as String,
      messageType: json['message_type'] as String,
      createdAt: json['created_at'] as DateTime,
      isRead: json['is_read'] as bool,
    );
  }
}
