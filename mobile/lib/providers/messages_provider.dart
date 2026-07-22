import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

// Messages state
class MessagesState {
  final List<ConversationModel> conversations;
  final List<MessageModel> currentMessages;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  MessagesState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<ConversationModel>? conversations,
    List<MessageModel>? currentMessages,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Messages notifier
class MessagesNotifier extends StateNotifier<MessagesState> {
  final MessageService _messageService = MessageService();

  MessagesNotifier() : super(MessagesState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _messageService.getConversations();

    if (response.success) {
      final conversations = response.data ?? [];
      final totalUnread = conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
      state = state.copyWith(
        conversations: conversations,
        unreadCount: totalUnread,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  Future<void> loadMessages(String bookingId) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _messageService.getBookingMessages(bookingId);
    if (response.success) {
      state = state.copyWith(currentMessages: response.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
    }
  }

  Future<void> loadDirectMessages(String otherUserId) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _messageService.getDirectMessages(otherUserId);
    if (response.success) {
      state = state.copyWith(currentMessages: response.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
    }
  }

  Future<bool> sendMessage({
    String? bookingId,
    String? receiverId,
    required String content,
  }) async {
    final response = await _messageService.sendMessage(
      bookingId: bookingId,
      receiverId: receiverId,
      content: content,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        currentMessages: [...state.currentMessages, response.data!],
      );
      return true;
    } else {
      state = state.copyWith(error: response.message);
      return false;
    }
  }

  Future<void> loadUnreadCount() async {
    final response = await _messageService.getUnreadCount();

    if (response.success) {
      state = state.copyWith(unreadCount: response.data ?? 0);
    }
  }

  void clearCurrentMessages() {
    state = state.copyWith(currentMessages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refresh() {
    loadConversations();
    loadUnreadCount();
  }
}

// Provider
final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier();
});
