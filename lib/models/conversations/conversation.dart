// ignore_for_file: public_member_api_docs, sort_constructors_first

class Conversation {
  final int id;
  final int otherUserId;
  final String otherUserFirstName;
  final String otherUserLastName;
  String? otherUserPhotoUrl;
  bool? otherUserIsOnline;
  DateTime? otherUserLastSeen;
  String? lastMessage;
  int? lastMessageId;
  int unreadCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? expiresAt;
  DateTime? activatedAt;
  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserFirstName,
    required this.otherUserLastName,
    this.otherUserPhotoUrl,
    this.otherUserIsOnline,
    this.otherUserLastSeen,
    this.lastMessage,
    this.lastMessageId,
    required this.unreadCount,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.activatedAt,
  });

  Conversation copyWith({
    int? id,
    int? otherUserId,
    String? otherUserFirstName,
    String? otherUserLastName,
    String? otherUserPhotoUrl,
    bool? otherUserIsOnline,
    DateTime? otherUserLastSeen,
    String? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? activatedAt,
    int? lastMessageId,
  }) {
    return Conversation(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserFirstName: otherUserFirstName ?? this.otherUserFirstName,
      otherUserLastName: otherUserLastName ?? this.otherUserLastName,
      otherUserPhotoUrl: otherUserPhotoUrl ?? this.otherUserPhotoUrl,
      otherUserIsOnline: otherUserIsOnline ?? this.otherUserIsOnline,
      otherUserLastSeen: otherUserLastSeen ?? this.otherUserLastSeen,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      expiresAt: expiresAt ?? this.expiresAt,
      activatedAt: activatedAt ?? this.activatedAt,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> map) {
    final lastMessageMap = map['last_message'] as Map<String, dynamic>?;

    return Conversation(
      id: map['id'] as int,
      otherUserId: map['other_user_id'] as int,
      otherUserFirstName: map['other_user_first_name'] as String,
      otherUserLastName: map['other_user_last_name'] as String,
      otherUserPhotoUrl: map['other_user_photo'] as String?,
      otherUserIsOnline: map['other_user_is_online'] as bool?,
      otherUserLastSeen: map['other_user_last_seen'] != null
          ? DateTime.parse(map['other_user_last_seen'])
          : null,
      lastMessage: lastMessageMap?['content'] as String?,
      lastMessageId: lastMessageMap?['id'] is String
          ? int.parse(lastMessageMap?['id'])
          : lastMessageMap?['id'],
      unreadCount: map['unread_count'] ?? 0,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      expiresAt:
          map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      activatedAt: map['activated_at'] != null
          ? DateTime.parse(map['activated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'other_user_id': otherUserId,
      'other_user_first_name': otherUserFirstName,
      'other_user_last_name': otherUserLastName,
      'other_user_photo': otherUserPhotoUrl,
      'other_user_is_online': otherUserIsOnline,
      'other_user_last_seen': otherUserLastSeen?.toIso8601String(),
      'last_message': lastMessage != null ? {'content': lastMessage} : null,
      'unread_count': unreadCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Conversation(id: $id, otherUserId: $otherUserId, otherUserFirstName: $otherUserFirstName, otherUserLastName: $otherUserLastName, otherUserPhotoUrl: $otherUserPhotoUrl, otherUserIsOnline: $otherUserIsOnline, otherUserLastSeen: $otherUserLastSeen, lastMessage: $lastMessage, unreadCount: $unreadCount, createdAt: $createdAt, updatedAt: $updatedAt , expiresAt : $expiresAt , activatedAt : $activatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Conversation &&
        other.id == id &&
        other.otherUserId == otherUserId &&
        other.otherUserFirstName == otherUserFirstName &&
        other.otherUserLastName == otherUserLastName &&
        other.otherUserPhotoUrl == otherUserPhotoUrl &&
        other.otherUserIsOnline == otherUserIsOnline &&
        other.otherUserLastSeen == otherUserLastSeen &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt &&
        other.activatedAt == activatedAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        otherUserId.hashCode ^
        otherUserFirstName.hashCode ^
        otherUserLastName.hashCode ^
        otherUserPhotoUrl.hashCode ^
        otherUserIsOnline.hashCode ^
        otherUserLastSeen.hashCode ^
        lastMessage.hashCode ^
        unreadCount.hashCode ^
        createdAt.hashCode ^
        expiresAt.hashCode ^
        activatedAt.hashCode ^
        updatedAt.hashCode;
  }
}
