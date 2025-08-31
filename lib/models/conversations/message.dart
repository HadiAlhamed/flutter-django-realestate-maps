class Message {
  final int id;
  final int senderId;
  final String senderFirstName;
  final String senderLastName;
  final String? senderPhoto;
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
    this.senderPhoto,
    this.content,
    this.fileUrl,
    required this.messageType,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // print("runtime type of message id : ${json['id'].runtimeType}");
    return Message(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      senderId: json['sender_id'] is String
          ? int.parse(json['sender_id'])
          : json['sender_id'] as int,
      senderFirstName: json['sender_first_name'] as String,
      senderLastName: json['sender_last_name'] as String,
      senderPhoto: json['sender_photo'] as String?,
      content: json['content'] as String?,
      fileUrl: json['file_url'] as String?,
      messageType: json['message_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool,
    );
  }
}
