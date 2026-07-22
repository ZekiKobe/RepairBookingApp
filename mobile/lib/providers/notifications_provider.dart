import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final _service = NotificationService();

  NotificationsNotifier() : super(const NotificationsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.getNotifications();
    if (res.success) {
      final list = res.data ?? [];
      final unread = list.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: list, unreadCount: unread, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: res.message);
    }
  }

  Future<void> loadUnreadCount() async {
    final count = await _service.getUnreadCount();
    state = state.copyWith(unreadCount: count);
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    final updated = state.notifications.map((n) => NotificationModel(
      id: n.id, type: n.type, title: n.title, body: n.body,
      bookingId: n.bookingId, isRead: true, createdAt: n.createdAt,
    )).toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
  }

  Future<void> markOneRead(String id) async {
    await _service.markOneRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id, type: n.type, title: n.title, body: n.body,
          bookingId: n.bookingId, isRead: true, createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});
