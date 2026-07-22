import '../models/notification_model.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class NotificationApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  NotificationApiResponse({required this.success, this.data, this.message});
}

class NotificationService {
  final _api = ApiService();

  Future<NotificationApiResponse<List<NotificationModel>>> getNotifications() async {
    try {
      final res = await _api.dio.get('/notifications');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['data']['notifications'] as List)
            .map((j) => NotificationModel.fromJson(j))
            .toList();
        return NotificationApiResponse(success: true, data: list);
      }
      return NotificationApiResponse(success: false, message: res.data['message']);
    } on DioException catch (e) {
      return NotificationApiResponse(success: false, message: e.response?.data['message'] ?? e.message);
    } catch (e) {
      return NotificationApiResponse(success: false, message: e.toString());
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _api.dio.get('/notifications/unread-count');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data']['unreadCount'] ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.dio.put('/notifications/read-all');
    } catch (_) {}
  }

  Future<void> markOneRead(String id) async {
    try {
      await _api.dio.put('/notifications/$id/read');
    } catch (_) {}
  }
}
