import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryBoyModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String vehicleNumber;
  final String image;
  final bool isActive;
  final DateTime? createdAt;
  final String fcmToken;

  DeliveryBoyModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.vehicleNumber,
    required this.image,
    required this.isActive,
    required this.createdAt,
    required this.fcmToken,
  });

  factory DeliveryBoyModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final created = data['created_at'];
    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is String) {
      createdAt = DateTime.tryParse(created);
    }

    return DeliveryBoyModel(
      id: id,
      vendorId: (data['vendor_id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      password: (data['password'] ?? '').toString(),
      vehicleNumber: (data['vehicle_number'] ?? '').toString(),
      image: (data['image'] ?? '').toString(),
      isActive: (data['is_active'] as bool?) ?? true,
      createdAt: createdAt,
      fcmToken: (data['fcm_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendor_id': vendorId,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'vehicle_number': vehicleNumber,
      'image': image,
      'is_active': isActive,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'fcm_token': fcmToken,
    };
  }
}

