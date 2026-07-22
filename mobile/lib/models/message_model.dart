import 'user_model.dart';

class MessageModel {
  final String id;
  final String bookingId;
  final UserModel? sender;
  final String senderId;
  final UserModel? receiver;
  final String receiverId;
  final String content;
  final String? attachment;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.bookingId,
    this.sender,
    required this.senderId,
    this.receiver,
    required this.receiverId,
    required this.content,
    this.attachment,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['booking'] is String ? json['booking'] : json['bookingId'] ?? '',
      sender: json['sender'] != null && json['sender'] is Map<String, dynamic>
          ? UserModel.fromJson(json['sender'])
          : null,
      senderId: json['sender'] is String
          ? json['sender']
          : (json['sender'] is Map ? (json['sender']['_id'] ?? json['sender']['id'] ?? '') : json['senderId'] ?? ''),
      receiver: json['receiver'] is Map<String, dynamic>
          ? (() { try { return UserModel.fromJson(json['receiver']); } catch (_) { return null; } })()
          : null,
      receiverId: json['receiver'] is String
          ? json['receiver']
          : (json['receiver'] is Map ? (json['receiver']['_id'] ?? json['receiver']['id'] ?? '') : json['receiverId'] ?? ''),
      content: json['content'] ?? '',
      attachment: json['attachment'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'attachment': attachment,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Conversation model
class ConversationModel {
  final String? bookingId;
  final UserModel? otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;

  ConversationModel({
    this.bookingId,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    UserModel? otherUser;
    if (json['otherUser'] is Map<String, dynamic>) {
      try { otherUser = UserModel.fromJson(json['otherUser']); } catch (_) {}
    }
    return ConversationModel(
      bookingId: json['bookingId'] as String?,
      otherUser: otherUser,
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? (() { try { return MessageModel.fromJson(json['lastMessage']); } catch(_) { return null; } })()
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
