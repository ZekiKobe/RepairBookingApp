import 'user_model.dart';
import 'service_model.dart';

class BookingModel {
  final String id;
  final UserModel? user;
  final String? userId;
  final dynamic technician;
  final String? technicianId;
  final ServiceModel? service;
  final String? serviceId;
  final String status;
  final String? description;
  final String address;
  final double price;
  final DateTime scheduledDate;
  final String? timeSlot;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String paymentStatus;

  BookingModel({
    required this.id,
    this.user,
    this.userId,
    this.technician,
    this.technicianId,
    this.service,
    this.serviceId,
    required this.status,
    this.description,
    required this.address,
    required this.price,
    required this.scheduledDate,
    this.timeSlot,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.paymentStatus = 'pending',
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: json['user'] is Map<String, dynamic> ? (() { try { return UserModel.fromJson(json['user']); } catch (_) { return null; } })() : null,
      userId: json['user'] is String ? json['user'] : (json['user'] is Map ? json['user']['_id'] : json['userId']),
      technician: json['technician'],
      technicianId: json['technician'] is String ? json['technician'] : json['technicianId'],
      service: json['service'] is Map<String, dynamic> ? (() { try { return ServiceModel.fromJson(json['service']); } catch (_) { return null; } })() : null,
      serviceId: json['service'] is String ? json['service'] : json['serviceId'],
      status: json['status'] ?? 'pending',
      description: json['description'],
      address: json['address'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : DateTime.now(),
      timeSlot: json['timeSlot'] ??
          (json['scheduledTimeSlot'] is Map
              ? '${json['scheduledTimeSlot']['start']} - ${json['scheduledTimeSlot']['end']}'
              : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      paymentStatus: json['paymentStatus'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'technicianId': technicianId,
      'serviceId': serviceId,
      'status': status,
      'description': description,
      'address': address,
      'price': price,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

// Create booking request
class CreateBookingRequest {
  final String serviceId;
  final String? technicianId;
  final String description;
  final String address;
  final double price;
  final DateTime scheduledDate;
  final Map<String, String>? scheduledTimeSlot;

  CreateBookingRequest({
    required this.serviceId,
    this.technicianId,
    required this.description,
    required this.address,
    required this.price,
    required this.scheduledDate,
    this.scheduledTimeSlot,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      if (technicianId != null) 'technicianId': technicianId,
      if (description.isNotEmpty) 'description': description,
      'address': address,
      'price': price,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTimeSlot': scheduledTimeSlot ?? {'start': '08:00', 'end': '10:00'},
    };
  }
}
