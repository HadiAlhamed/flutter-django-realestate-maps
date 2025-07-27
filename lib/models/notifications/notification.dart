// ignore_for_file: public_member_api_docs, sort_constructors_first

enum NotificationType {
  propertyStatus,
  propertyFavorited,
  propertyPriceChange,
  propertyRated,
}

// Extension for enum to string (toJson)
extension NotificationTypeExtension on NotificationType {
  String toJson() {
    switch (this) {
      case NotificationType.propertyStatus:
        return "property_status";
      case NotificationType.propertyFavorited:
        return "property_favorited";
      case NotificationType.propertyPriceChange:
        return "property_price_change";
      case NotificationType.propertyRated:
        return "property_rated";
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.propertyStatus:
        return "Property Status";
      case NotificationType.propertyFavorited:
        return "Property Favorited";
      case NotificationType.propertyPriceChange:
        return "Price Changed";
      case NotificationType.propertyRated:
        return "Property Rated";
    }
  }
}

// String to enum (fromJson)
NotificationType notificationTypeFromJson(String? value) {
  switch (value) {
    case 'property_status':
      return NotificationType.propertyStatus;
    case 'property_favorited':
      return NotificationType.propertyFavorited;
    case 'property_price_change':
      return NotificationType.propertyPriceChange;
    case 'property_rated':
      return NotificationType.propertyRated;
    default:
      throw Exception("Unknown notification type: $value");
  }
}

class Notification {
  final int id;
  final int recipientId;
  final String recipientEmail;
  final NotificationType notificationType;
  final String notificationTypeDisplay; // title
  final String message;
  bool isRead;
  final DateTime createdAt;
  final String relatedObjectData;

  Notification({
    required this.id,
    required this.recipientId,
    required this.recipientEmail,
    required this.notificationType,
    required this.notificationTypeDisplay,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.relatedObjectData,
  });

  Notification copyWith({
    int? id,
    int? recipientId,
    String? recipientEmail,
    NotificationType? notificationType,
    String? notificationTypeDisplay,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? relatedObjectData,
  }) {
    return Notification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      notificationType: notificationType ?? this.notificationType,
      notificationTypeDisplay:
          notificationTypeDisplay ?? this.notificationTypeDisplay,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedObjectData: relatedObjectData ?? this.relatedObjectData,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'recipient_id': recipientId,
      'recipient_email': recipientEmail,
      'notification_type': notificationType.toJson(),
      'notification_type_display': notificationTypeDisplay,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'related_object_data': relatedObjectData,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as int,
      recipientId: map['recipient_id'] as int,
      recipientEmail: map['recipient_email'] as String,
      notificationType:
          notificationTypeFromJson(map['notification_type'] as String),
      notificationTypeDisplay: map['notification_type_display'] as String,
      message: map['message'] as String,
      isRead: map['is_read'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      relatedObjectData: map['related_object_data'] as String,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, recipientId: $recipientId, recipientEmail: $recipientEmail, notificationType: $notificationType, notificationTypeDisplay: $notificationTypeDisplay, message: $message, isRead: $isRead, createdAt: $createdAt, relatedObjectData: $relatedObjectData)';
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.recipientId == recipientId &&
        other.recipientEmail == recipientEmail &&
        other.notificationType == notificationType &&
        other.notificationTypeDisplay == notificationTypeDisplay &&
        other.message == message &&
        other.isRead == isRead &&
        other.createdAt == createdAt &&
        other.relatedObjectData == relatedObjectData;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        recipientId.hashCode ^
        recipientEmail.hashCode ^
        notificationType.hashCode ^
        notificationTypeDisplay.hashCode ^
        message.hashCode ^
        isRead.hashCode ^
        createdAt.hashCode ^
        relatedObjectData.hashCode;
  }
}
