import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/booking_model.dart';

class BookingService {
  final ApiService _api = ApiService();

  // Get my bookings (for customers)
  Future<ApiResponse<List<BookingModel>>> getMyBookings() async {
    try {
      final response = await _api.dio.get('/bookings/my-bookings');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final list = raw is List ? raw : (raw['bookings'] as List? ?? []);
          final bookings = list.map((json) => BookingModel.fromJson(json)).toList();
          return ApiResponse(
            success: true,
            data: bookings,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get bookings',
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

  // Get technician bookings (for technicians)
  Future<ApiResponse<List<BookingModel>>> getTechnicianBookings() async {
    try {
      final response = await _api.dio.get('/bookings/technician-bookings');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final list = raw is List ? raw : (raw['bookings'] as List? ?? []);
          final bookings = list.map((json) => BookingModel.fromJson(json)).toList();
          return ApiResponse(
            success: true,
            data: bookings,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get bookings',
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

  // Get single booking
  Future<ApiResponse<BookingModel>> getBooking(String id) async {
    try {
      final response = await _api.dio.get('/bookings/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: BookingModel.fromJson(data['data']),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get booking',
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

  // Create booking
  Future<ApiResponse<BookingModel>> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _api.dio.post('/bookings', data: request.toJson());

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: BookingModel.fromJson(data['data']),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to create booking',
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

  // Cancel booking
  Future<ApiResponse<void>> cancelBooking(String id) async {
    try {
      final response = await _api.dio.put('/bookings/$id/cancel');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to cancel booking',
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

  // Update booking status (technician only)
  Future<ApiResponse<void>> updateStatus(String id, String status) async {
    try {
      final response = await _api.dio.put('/bookings/$id/status', data: {
        'status': status,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update status',
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

  // Accept booking (technician only)
  Future<ApiResponse<void>> acceptBooking(String id) async {
    try {
      final response = await _api.dio.put('/bookings/$id/accept');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to accept booking',
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

  // Submit review for a completed booking
  Future<ApiResponse<void>> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _api.dio.post('/reviews', data: {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      });
      if (response.statusCode == 201 && response.data['success'] == true) {
        return ApiResponse(success: true, message: response.data['message']);
      }
      return ApiResponse(success: false, message: response.data['message'] ?? 'Failed to submit review');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Initiate payment — returns checkoutUrl for real providers, or null for mock
  Future<ApiResponse<Map<String, dynamic>>> initiatePayment(String bookingId) async {
    try {
      final res = await _api.dio.post('/payments/intent', data: {'bookingId': bookingId});
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResponse(success: true, data: Map<String, dynamic>.from(res.data['data']));
      }
      return ApiResponse(success: false, message: res.data['message'] ?? 'Failed to initiate payment');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Confirm payment (call after returning from checkout URL, or directly for mock)
  Future<ApiResponse<void>> confirmPayment(String bookingId, {String? txRef}) async {
    try {
      final confirmRes = await _api.dio.post('/payments/confirm', data: {
        'bookingId': bookingId,
        if (txRef != null) 'txRef': txRef,
      });
      if (confirmRes.statusCode == 200 && confirmRes.data['success'] == true) {
        return ApiResponse(success: true, message: 'Payment confirmed');
      }
      return ApiResponse(success: false, message: confirmRes.data['message'] ?? 'Payment failed');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
