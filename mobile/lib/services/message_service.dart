import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/message_model.dart';

class MessageService {
  final ApiService _api = ApiService();

  // Get my conversations
  Future<ApiResponse<List<ConversationModel>>> getConversations() async {
    try {
      final response = await _api.dio.get('/messages/conversations');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final list = raw is List ? raw : (raw['conversations'] as List? ?? []);
          final conversations = list
              .map((json) => ConversationModel.fromJson(json))
              .toList();
          return ApiResponse(
            success: true,
            data: conversations,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get conversations',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Get messages for a booking
  Future<ApiResponse<List<MessageModel>>> getBookingMessages(String bookingId) async {
    try {
      final response = await _api.dio.get('/messages/booking/$bookingId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final list = raw is List ? raw : (raw['messages'] as List? ?? []);
          final messages = list.map((json) => MessageModel.fromJson(json)).toList();
          return ApiResponse(
            success: true,
            data: messages,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get messages',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Get direct messages between two users
  Future<ApiResponse<List<MessageModel>>> getDirectMessages(String otherUserId) async {
    try {
      final response = await _api.dio.get('/messages/direct/$otherUserId');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final list = raw is List ? raw : (raw['messages'] as List? ?? []);
          return ApiResponse(success: true, data: list.map((j) => MessageModel.fromJson(j)).toList());
        }
      }
      return ApiResponse(success: false, message: response.data['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Send message
  Future<ApiResponse<MessageModel>> sendMessage({
    String? bookingId,
    String? receiverId,
    required String content,
  }) async {
    try {
      final response = await _api.dio.post('/messages', data: {
        if (bookingId != null) 'bookingId': bookingId,
        if (receiverId != null) 'receiverId': receiverId,
        'content': content,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final msgJson = raw is Map ? (raw['message'] ?? raw) : raw;
          return ApiResponse(
            success: true,
            data: MessageModel.fromJson(msgJson),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to send message',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Get unread count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _api.dio.get('/messages/unread-count');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: data['data']['unreadCount'] ?? data['data']['count'] ?? 0,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get unread count',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
