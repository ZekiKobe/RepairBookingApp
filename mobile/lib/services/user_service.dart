import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class UserService {
  final ApiService _api = ApiService();

  // Get my profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _api.dio.get('/users/profile');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final userJson = raw is Map && raw.containsKey('user') ? raw['user'] : raw;
          return ApiResponse(
            success: true,
            data: UserModel.fromJson(userJson as Map<String, dynamic>),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get profile',
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

  // Update profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (email != null) updateData['email'] = email;
      if (avatar != null) updateData['avatar'] = avatar;

      final response = await _api.dio.put('/users/profile', data: updateData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final userJson = raw is Map && raw.containsKey('user') ? raw['user'] : raw;
          return ApiResponse(
            success: true,
            data: UserModel.fromJson(userJson as Map<String, dynamic>),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update profile',
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

  // Set location
  Future<ApiResponse<void>> setLocation({
    required String type,
    required List<double> coordinates,
    String? address,
  }) async {
    try {
      final response = await _api.dio.put('/users/location', data: {
        'type': type,
        'coordinates': coordinates,
        'address': address,
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
        message: response.data['message'] ?? 'Failed to set location',
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
