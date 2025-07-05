// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:real_estate/models/conversation.dart';

class PaginatedConversation {
  final List<Conversation> conversations;
  final String? nextUrl;
  PaginatedConversation({
    required this.conversations,
    this.nextUrl,
  });

  PaginatedConversation copyWith({
    List<Conversation>? conversations,
    String? nextUrl,
  }) {
    return PaginatedConversation(
      conversations: conversations ?? this.conversations,
      nextUrl: nextUrl ?? this.nextUrl,
    );
  }

  factory PaginatedConversation.fromJson(Map<String, dynamic> json) {
    return PaginatedConversation(
      conversations: json['results'].map((conversation) {
        return Conversation.fromJson(conversation);
      }),
      nextUrl: json['next'],
    );
  }

  @override
  int get hashCode => conversations.hashCode ^ nextUrl.hashCode;
}
