import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_fields.dart';
import '../enums/pharmacy_status.dart';

class PharmacyModel {
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const PharmacyModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.approvalStatus,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PharmacyModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final location = map[FirestoreFields.location] as Map<String, dynamic>;

    return PharmacyModel(
      id: documentId,
      ownerId: map[FirestoreFields.ownerId] as String,
      name: map[FirestoreFields.name] as String,
      phone: map[FirestoreFields.phone] as String,
      email: map[FirestoreFields.email] as String,
      address: map[FirestoreFields.address] as String,
      latitude: (location[FirestoreFields.latitude] as num).toDouble(),
      longitude: (location[FirestoreFields.longitude] as num).toDouble(),
      imageUrl: map[FirestoreFields.imageUrl] as String?,
      approvalStatus: PharmacyStatus.values.firstWhere(
        (e) => e.value == map[FirestoreFields.approvalStatus],
      ),
      isActive: map[FirestoreFields.isActive] as bool,
      createdAt: (map[FirestoreFields.createdAt] as Timestamp).toDate(),
      updatedAt: (map[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.ownerId: ownerId,
      FirestoreFields.name: name,
      FirestoreFields.phone: phone,
      FirestoreFields.email: email,
      FirestoreFields.address: address,
      FirestoreFields.location: {
        FirestoreFields.latitude: latitude,
        FirestoreFields.longitude: longitude,
      },
      FirestoreFields.imageUrl: imageUrl,
      FirestoreFields.approvalStatus: approvalStatus.value,
      FirestoreFields.isActive: isActive,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}
