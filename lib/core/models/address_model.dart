import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_fields.dart';

class AddressModel {
  final String id;
  final String userId;
  final String label;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return AddressModel(
      id: documentId,
      userId: map[FirestoreFields.userId] as String,
      label: map[FirestoreFields.label] as String,
      address: map[FirestoreFields.address] as String,
      phone: map[FirestoreFields.phone] as String,
      latitude: (map[FirestoreFields.latitude] as num).toDouble(),
      longitude: (map[FirestoreFields.longitude] as num).toDouble(),
      isDefault: map[FirestoreFields.isDefault] as bool,
      createdAt: (map[FirestoreFields.createdAt] as Timestamp).toDate(),
      updatedAt: (map[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.userId: userId,
      FirestoreFields.label: label,
      FirestoreFields.address: address,
      FirestoreFields.phone: phone,
      FirestoreFields.latitude: latitude,
      FirestoreFields.longitude: longitude,
      FirestoreFields.isDefault: isDefault,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}
