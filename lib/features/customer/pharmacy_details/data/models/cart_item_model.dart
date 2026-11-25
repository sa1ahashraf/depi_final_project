import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

class CartItemModel {
  final PharmacyInventoryItemModel item;
  final int quantity;
  final String pharmacyId;
  final String pharmacyName;
  final String? pharmacyAddress;
  final String? pharmacyDeliveryTime;
  final PharmacyDetailModel? pharmacy;

  const CartItemModel({
    required this.item,
    required this.quantity,
    this.pharmacyId = '',
    this.pharmacyName = '',
    this.pharmacyAddress,
    this.pharmacyDeliveryTime,
    this.pharmacy,
  });

  String get effectivePharmacyId =>
      pharmacyId.isNotEmpty ? pharmacyId : (pharmacy?.id ?? item.pharmacyId);

  String get effectivePharmacyName =>
      pharmacyName.isNotEmpty ? pharmacyName : (pharmacy?.name ?? 'الصيدلية');

  double get totalPrice => item.price * quantity;

  CartItemModel copyWith({
    PharmacyInventoryItemModel? item,
    int? quantity,
    String? pharmacyId,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyDeliveryTime,
    PharmacyDetailModel? pharmacy,
  }) {
    return CartItemModel(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacyAddress: pharmacyAddress ?? this.pharmacyAddress,
      pharmacyDeliveryTime: pharmacyDeliveryTime ?? this.pharmacyDeliveryTime,
      pharmacy: pharmacy ?? this.pharmacy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': item.id,
      'medicineId': item.medicineId,
      'name': item.name,
      'genericName': item.genericName,
      'price': item.price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'pharmacyId': effectivePharmacyId,
      'pharmacyName': effectivePharmacyName,
      'pharmacyAddress': pharmacyAddress ?? pharmacy?.address,
      'pharmacyDeliveryTime': pharmacyDeliveryTime ?? pharmacy?.deliveryTime,
    };
  }
}
