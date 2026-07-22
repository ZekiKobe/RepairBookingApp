class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? icon;
  final double basePrice;
  final bool isActive;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.icon,
    required this.basePrice,
    this.isActive = true,
    required this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'],
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'basePrice': basePrice,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Service category model
class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final int serviceCount;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.serviceCount = 0,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      serviceCount: json['serviceCount'] ?? 0,
    );
  }
}
