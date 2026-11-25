import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';

class CartPharmacyGroup {
  final String pharmacyId;
  final String pharmacyName;
  final String? pharmacyAddress;
  final String? pharmacyDeliveryTime;
  final PharmacyDetailModel? pharmacy;
  final List<CartItemModel> items;
  final bool isSelected;

  const CartPharmacyGroup({
    required this.pharmacyId,
    required this.pharmacyName,
    this.pharmacyAddress,
    this.pharmacyDeliveryTime,
    this.pharmacy,
    required this.items,
    this.isSelected = true,
  });

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  CartPharmacyGroup copyWith({
    String? pharmacyId,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyDeliveryTime,
    PharmacyDetailModel? pharmacy,
    List<CartItemModel>? items,
    bool? isSelected,
  }) {
    return CartPharmacyGroup(
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacyAddress: pharmacyAddress ?? this.pharmacyAddress,
      pharmacyDeliveryTime: pharmacyDeliveryTime ?? this.pharmacyDeliveryTime,
      pharmacy: pharmacy ?? this.pharmacy,
      items: items ?? this.items,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
