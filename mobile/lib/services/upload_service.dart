import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

class UploadService {
  final _api = ApiService();

  /// Upload avatar image. Returns the CDN/local URL on success.
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      final res = await _api.dio.post('/uploads/avatar', data: formData);
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data']['url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Upload a generic attachment. Returns the URL on success.
  Future<String?> uploadAttachment(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      final res = await _api.dio.post('/uploads/attachment', data: formData);
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data']['url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
