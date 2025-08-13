// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:intl/intl.dart';

class ActivateChatModel {
  String detail;
  int? conversationId;
  DateTime? expiresAt;
  double newPointsBalance;
  ActivateChatModel({
    required this.detail,
    this.conversationId,
    this.expiresAt,
    required this.newPointsBalance,
  });

  ActivateChatModel copyWith({
    String? detail,
    int? conversationId,
    DateTime? expiresAt,
    double? newPointsBalance,
  }) {
    return ActivateChatModel(
      detail: detail ?? this.detail,
      conversationId: conversationId ?? this.conversationId,
      expiresAt: expiresAt ?? this.expiresAt,
      newPointsBalance: newPointsBalance ?? this.newPointsBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'detail': detail,
      if (conversationId != null) 'conversation_id': conversationId,
      if (expiresAt != null) 'expires_at': expiresAt.toString(),
      'new_points_balance': newPointsBalance,
    };
  }

  factory ActivateChatModel.fromJson(Map<String, dynamic> map) {
    return ActivateChatModel(
      detail: map['detail'] as String,
      conversationId:
          map['conversation_id'] != null ? map['conversation_id'] as int : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      newPointsBalance: (map['new_points_balance'] as int).toDouble(),
    );
  }

  @override
  String toString() {
    return 'ActivateChatModel(detail: $detail, conversationId: $conversationId, expiresAt: $expiresAt, newPointsBalance: $newPointsBalance)';
  }

  @override
  bool operator ==(covariant ActivateChatModel other) {
    if (identical(this, other)) return true;

    return other.detail == detail &&
        other.conversationId == conversationId &&
        other.expiresAt == expiresAt &&
        other.newPointsBalance == newPointsBalance;
  }

  @override
  int get hashCode {
    return detail.hashCode ^
        conversationId.hashCode ^
        expiresAt.hashCode ^
        newPointsBalance.hashCode;
  }
}
