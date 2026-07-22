import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/service_model.dart';

class ServiceService {
  final ApiService _api = ApiService();

  // Get all services
  Future<ApiResponse<List<ServiceModel>>> getServices({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _api.dio.get(
        '/services',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          // API returns { data: { services: [...] } } or { data: [...] }
          final List rawList = raw is List
              ? raw
              : (raw['services'] as List? ?? []);
          final services = rawList
              .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse(
            success: true,
            data: services,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get services',
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

  // Get service categories
  Future<ApiResponse<List<ServiceCategory>>> getCategories() async {
    try {
      final response = await _api.dio.get('/services/categories');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          // API returns { data: { categories: [...] } } or { data: [...] }
          final List rawList = raw is List
              ? raw
              : (raw['categories'] as List? ?? []);
          final categories = rawList
              .map((json) => ServiceCategory.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse(
            success: true,
            data: categories,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get categories',
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

  // Get single service
  Future<ApiResponse<ServiceModel>> getService(String id) async {
    try {
      final response = await _api.dio.get('/services/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: ServiceModel.fromJson(data['data']),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get service',
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
