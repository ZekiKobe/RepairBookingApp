import 'user_model.dart';
import 'service_model.dart';

class TechnicianModel {
  final String id;
  final UserModel? user;
  final String userId;
  final String? bio;
  final String? specialization;
  final double? rating;
  final int? reviewCount;
  final List<String>? skills;
  final List<ServiceModel>? services;
  final bool isApproved;
  final bool isAvailable;
  final dynamic availability;
  final String? location;
  final int? yearsOfExperience;
  final String? idDocument;
  final String? certificationDocument;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TechnicianModel({
    required this.id,
    this.user,
    required this.userId,
    this.bio,
    this.specialization,
    this.rating,
    this.reviewCount,
    this.skills,
    this.services,
    this.isApproved = false,
    this.isAvailable = true,
    this.availability,
    this.location, 
    this.yearsOfExperience,
    this.idDocument,
    this.certificationDocument,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => user?.fullName ?? 'Unknown';
  String get initials => user?.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '?';

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    // Safely parse user field (could be a Map or a String ObjectId)
    UserModel? userModel;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      try { userModel = UserModel.fromJson(rawUser); } catch (_) {}
    }

    // Safely parse services (ServiceOffering wrapper or flat ServiceModel)
    List<ServiceModel>? serviceList;
    final rawServices = json['services'];
    if (rawServices is List) {
      serviceList = rawServices.map((s) {
        if (s is! Map<String, dynamic>) return null;
        try {
          final inner = s['service'];
          if (inner is Map<String, dynamic>) {
            return ServiceModel.fromJson({
              ...inner,
              'basePrice': s['price'] ?? inner['basePrice'] ?? 0,
            });
          }
          return ServiceModel.fromJson({
            ...s,
            'basePrice': s['price'] ?? s['basePrice'] ?? 0,
          });
        } catch (_) { return null; }
      }).whereType<ServiceModel>().toList();
    }

    // Safely parse skills
    List<String>? skillList;
    final rawSkills = json['skills'];
    if (rawSkills is List) {
      skillList = rawSkills.whereType<String>().toList();
    }

    return TechnicianModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: userModel,
      userId: rawUser is String ? rawUser : (json['userId'] ?? ''),
      bio: json['bio'] as String?,
      specialization: json['specialization'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      skills: skillList,
      services: serviceList,
      isApproved: json['isApproved'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      availability: json['availability'],
      location: json['location'] is String ? json['location'] as String : null,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      idDocument: json['idDocument'] as String?,
      certificationDocument: json['certificationDocument'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'bio': bio,
      'specialization': specialization,
      'skills': skills,
      'isApproved': isApproved,
      'isAvailable': isAvailable,
      'availability': availability,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
