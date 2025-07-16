// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:real_estate/models/conversations/conversation.dart';

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
      conversations: (json['results'] as List).map((conversation) {
        return Conversation.fromJson(conversation);
      }).toList(),
      nextUrl: json['next'],
    );
  }

  @override
  int get hashCode => conversations.hashCode ^ nextUrl.hashCode;
}
