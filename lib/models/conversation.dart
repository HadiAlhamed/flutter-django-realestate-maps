// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Conversation {
  final int id;
  final int otherUserId;
  final String otherUserFirstName;
  final String otherUserLastName;
  final String otherUserPhotoUrl;
  final bool otherUserIsOnline;
  final DateTime otherUserLastSeen;
  String? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserFirstName,
    required this.otherUserLastName,
    required this.otherUserPhotoUrl,
    required this.otherUserIsOnline,
    required this.otherUserLastSeen,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
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
      'other_user_last_seen': otherUserLastSeen.millisecondsSinceEpoch,
      'last_message': lastMessage,
      'unread_count': unreadCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as int,
      otherUserId: map['other_user_id'] as int,
      otherUserFirstName: map['other_user_first_name'] as String,
      otherUserLastName: map['other_user_last_name'] as String,
      otherUserPhotoUrl: map['other_user_photo'] as String,
      otherUserIsOnline: map['other_user_is_online'] as bool,
      otherUserLastSeen: DateTime.fromMillisecondsSinceEpoch(
          map['other_user_last_seen'] as int),
      lastMessage:
          map['last_message'] != null ? map['last_message'] as String : null,
      unreadCount: map['unread_count'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  String toString() {
    return 'Conversation(id: $id, otherUserId: $otherUserId, otherUserFirstName: $otherUserFirstName, otherUserLastName: $otherUserLastName, otherUserPhotoUrl: $otherUserPhotoUrl, otherUserIsOnline: $otherUserIsOnline, otherUserLastSeen: $otherUserLastSeen, lastMessage: $lastMessage, unreadCount: $unreadCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Conversation other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.otherUserId == otherUserId &&
        other.otherUserFirstName == otherUserFirstName &&
        other.otherUserLastName == otherUserLastName &&
        other.otherUserPhotoUrl == otherUserPhotoUrl &&
        other.otherUserIsOnline == otherUserIsOnline &&
        other.otherUserLastSeen == otherUserLastSeen &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount &&
        other.createdAt == createdAt &&
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
        updatedAt.hashCode;
  }
}
