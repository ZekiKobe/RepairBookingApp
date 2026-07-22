import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  // Base URL - Change this to your backend URL
  // For Android emulator: http://10.0.2.2:5000/api
  // For iOS simulator: http://localhost:5000/api
  // For physical device: use your computer's LAN IP address
<<<<<<< HEAD
  // static const String baseUrl = 'http://172.16.238.225:5000/api';
  static const String baseUrl = 'http://localhost:5000/api';

  /// Socket.IO server origin (strip trailing `/api`).
  static String get socketOrigin =>
      baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
=======
  static const String baseUrl = 'http://172.16.238.225:5000/api';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

  Dio get dio => _dio;

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 - Unauthorized
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            _token = null;
          }
          return handler.next(error);
        },
      ),
    );

    // Load token from storage
    await _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  String? get token => _token;
  bool get isAuthenticated => _token != null;
}

// Global API error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) parser,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? parser(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }
}
