import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/technician_model.dart';

class TechnicianService {
  final ApiService _api = ApiService();

  // Get all technicians
  Future<ApiResponse<List<TechnicianModel>>> getTechnicians({
    String? service,
    String? category,
    bool? available,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (service != null) queryParams['service'] = service;
      if (category != null) queryParams['category'] = category;
      if (available != null) queryParams['isAvailable'] = available.toString();
      if (sort != null) queryParams['sort'] = sort;

      final response = await _api.dio.get(
        '/technicians',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final list = raw is List ? raw : (raw['technicians'] as List? ?? []);
          final technicians = list
              .map((json) => TechnicianModel.fromJson(json))
              .toList();
          return ApiResponse(
            success: true,
            data: technicians,
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get technicians',
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

  // Get single technician
  Future<ApiResponse<TechnicianModel>> getTechnician(String id) async {
    try {
      final response = await _api.dio.get('/technicians/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final json = raw is Map && raw.containsKey('technician') ? raw['technician'] : raw;
          return ApiResponse(
            success: true,
            data: TechnicianModel.fromJson(json),
            message: data['message'],
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to get technician',
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

  // Get my technician profile (for technicians)
  Future<ApiResponse<TechnicianModel>> getMyProfile() async {
    try {
      final response = await _api.dio.get('/technicians/profile/me');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final raw = data['data'];
          final json = raw is Map && raw.containsKey('technician') ? raw['technician'] : raw;
          return ApiResponse(
            success: true,
            data: TechnicianModel.fromJson(json),
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

  // Create technician profile (full registration)
  Future<ApiResponse<TechnicianModel>> createProfile({
    String? bio,
    int yearsOfExperience = 0,
    String? idDocument,
    String? certificationDocument,
    bool isAvailable = true,
    List<Map<String, dynamic>>? services,
    List<Map<String, dynamic>>? customServices,
    dynamic availability,
  }) async {
    try {
      // Append custom service names to bio so they are preserved
      String? effectiveBio = bio;
      if (customServices != null && customServices.isNotEmpty) {
        final names = customServices.map((cs) => '${cs['serviceName']} (ETB ${cs['price']})').join(', ');
        effectiveBio = (effectiveBio != null && effectiveBio.isNotEmpty)
            ? '$effectiveBio\n\nServices offered: $names'
            : 'Services offered: $names';
      }

      final body = <String, dynamic>{
        'isAvailable': isAvailable,
        'yearsOfExperience': yearsOfExperience,
      };
      if (effectiveBio != null && effectiveBio.isNotEmpty) body['bio'] = effectiveBio;
      if (idDocument != null && idDocument.isNotEmpty) body['idDocument'] = idDocument;
      if (certificationDocument != null && certificationDocument.isNotEmpty) {
        body['certificationDocument'] = certificationDocument;
      }
      if (services != null && services.isNotEmpty) body['services'] = services;
      if (availability != null) body['availability'] = availability;

      try {
        final response = await _api.dio.post('/technicians/profile', data: body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data;
          if (data['success'] == true) {
            final raw = data['data'];
            final json = raw is Map && raw.containsKey('technician') ? raw['technician'] : raw;
            return ApiResponse(
              success: true,
              data: TechnicianModel.fromJson(json),
              message: data['message'],
            );
          }
        }

        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to create profile',
        );
      } on DioException catch (postError) {
        // If profile already exists (400), fall back to updating it
        if (postError.response?.statusCode == 400) {
          final existing = await getMyProfile();
          if (existing.success && existing.data != null) {
            final techId = existing.data!.id;
            final putResponse = await _api.dio.put('/technicians/$techId', data: body);
            if (putResponse.statusCode == 200) {
              final data = putResponse.data;
              if (data['success'] == true) {
                final raw = data['data'];
                final json = raw is Map && raw.containsKey('technician') ? raw['technician'] : raw;
                return ApiResponse(
                  success: true,
                  data: TechnicianModel.fromJson(json),
                  message: 'Profile updated successfully',
                );
              }
            }
          }
        }
        return ApiResponse(
          success: false,
          message: postError.response?.data['message'] ?? postError.message ?? 'Network error',
          statusCode: postError.response?.statusCode,
        );
      }
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

  // Update user location (called after registration to save city)
  Future<ApiResponse<void>> updateUserLocation(String location) async {
    try {
      final response = await _api.dio.put('/users/profile', data: {'location': location});
      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Update technician profile
  Future<ApiResponse<TechnicianModel>> updateProfile(String id, {
    String? bio,
    String? specialization,
    List<String>? skills,
    bool? isAvailable,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (bio != null) updateData['bio'] = bio;
      if (specialization != null) updateData['specialization'] = specialization;
      if (skills != null) updateData['skills'] = skills;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;

      final response = await _api.dio.put('/technicians/$id', data: updateData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: TechnicianModel.fromJson(data['data']),
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
}
