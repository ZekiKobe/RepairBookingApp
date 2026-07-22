class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final String? email;
  final String? avatar;
  final Map<String, dynamic>? location;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.email,
    this.avatar,
    this.location,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      email: json['email'],
      avatar: json['avatar'],
      location: json['location'] is Map<String, dynamic> ? json['location'] as Map<String, dynamic> : null,
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'email': email,
      'avatar': avatar,
      'location': location,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Login request model
class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
      };
}

// Register request model
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String role;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'password': password,
        'role': role,
      };
}
