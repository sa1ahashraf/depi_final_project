import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_fields.dart';

class InventoryModel {
  final String id;
  final String pharmacyId;
  final String medicineId;
  final double price;
  final int quantity;
  final bool isAvailable;
  final bool publicVisible;
  final DateTime updatedAt;

  const InventoryModel({
    required this.id,
    required this.pharmacyId,
    required this.medicineId,
    required this.price,
    required this.quantity,
    required this.isAvailable,
    required this.publicVisible,
    required this.updatedAt,
  });

  factory InventoryModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return InventoryModel(
      id: documentId,
      pharmacyId: map[FirestoreFields.pharmacyId] as String,
      medicineId: map[FirestoreFields.medicineId] as String,
      price: (map[FirestoreFields.price] as num).toDouble(),
      quantity: (map[FirestoreFields.quantity] as num).toInt(),
      isAvailable: map[FirestoreFields.isAvailable] as bool,
      publicVisible: map[FirestoreFields.publicVisible] as bool,
      updatedAt: (map[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.pharmacyId: pharmacyId,
      FirestoreFields.medicineId: medicineId,
      FirestoreFields.price: price,
      FirestoreFields.quantity: quantity,
      FirestoreFields.isAvailable: isAvailable,
      FirestoreFields.publicVisible: publicVisible,
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}
