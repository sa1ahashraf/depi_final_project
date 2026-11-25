import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/core/enums/pharmacy_status.dart';
import 'package:depi_final_project/core/models/pharmacy_model.dart';

class PharmacyDetailModel {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final PharmacyStatus approvalStatus;
  final bool isActive;
  final double rating;
  final double distanceKm;
  final bool isOpen;
  final bool isVerified;
  final String deliveryTime;
  final List<String> paymentMethods;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PharmacyDetailModel({
    required this.id,
    this.ownerId = 'owner_default',
    required this.name,
    this.phone = '',
    this.email = '',
    required this.address,
    this.latitude = 30.0444,
    this.longitude = 31.2357,
    this.imageUrl,
    this.approvalStatus = PharmacyStatus.approved,
    this.isActive = true,
    this.rating = 4.8,
    this.distanceKm = 1.2,
    this.isOpen = true,
    this.isVerified = true,
    this.deliveryTime = '20-30 دقيقة',
    this.paymentMethods = const [
      'إكسترا باي InstaPay',
      'فودافون كاش',
      'دفع عند الاستلام',
    ],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PharmacyDetailModel.fromPharmacyModel(
    PharmacyModel model, {
    double rating = 4.8,
    double distanceKm = 1.2,
    bool isOpen = true,
    bool isVerified = true,
    String deliveryTime = '20-30 دقيقة',
    List<String>? paymentMethods,
  }) {
    return PharmacyDetailModel(
      id: model.id,
      ownerId: model.ownerId,
      name: model.name,
      phone: model.phone,
      email: model.email,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
      imageUrl: model.imageUrl,
      approvalStatus: model.approvalStatus,
      isActive: model.isActive,
      rating: rating,
      distanceKm: distanceKm,
      isOpen: isOpen,
      isVerified: isVerified,
      deliveryTime: deliveryTime,
      paymentMethods:
          paymentMethods ??
          const ['إكسترا باي InstaPay', 'فودافون كاش', 'دفع عند الاستلام'],
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  factory PharmacyDetailModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final location =
        map['location'] is Map<String, dynamic>
            ? map['location'] as Map<String, dynamic>
            : <String, dynamic>{};

    return PharmacyDetailModel(
      id: documentId,
      ownerId: map['ownerId'] as String? ?? 'owner_default',
      name: map['name'] as String? ?? 'صيدلية النور',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address:
          map['address'] as String? ??
          'شارع النصر، أمام مستشفى المعادي، عمارة 24',
      latitude:
          (location['latitude'] as num?)?.toDouble() ??
          (map['latitude'] as num?)?.toDouble() ??
          30.0444,
      longitude:
          (location['longitude'] as num?)?.toDouble() ??
          (map['longitude'] as num?)?.toDouble() ??
          31.2357,
      imageUrl: map['imageUrl'] as String?,
      approvalStatus: PharmacyStatus.values.firstWhere(
        (e) => e.value == (map['approvalStatus'] as String? ?? 'approved'),
        orElse: () => PharmacyStatus.approved,
      ),
      isActive: map['isActive'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 1.2,
      isOpen: map['isOpen'] as bool? ?? true,
      isVerified: map['isVerified'] as bool? ?? true,
      deliveryTime: map['deliveryTime'] as String? ?? '20-30 دقيقة',
      paymentMethods:
          (map['paymentMethods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['إكسترا باي InstaPay', 'فودافون كاش', 'دفع عند الاستلام'],
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'location': {'latitude': latitude, 'longitude': longitude},
      'imageUrl': imageUrl,
      'approvalStatus': approvalStatus.value,
      'isActive': isActive,
      'rating': rating,
      'distanceKm': distanceKm,
      'isOpen': isOpen,
      'isVerified': isVerified,
      'deliveryTime': deliveryTime,
      'paymentMethods': paymentMethods,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PharmacyDetailModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    PharmacyStatus? approvalStatus,
    bool? isActive,
    double? rating,
    double? distanceKm,
    bool? isOpen,
    bool? isVerified,
    String? deliveryTime,
    List<String>? paymentMethods,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PharmacyDetailModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      distanceKm: distanceKm ?? this.distanceKm,
      isOpen: isOpen ?? this.isOpen,
      isVerified: isVerified ?? this.isVerified,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
