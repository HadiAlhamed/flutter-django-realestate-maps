// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatStatusCheck {
  // "status_code": "STRING_CODE",
  //       "conversation_id": null | INTEGER,
  //       "cost": null | DECIMAL,
  //       "current_points": INTEGER,
  //       "expires_at": null | DATETIME_STRING,
  //       "message": "Descriptive message for UI"
  String statusCode;
  int? conversationId;
  double? cost; //maybe should be double
  int currentPoint;
  DateTime? expiresAt;
  String message;
  ChatStatusCheck({
    required this.statusCode,
    this.conversationId,
    this.cost,
    required this.currentPoint,
    this.expiresAt,
    required this.message,
  });

  ChatStatusCheck copyWith({
    String? statusCode,
    int? conversationId,
    double? cost,
    int? currentPoint,
    DateTime? expiresAt,
    String? message,
  }) {
    return ChatStatusCheck(
      statusCode: statusCode ?? this.statusCode,
      conversationId: conversationId ?? this.conversationId,
      cost: cost ?? this.cost,
      currentPoint: currentPoint ?? this.currentPoint,
      expiresAt: expiresAt ?? this.expiresAt,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status_code': statusCode,
      'conversation_id': conversationId,
      'cost': cost,
      'current_point': currentPoint,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
      'message': message,
    };
  }

  factory ChatStatusCheck.fromJson(Map<String, dynamic> map) {
    return ChatStatusCheck(
      statusCode: map['status_code'] as String,
      conversationId:
          map['conversation_id'] != null ? map['conversation_id'] as int : null,
      cost: map['cost'] != null ? double.parse(map['cost'] as String) : null,
      currentPoint:
          map['current_points'] == null ? 0 : map['current_points'] as int,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      message: map['message'] as String,
    );
  }

  @override
  String toString() {
    return 'ChatStatusCheck(statusCode: $statusCode, conversationId: $conversationId, cost: $cost, currentPoint: $currentPoint, expiresAt: $expiresAt, message: $message)';
  }

  @override
  bool operator ==(covariant ChatStatusCheck other) {
    if (identical(this, other)) return true;

    return other.statusCode == statusCode &&
        other.conversationId == conversationId &&
        other.cost == cost &&
        other.currentPoint == currentPoint &&
        other.expiresAt == expiresAt &&
        other.message == message;
  }

  @override
  int get hashCode {
    return statusCode.hashCode ^
        conversationId.hashCode ^
        cost.hashCode ^
        currentPoint.hashCode ^
        expiresAt.hashCode ^
        message.hashCode;
  }
}
