import '../constants/firestore_fields.dart';

class OrderItemModel {
  final String medicineId;
  final String medicineName;
  final String strength;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.strength,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      medicineId: map[FirestoreFields.medicineId] as String,
      medicineName: map[FirestoreFields.medicineName] as String,
      strength: map[FirestoreFields.strength] as String,
      quantity: (map[FirestoreFields.quantity] as num).toInt(),
      unitPrice: (map[FirestoreFields.unitPrice] as num).toDouble(),
      subtotal: (map[FirestoreFields.subtotal] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.medicineId: medicineId,
      FirestoreFields.medicineName: medicineName,
      FirestoreFields.strength: strength,
      FirestoreFields.quantity: quantity,
      FirestoreFields.unitPrice: unitPrice,
      FirestoreFields.subtotal: subtotal,
    };
  }
}
