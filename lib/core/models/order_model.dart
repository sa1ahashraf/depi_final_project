import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_fields.dart';
import '../enums/order_status.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String pharmacyId;
  final List<OrderItemModel> items;
  final double totalPrice;
  final double deliveryFee;
  final Map<String, dynamic> deliveryAddress;
  final OrderStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.pharmacyId,
    required this.items,
    required this.totalPrice,
    required this.deliveryFee,
    required this.deliveryAddress,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return OrderModel(
      id: documentId,
      customerId: map[FirestoreFields.customerId] as String,
      pharmacyId: map[FirestoreFields.pharmacyId] as String,
      items: (map[FirestoreFields.items] as List)
          .map(
            (item) =>
                OrderItemModel.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      totalPrice: (map[FirestoreFields.totalPrice] as num).toDouble(),
      deliveryFee: (map[FirestoreFields.deliveryFee] as num).toDouble(),
      deliveryAddress: Map<String, dynamic>.from(
        map[FirestoreFields.deliveryAddress] as Map,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.value == map[FirestoreFields.status],
      ),
      rejectionReason: map[FirestoreFields.rejectionReason] as String?,
      createdAt: (map[FirestoreFields.createdAt] as Timestamp).toDate(),
      updatedAt: (map[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.customerId: customerId,
      FirestoreFields.pharmacyId: pharmacyId,
      FirestoreFields.items: items.map((item) => item.toMap()).toList(),
      FirestoreFields.totalPrice: totalPrice,
      FirestoreFields.deliveryFee: deliveryFee,
      FirestoreFields.deliveryAddress: deliveryAddress,
      FirestoreFields.status: status.value,
      FirestoreFields.rejectionReason: rejectionReason,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}
