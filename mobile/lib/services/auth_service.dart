import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import '../models/user_model.dart';

final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

class AuthService {
  final ApiService _api = ApiService();

  // Register
  Future<ApiResponse<UserModel>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _api.dio.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'password': password,
        'role': role,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final tokens = data['data']?['tokens'];
          if (tokens?['accessToken'] != null) {
            await _api.setToken(tokens['accessToken']);
          }
          return ApiResponse(
            success: true,
            data: UserModel.fromJson(data['data']['user']),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Registration failed',
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

  // Login
  Future<ApiResponse<UserModel>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final tokens = data['data']?['tokens'];
          if (tokens?['accessToken'] != null) {
            await _api.setToken(tokens['accessToken']);
          }
          return ApiResponse(
            success: true,
            data: UserModel.fromJson(data['data']['user']),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Login failed',
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

  // Get current user
  Future<ApiResponse<UserModel>> getMe() async {
    try {
      final response = await _api.dio.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: UserModel.fromJson(data['data']['user']),
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get user',
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

  // Forgot password – request OTP
  Future<ApiResponse<String?>> forgotPassword(String phone) async {
    try {
      final response = await _api.dio.post('/auth/forgot-password', data: {'phone': phone});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final otp = response.data['data']?['otp'] as String?;
        return ApiResponse(success: true, data: otp, message: response.data['message']);
      }
      return ApiResponse(success: false, message: response.data['message'] ?? 'Failed to send OTP');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Verify OTP
  Future<ApiResponse<void>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _api.dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse(success: true, message: response.data['message']);
      }
      return ApiResponse(success: false, message: response.data['message'] ?? 'Invalid OTP');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Reset password
  Future<ApiResponse<void>> resetPassword(String phone, String otp, String newPassword) async {
    try {
      final response = await _api.dio.post('/auth/reset-password', data: {
        'phone': phone,
        'otp': otp,
        'newPassword': newPassword,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse(success: true, message: response.data['message']);
      }
      return ApiResponse(success: false, message: response.data['message'] ?? 'Failed to reset password');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Google Sign-In
  Future<ApiResponse<UserModel>> googleSignIn({String role = 'user'}) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return ApiResponse(success: false, message: 'Google sign-in cancelled');
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        return ApiResponse(success: false, message: 'Failed to get Google ID token');
      }

      final response = await _api.dio.post('/auth/google', data: {
        'idToken': idToken,
        'role': role,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tokens = response.data['data']?['tokens'];
        if (tokens?['accessToken'] != null) {
          await _api.setToken(tokens['accessToken']);
        }
        return ApiResponse(
          success: true,
          data: UserModel.fromJson(response.data['data']['user']),
          message: response.data['message'],
        );
      }
      return ApiResponse(success: false, message: response.data['message'] ?? 'Google auth failed');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) {});
    await _api.clearToken();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _api.isAuthenticated;
}
